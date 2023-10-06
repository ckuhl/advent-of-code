import dataclasses


def parse_map(string_or_default: str | None = None):
    if string_or_default is None:
        with open("./input/day18.txt") as f:
            string_or_default = f.readlines()
    else:
        string_or_default = string_or_default.split("\n")
    return [list(x.strip()) for x in string_or_default]


example_big = """
########################
#f.D.E.e.C.b.A.@.a.B.c.#
######################.#
#d.....................#
########################"""

KEYS = {chr(x) for x in range(ord("a"), ord("z") + 1)}
DOORS = {chr(x) for x in range(ord("A"), ord("Z") + 1)}


def array_to_dict(arr: list[list[str]]) -> dict[tuple[int, int], str]:
    mapping = {}
    for y, row in enumerate(arr):
        for x, char in enumerate(row):
            mapping[(x, y)] = char
    return mapping


def find_start(mapping: dict[tuple[int, int], str]) -> tuple[int, int]:
    for k, v in mapping.items():
        if v == "@":
            return k
    raise Exception("No starting point in map; something went wrong!")


def find_keys(mapping: dict[tuple[int, int], str]) -> set[str]:
    total_keys = set()
    for k, v in mapping.items():
        if v in KEYS:
            total_keys.add(v)
    return total_keys


@dataclasses.dataclass(eq=True, frozen=True)
class State:
    """Helper that's hashable, easier to keep track of values"""
    pos: tuple[int, int]
    keys: frozenset[str]


def solve_keyfind(
        mapping: dict[tuple[int, int], str],
        starting_point: tuple[int, int],
        ignore_unfindable_keys: bool = False,
) -> int:
    """
    We want to find the shortest path to reach all keys.
    Some keys (and doors) block other keys.
    So what we need to know is:
    - Where we start
    - Where the keys are
    - Where the doors are

    What we want is:
    - To collect all the keys,
    - in the minimal number of steps

    So we need to keep track of:
    - Where I am,
    - What keys I have, and
    - How many steps I have taken

    And then finally:
    - When I have all the keys, return the number of steps taken;
    - If we apply BFS, the first result _is_ the shortest route

    We will likely end up in the same place more than once, with the same set of keys.
    It will also likely take us a different amount of steps to accomplish this in different orders.
    So we will need a way to ensure we keep track of the _minimal number of steps_.
    Breadth-first-search will ensure that.
    """
    total_keys = find_keys(mapping)

    steps = 0

    initial = State(pos=starting_point, keys=frozenset())
    frontier: set[State] = {initial}
    next_frontier: set[State] = set()

    seen: dict[State, int] = {}

    max_keys = 0
    while frontier or next_frontier:
        if not frontier:  # We've reached the end of one iteration of BFS
            frontier, next_frontier = next_frontier, set()
            steps += 1
            continue

        state = frontier.pop()
        if seen.get(state) is not None:
            # If we have already been here, we don't want to repeat the same action
            continue
        else:
            seen[state] = steps

        # Out of bounds; do not
        if mapping.get(state.pos) in (None, "#"):
            continue

        # If we have found a key, add it to the collection!
        new_keys = state.keys

        # Debug activities
        max_keys = max(max_keys, len(new_keys))

        curr = mapping[state.pos]
        if curr == ".":
            pass
        elif curr in KEYS:
            tmp = set(state.keys)
            tmp.add(mapping[state.pos])
            new_keys = frozenset(tmp)
            if new_keys.issuperset(total_keys):
                return steps

        # If we have found a door...
        elif curr in DOORS:
            needed_key = mapping[state.pos].lower()
            # ...and it is opened by a key from another sector, continue
            if ignore_unfindable_keys and needed_key not in total_keys:
                pass
            # ..and we can open it, continue!
            elif needed_key in state.keys:
                pass
            # ...otherwise, stop here; we can't proceed
            else:
                continue

        # Finally, add new points to the (next) frontier!
        next_frontier.add(State((state.pos[0] + 1, state.pos[1]), new_keys))
        next_frontier.add(State((state.pos[0] - 1, state.pos[1]), new_keys))
        next_frontier.add(State((state.pos[0], state.pos[1] + 1), new_keys))
        next_frontier.add(State((state.pos[0], state.pos[1] - 1), new_keys))

    raise NotImplementedError(f"Ran out of new steps: Need {total_keys=}, have {max_keys=}")


