from pathlib import Path


def load():
    default = open(f"{Path(__file__).stem}.txt").readlines()
    return [x.strip().split(",") for x in default]


def get_displacement(segment: str) -> tuple[int, int]:
    return {
        "R": (+1, 0),
        "L": (-1, 0),
        "U": (0, -1),
        "D": (0, +1),
    }[segment[0]]


def line_segment(pos: tuple[int, int], segment: str) -> set[tuple[int, int]]:
    distance = int(segment[1:])
    return {(pos[0] + get_displacement(segment)[0] * x, pos[1] + get_displacement(segment)[1] * x) for x in
            range(distance)}


def new_point(point: tuple[int, int], segment) -> tuple[int, int]:
    return (
        point[0] + get_displacement(segment)[0] * int(segment[1:]),
        point[1] + get_displacement(segment)[1] * int(segment[1:]),
    )


def points_visited(line: list[str]) -> set[tuple[int, int]]:
    # FIXME: We need to: update position on each move
    #  Generate all segments from _both_ lines
    #  Find all intersecting points
    #  Find the minimal one
    x, y = 0, 0
    visited = set()
    for point in line:
        visited.update(line_segment((x, y), point))
        x, y = new_point((x, y), point)
    return visited


def find_overlap() -> set[tuple[int, int]]:
    lines = [points_visited(x) for x in load()]
    first, second = lines
    return first.intersection(second)


def find_smallest_abs_point(points: set[tuple[int, int]]) -> tuple[int, int]:
    points.remove((0, 0))
    return list(sorted(list(points), key=lambda x: abs(x[0]) + abs(x[1])))[0]


def part1():
    x, y = find_smallest_abs_point(find_overlap())
    return abs(x) + abs(y)


def part2():
    # TODO: Now we care about distance as well. Likely we want to use a dict and count steps of each wire.
    #       Taking an intersection then means summing the values of both points.
    #       Then we just need to sort the keys and choose the lowest.
    raise NotImplementedError


if __name__ == "__main__":
    print(part1())
