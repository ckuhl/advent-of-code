from collections import defaultdict

EXAMPLE1 = """         A           
         A           
  #######.#########  
  #######.........#  
  #######.#######.#  
  #######.#######.#  
  #######.#######.#  
  #####  B    ###.#  
BC...##  C    ###.#  
  ##.##       ###.#  
  ##...DE  F  ###.#  
  #####    G  ###.#  
  #########.#####.#  
DE..#######...###.#  
  #.#########.###.#  
FG..#########.....#  
  ###########.#####  
             Z       
             Z       """

EXAMPLE2 = """                   A               
                   A               
  #################.#############  
  #.#...#...................#.#.#  
  #.#.#.###.###.###.#########.#.#  
  #.#.#.......#...#.....#.#.#...#  
  #.#########.###.#####.#.#.###.#  
  #.............#.#.....#.......#  
  ###.###########.###.#####.#.#.#  
  #.....#        A   C    #.#.#.#  
  #######        S   P    #####.#  
  #.#...#                 #......VT
  #.#.#.#                 #.#####  
  #...#.#               YN....#.#  
  #.###.#                 #####.#  
DI....#.#                 #.....#  
  #####.#                 #.###.#  
ZZ......#               QG....#..AS
  ###.###                 #######  
JO..#.#.#                 #.....#  
  #.#.#.#                 ###.#.#  
  #...#..DI             BU....#..LF
  #####.#                 #.#####  
YN......#               VT..#....QG
  #.###.#                 #.###.#  
  #.#...#                 #.....#  
  ###.###    J L     J    #.#.###  
  #.....#    O F     P    #.#...#  
  #.###.#####.#.#####.#####.###.#  
  #...#.#.#...#.....#.....#.#...#  
  #.#####.###.###.#.#.#########.#  
  #...#.#.....#...#.#.#.#.....#.#  
  #.###.#####.###.###.#.#.#######  
  #.#.........#...#.............#  
  #########.###.###.#############  
           B   J   C               
           U   P   P               """


def parse(string_or_default: str | None = None) -> NotImplemented:
    if string_or_default is None:
        with open("./input/day20.txt") as f:
            string = f.readlines()
    else:
        string = string_or_default.split("\n")

    mapping = {}
    for y, line in enumerate(string):
        for x, v in enumerate(line):
            if not v.isspace():
                mapping[(x, y)] = v

    return mapping


def extract_portals(mapping: dict[tuple[int, int], str]) -> dict[tuple[int, int], str]:
    """
    Given an unprocessed mapping, return a new mapping of:
    portal_pos: portal_tag
    >>> extract_portals(parse(EXAMPLE1))
    >>> {(9, 2): 'AA', (9, 6): 'BC', (2, 8): 'BC', (6, 10): 'DE', (11, 12): 'FG', (2, 13): 'DE', (2, 15): 'FG', (13, 16): 'ZZ'}

    Since tags are always in whitespace, we will only add when we find the middle of a tag, to avoid duplication.
    """
    tags = {}
    for k, v in mapping.items():
        if not v.isalpha():
            continue
        right, left = mapping.get((k[0] + 1, k[1])), mapping.get((k[0] - 1, k[1]))
        down, up = mapping.get((k[0], k[1] + 1)), mapping.get((k[0], k[1] - 1))
        if left and right:
            if left.isalpha():
                tags[(k[0] + 1, k[1])] = left + v
            else:
                tags[(k[0] - 1, k[1])] = v + right
        if up and down:
            if up.isalpha():
                tags[(k[0], k[1] + 1)] = up + v
            else:
                tags[(k[0], k[1] - 1)] = v + down
    return tags


def construct_weighted_graph(
        mapping: dict[tuple[int, int], str],
        portals: dict[tuple[int, int], str],
) -> dict[str, list[tuple[str, int]]]:
    """
    Given a donut map and a mapping of portals:
    1. Select a portal.
    2. Add an entry to our list of portal routes.
    3. BFS to every other portal reachable.
        a. For each portal reached, add the portal and number of steps to reach it to the routes.
    4. Return this mapping.
    """
    graph = defaultdict(list)
    for pos, tag in portals.items():
        curr_frontier, next_frontier = [pos], []
        steps = 0
        seen = set()
        while curr_frontier or next_frontier:
            if not curr_frontier:
                curr_frontier, next_frontier = next_frontier, []
                steps += 1

            prospect = curr_frontier.pop()
            if prospect in seen:
                continue

            else:
                seen.add(prospect)

            if mapping.get(prospect) != ".":
                continue

            if prospect in portals and portals[prospect] != tag:
                graph[tag].append((portals[prospect], steps,))

            next_frontier.append((prospect[0] + 1, prospect[1]))
            next_frontier.append((prospect[0] - 1, prospect[1]))
            next_frontier.append((prospect[0], prospect[1] + 1))
            next_frontier.append((prospect[0], prospect[1] - 1))

    return graph


def minimum_cost_weight_graph(
        graph: dict[str, list[tuple[str, int]]],
        start: str,
        stop: str,
) -> int:
    """
    Given a graph mapping costs between nodes, what is the minimum cost to get from the start to the end?
    This is a variation on BFS:
    - We need to track cost
    - We need to track routes (to catch cycles)
    - We end early when all routes in the frontier (and next frontier) are higher-cost than the shortest known route
    """
    shortest_route = float("inf")
    frontier, next_frontier = {(start,): 0}, {}
    while frontier or next_frontier:
        if not frontier:
            frontier = {k: v for k, v in next_frontier.items()}
            next_frontier = {}

        candidate, cost = frontier.popitem()
        for neighbour, travel_cost in graph[candidate[-1]]:
            if neighbour in candidate:
                # Cycling; don't do that
                continue
            elif neighbour == stop:
                # We found the end; is it a good one?
                shortest_route = min(shortest_route, cost + travel_cost)
                continue

            # Continue iterating
            route = tuple(list(candidate) + [neighbour])
            next_frontier[route] = min(next_frontier.get(route, float("inf")), cost + travel_cost + 1)

    return shortest_route


def part1(string_or_default: str | None = None):
    raw = parse(string_or_default)
    portals = extract_portals(raw)
    weighted_graph = construct_weighted_graph(raw, portals)
    return minimum_cost_weight_graph(weighted_graph, "AA", "ZZ")


def part2():
    """Todo: Solve part 2 once off the plane"""
    raise NotImplementedError


if __name__ == "__main__":
    assert part1(EXAMPLE1) == 23
    assert part1(EXAMPLE2) == 58
    assert part1() == 686