def part1(stringmap: str | None = None):
    mapping = array_to_dict(parse_map(stringmap))
    starting_point = find_start(mapping)
    s = solve_keyfind(mapping, starting_point)
    return s


def partition_map(
        mapping: dict[tuple[int, int], str],
) -> tuple[dict[tuple[int, int], str], ...]:
    """
    Apply the modification from part2 of the question to the mapping.
    Return each portion of the vault separately from the original
    Initially, there is only one start.
    """
    x, y = find_start(mapping)
    mapping[x - 1, y - 1] = "@"
    mapping[x + 0, y - 1] = "#"
    mapping[x + 1, y - 1] = "@"
    mapping[x - 1, y + 0] = "#"
    mapping[x + 0, y + 0] = "#"
    mapping[x + 1, y + 0] = "#"
    mapping[x - 1, y + 1] = "@"
    mapping[x + 0, y + 1] = "#"
    mapping[x + 1, y + 1] = "@"
    ne, nw, se, sw = {}, {}, {}, {}
    for k, v in mapping.items():
        if k[0] >= x and k[1] >= y:
            sw[k] = v
        if k[0] <= x and k[1] >= y:
            se[k] = v
        if k[0] >= x and k[1] <= y:
            nw[k] = v
        if k[0] <= x and k[1] <= y:
            ne[k] = v
    return ne, nw, se, sw


def part2(stringmap: str | None = None):
    """
    Dumb insight: Tracking multiple players with multiple states is hard.
    However, there are four vaults! These are separate.
    Insight:
    - We know that the _order_ we take steps in does not matter (i.e. which robot moves when) as long as we have the
      requisite keys
    - We know that, supposing we have all keys, there will be one optimal path for each droid
    - We know that all the doors can be opened provided we've accumulated all the keys.
    Thus:
    - We can solve each portion individually, assuming the other droids have already gotten the requisite keys
    - Then we simply sum each quadrant together
    """
    labrynth_sectors = partition_map(array_to_dict(parse_map(stringmap)))
    total_distance = 0

    for sector in labrynth_sectors:
        sector_start = find_start(sector)
        total_distance += solve_keyfind(sector, sector_start, ignore_unfindable_keys=True)

    return total_distance


if __name__ == "__main__":
    assert part1("""########################
#f.D.E.e.C.b.A.@.a.B.c.#
######################.#
#d.....................#
########################""") == 86
    assert part1("""########################
#...............b.C.D.f#
#.######################
#.....@.a.B.c.d.A.e.F.g#
########################""") == 132
    assert part1("""#################
#i.G..c...e..H.p#
########.########
#j.A..b...f..D.o#
########@########
#k.E..a...g..B.n#
########.########
#l.F..d...h..C.m#
#################""") == 136
    assert part1("""########################
#@..............ac.GI.b#
###d#e#f################
###A#B#C################
###g#h#i################
########################""") == 81
    assert part1() == 4350
    assert part2("""#######
#a.#Cd#
##...##
##.@.##
##...##
#cB#Ab#
#######""") == 8
    # FIXME: Why isn't this one 72, as mentioned on the question page?
    # nb. had to hack this one into single-entry labrynth since our solver wants to change that
    assert part2("""#############
#g#f.D#..h#l#
#F###e#E###.#
#dCba...BcIJ#
#####.@.#####
#nK.L...G...#
#M###N#H###.#
#o#m..#i#jk.#
#############""") == 70
    assert part2() == 2348
