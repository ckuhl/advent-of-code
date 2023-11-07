EXAMPLE2 = """....#
#..#.
#.?##
..#..
#...."""


def parse(input_or_none: str | None = None) -> dict[tuple[int, int, int], str]:
    """Parse in the question input, or an example, into a dictionary representing the map"""
    if input_or_none is None:
        with open("./input/day24.txt") as f:
            string = f.read()
    else:
        string = input_or_none

    mapping = {}
    for y, line in enumerate(string.splitlines()):
        for x, char in enumerate(line):
            mapping[(x, y, 0)] = char

    return mapping


def adjacent_points(
        point: tuple[int, int, int],
        is_recursive: bool = False,
) -> list[tuple[int, int, int]]:
    """
    Helper: Generate the valid neighbouring points to a given point.
    Includes optional is_recursive to handle part 2.
    """
    points = []
    x, y, d = point
    for x_offset, y_offset in ((0, 1), (1, 0), (0, -1), (-1, 0)):
        new_x = x + x_offset
        new_y = y + y_offset

        # Case: Recurse inwards
        if is_recursive and new_x == new_y == 2:
            if x_offset == 1:
                # On left
                points += [(0, y, d + 1) for y in range(5)]
            elif x_offset == -1:
                # On right
                points += [(4, y, d + 1) for y in range(5)]
            elif y_offset == 1:
                # On bottom
                points += [(x, 0, d + 1) for x in range(5)]
            elif y_offset == -1:
                # On top
                points += [(x, 4, d + 1) for x in range(5)]

        # Case: Recurse outwards
        elif is_recursive and (new_x > 4 or new_x < 0 or new_y > 4 or new_y < 0):
            points.append((2 + x_offset, 2 + y_offset, d - 1))

        # Case: Regular point, or non-recursive map
        else:
            points.append((new_x, new_y, d))

    return points


def neighbour_count_and_new_points(
        point: tuple[int, int, int],
        mapping: dict[tuple[int, int, int], str],
        is_recursive: bool = False,
) -> tuple[int, list[tuple[int, int, int]]]:
    """
    Return the count of neighbours for a given point, as well as newly-discovered points.
    Newly discovered points are used by part 2.
    """
    n = 0
    new_points = []
    for i in adjacent_points(point, is_recursive):
        tile = mapping.get(i)
        if tile == "#":
            n += 1
        elif tile is None:
            new_points.append(i)
    return n, new_points


def biodiversity_rating(mapping: dict[tuple[int, int, int], str]) -> int:
    """Calculate the score for a given mapping input"""
    score = 0
    for (x, y, _), z in mapping.items():
        if z == "#":
            score += 2 ** (y * 5 + x)
    return score


def map_step(
        mapping: dict[tuple[int, int, int], str],
        is_recursive: bool = False,
) -> dict[tuple[int, int, int], str]:
    """Apply one generation of the bug propagation logic"""
    neighbouring_points = []
    next_mapping = {}
    for point in mapping:
        neighbour_count, new_points = neighbour_count_and_new_points(point, mapping, is_recursive)
        if is_recursive:
            neighbouring_points += new_points
        match neighbour_count:
            case 1:
                next_mapping[point] = "#"
            case 2:
                next_mapping[point] = "#" if mapping[point] == "." else "."
            case _:
                next_mapping[point] = "."

    # FIXME: This is annoying duplication. We want to _add_ points adjacent to known points in the original mapping.
    #  We also want to consider those adjacent points _right now_, without adding _their_ adjacent points.
    for point in neighbouring_points:
        neighbour_count, _ = neighbour_count_and_new_points(point, mapping, is_recursive)
        match neighbour_count:
            case 1:
                next_mapping[point] = "#"
            case 2:
                next_mapping[point] = "#" if mapping.get(point, ".") == "." else "."
            case _:
                next_mapping[point] = "."
    return next_mapping


def part1(input_or_none: str | None = None) -> int:
    """
    Repeatedly step through the mapping; returning the biodiversity score of the first mapping to be repeated.

    Due to hashability rules in Python, we need to convert our mapping to a tuple before we can hash it. Ouch.
    """
    seen = set()
    mapping = parse(input_or_none)
    seen_key = tuple(sorted(mapping.items()))

    while seen_key not in seen:
        seen.add(seen_key)
        mapping = map_step(mapping)
        seen_key = tuple(sorted(mapping.items()))

    return biodiversity_rating(mapping)


def part2(input_or_none: str | None = None, minutes: int = 200) -> int:
    """
    Extend the above to encompass recursive layers. We will need:
    1. To handle depth (i.e. we go from (x, y) to (x, y, z)).
    2. To handle adjacency rules (for cases where we recurse up/down).
    3. Handle the above without blowing up the size of our problem.
    """
    mapping = parse(input_or_none)
    del mapping[(2, 2, 0)]

    for _ in range(minutes):
        mapping = map_step(mapping, is_recursive=True)

    return list(mapping.values()).count("#")


if __name__ == "__main__":
    assert part1() == 18401265
    assert part2(EXAMPLE2, minutes=10) == 99
    assert part2() == 2078
