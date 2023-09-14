import math


def load() -> list[list[str]]:
    default = open(f"./input/day10.txt").readlines()
    return [list(x.strip()) for x in default]


def test() -> list[list[str]]:
    s = """.#..##.###...#######
##.############..##.
.#.######.########.#
.###.#######.####.#.
#####.##.#.##.###.##
..#####..#.#########
####################
#.####....###.#.#.##
##.#################
#####.##.###..####..
..######..##.#######
####.##.####...##..#
.#####..#.######.###
##...#.##########...
#.##########.#######
.####.#.###.###.#.##
....##.##.###..#####
.#.#.###########.###
#.#.#.#####.####.###
###.##.####.##.#..##"""
    return [list(x) for x in s.split()]


def get_points(initial):
    points = set()
    for y, sublist in enumerate(initial):
        for x, v in enumerate(sublist):
            if v == "#":
                points.add((x, y))
    return points


def get_slope(p1: tuple[int, int], p2: tuple[int, int]) -> tuple[int, int]:
    """
    We are lazy here: Use a Fraction to reduce the slope to the smallest possible unit
    i.e. if we have (0, 0) and (2, 4), our slope is (1, 2).
    """
    if p1 == p2:
        raise ZeroDivisionError(f"Can't find the slope of a single point={p1}")

    if p1[0] - p2[0] == 0:
        return 0, ((p1[1] - p2[1]) // abs(p1[1] - p2[1]))
    elif p1[1] - p2[1] == 0:
        return ((p1[0] - p2[0]) // abs(p1[0] - p2[0])), 0

    gcd = math.gcd(p1[0] - p2[0], p1[1] - p2[1])
    return (p1[0] - p2[0]) // gcd, (p1[1] - p2[1]) // gcd


def part1(default=load()):
    """
    Insight(s):
    - All asteroids are:
        - Visible, or
        - Behind an asteroid that is visible _in the same line_
    - We can pick _any_ asteroid and remove all asteroids in that line
    """
    points = get_points(default)

    best = (0, 0), 0
    for station in points:
        visible = set()
        for asteroid in points:
            if station != asteroid:
                visible.add(get_slope(station, asteroid))
        if len(visible) > best[1]:
            best = station, len(visible)
    return best


def manhatten(p1: tuple[int, int], p2: tuple[int, int]) -> int:
    return abs(p2[0] - p1[0]) + abs(p2[1] - p1[1])


def part2(mapping: list[list[str]] = load(), pos: int = 200):
    """
    Insight(s):
    - Now we care about distance
    - But we still care about slope (i.e. angle)
    - So likely what we want is something like:
      - Order all slopes by angle
      - Order all asteroids by position along each slope
      - Round-robin down the list popping the nearest asteroid from each angle
    - How do we round-robin..? By using angles!
    """
    points = get_points(mapping)
    station = part1(mapping)[0]
    points.remove(station)
    points = sorted(list(points), key=lambda x: manhatten(station, x))

    # Now we want to make a list of angles (in radians) and their constituent points
    d = {}
    for point in points:
        slope = get_slope(station, point)
        # Rounding to ensure we can get items "in line," giving flexibility for floats
        deg = round((math.degrees(math.atan2(slope[1], slope[0])) + 270) % 360, 1)
        # Each time there's an earlier asteroid, we need to do another loop to laser the current one
        while d.get(deg):
            deg += 360
        d[deg] = point

    # Sort the asteroids along each line by distance from the station
    ordered_lines = [d[x] for x in sorted(d)]

    return ordered_lines[pos - 1]


if __name__ == "__main__":
    assert part1(test())[1] == 210
    assert part1()[1] == 282
    assert part2(test()) == (8, 2)
    assert part2() == (10, 8)
