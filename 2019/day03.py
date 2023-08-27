from pathlib import Path


def load():
    default = open(f"{Path(__file__).stem}.txt").readlines()
    return [x.strip().split(",") for x in default]


def test():
    l = ["R8,U5,L5,D3", "U7,R6,D4,L4"]
    return [x.strip().split(",") for x in l]


def direction(segment: str) -> tuple[int, int]:
    return {
        "R": (+1, 0),
        "L": (-1, 0),
        "U": (0, -1),
        "D": (0, +1),
    }[segment[0]]


def line_segment(pos: tuple[int, int], segment: str, dist: int) -> dict[tuple[int, int], int]:
    distance = int(segment[1:])
    return {(pos[0] + direction(segment)[0] * x,
             pos[1] + direction(segment)[1] * x): dist + x for x in range(distance)}


def new_point(point: tuple[int, int], segment) -> tuple[int, int]:
    return (
        point[0] + direction(segment)[0] * int(segment[1:]),
        point[1] + direction(segment)[1] * int(segment[1:]),
    )


def points_visited(line: list[str]) -> dict[tuple[int, int], int]:
    x, y, dist = 0, 0, 0
    visited = {}
    for point in line:
        # We update visited "backwards" so that we take the _earliest / lowest_ key value
        tmp = line_segment((x, y), point, dist)
        tmp.update(visited)
        visited = tmp
        x, y = new_point((x, y), point)
        dist += int(point[1:])
    return visited


def find_overlap(data: list[list[str]]) -> dict[tuple[int, int], int]:
    lines = [points_visited(x) for x in data]
    first, second = lines
    return {k: first[k] + second[k] for k in first.keys() & second.keys()}


def find_smallest_abs_point(points: dict[tuple[int, int], int]) -> tuple[int, int]:
    del points[(0, 0)]
    return list(sorted(list(points), key=lambda x: abs(x[0]) + abs(x[1])))[0]


def part1():
    x, y = find_smallest_abs_point(find_overlap(load()))
    return abs(x) + abs(y)


def find_earliest_distance(points: dict[tuple[int, int], int]) -> int:
    del points[(0, 0)]
    earliest = sorted(points, key=lambda k: points[k])[0]
    return points[earliest]


def part2():
    return find_earliest_distance(find_overlap(load()))


if __name__ == "__main__":
    print(part1())
    print(part2())
