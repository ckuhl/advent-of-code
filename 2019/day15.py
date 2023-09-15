import copy

from common import IntcodeComputer

NORTH, SOUTH, WEST, EAST = 1, 2, 3, 4


class RepairDroid:
    def __init__(
            self,
            prog: list[int] | None = None,
            pos: tuple[int, int] | None = None,
    ):
        self.cpu = IntcodeComputer(prog or f"./input/day15.txt")
        self.pos = pos or (0, 0)

    def split(self):
        return RepairDroid(
            copy.deepcopy(self.cpu.memory),
            copy.deepcopy(self.pos),
        )

    def move(self, direction: int) -> str:
        if direction == 1:
            self.pos = self.pos[0], self.pos[1] + 1
        elif direction == 2:
            self.pos = self.pos[0], self.pos[1] - 1
        elif direction == 3:
            self.pos = self.pos[0] - 1, self.pos[1]
        elif direction == 4:
            self.pos = self.pos[0] + 1, self.pos[1]
        else:
            raise NotImplementedError

        self.cpu.input_queue.append(direction)
        self.cpu.computer()
        movement_result = self.cpu.output_queue.pop()
        if movement_result == 0:
            return "#"
        elif movement_result == 1:
            return "."
        elif movement_result == 2:
            return "O"
        else:
            raise NotImplementedError


def part1():
    """
    There's a right way and a dumb/fun way to do this.

    Realistically, you want to do depth-first-search with the robot, backtracking with necessary.

    What's more fun is using the knowledge that your robot is virtual, and splitting the universe at each point.
    Like the popular trope that each decision we make is a diverging point between parallel universes, for this dear
    robot it really is. We keep track of each of the robots.

    If they hit a wall, we give up on them.

    If they find the air filter, they are the Chosen One.

    (This is also possibly more efficent than backtracking, as we never waste time backtracking. Just copying memory.)
    """
    layout = {(0, 0): "."}

    frontier = {(0, 0): RepairDroid()}
    next_frontier = {}
    depth = 1
    while frontier or next_frontier:
        if not frontier:
            frontier, next_frontier = next_frontier, {}
            depth += 1

        selected = frontier.popitem()[1]
        for i in (1, 2, 3, 4):
            j = selected.split()
            tile = j.move(i)
            if tile == "." and j.pos not in layout:
                layout[j.pos] = tile
                next_frontier[j.pos] = j
            elif tile == "O":
                return depth


def find_full_map():
    layout = {(0, 0): "."}

    frontier = {(0, 0): RepairDroid()}
    next_frontier = {}
    depth = 1
    while frontier or next_frontier:
        if not frontier:
            frontier, next_frontier = next_frontier, {}
            depth += 1

        selected = frontier.popitem()[1]
        for i in (1, 2, 3, 4):
            j = selected.split()
            tile = j.move(i)
            if tile != "#" and j.pos not in layout:
                layout[j.pos] = tile
                next_frontier[j.pos] = j
    return layout


def part2():
    """
    Copypasta part1, remove the early exit.

    TODO: Merge the two; accept the slowdown of generating the map once and cache it. Then use that in part1 and 2.
    """
    layout = find_full_map()

    # Here's something horrifying: Use the knowledge that dicts are now deterministic to look up the key by the value
    starting_point = list(layout.keys())[list(layout.values()).index("O")]

    # Count the number of minutes since the oxygen system was turned on (starts at 0)
    minutes = 0

    # Track the current frontier and the next frontier
    # TODO: Maybe use sets?
    frontier: list[tuple[int, int]] = [starting_point]
    next_frontier: list[tuple[int, int]] = []

    while frontier or next_frontier:
        if not frontier:
            frontier, next_frontier = next_frontier, []
            minutes += 1

        curr_x, curr_y = frontier.pop()
        for x, y in ((0, 1), (0, -1), (1, 0), (-1, 0)):
            new_pos = (curr_x + x, curr_y + y)
            tile = layout.pop(new_pos, "#")
            if tile != "#":
                next_frontier.append(new_pos)

    return minutes


if __name__ == "__main__":
    assert part1() == 218
    assert part2() == 544
