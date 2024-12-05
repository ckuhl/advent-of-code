import unittest


def load_map(
    filename: str,
) -> dict[tuple[int, int], str]:
    with open(filename, "r") as f:
        lines = f.readlines()
    return {(x, y): c for y, line in enumerate(lines) for x, c in enumerate(line)}


def check_xmas(
    mapping: dict[tuple[int, int], str],
    start: tuple[int, int],
    dx: tuple[int, int],
) -> bool:
    """Check if, for a given point and direction, the string `XMAS` occurs"""
    for i, c in enumerate("XMAS"):
        pt = (start[0] + dx[0] * i, start[1] + dx[1] * i)
        if mapping.get(pt) != c:
            return False
    return True


def xmas_count(
    mapping: dict[tuple[int, int], str],
    point: tuple[int, int],
) -> int:
    """Count the number of times the string `XMAS` occurs, in any direction, from one point"""
    offsets = ((-1, -1), (0, -1), (1, -1), (-1, 0), (1, 0), (-1, 1), (0, 1), (1, 1))
    return sum(check_xmas(mapping, point, x) for x in offsets)


def part1(
    problem_input: dict[tuple[int, int], str],
) -> int:
    return sum(xmas_count(problem_input, x) for x in problem_input)


def check_x_mas(
    mapping: dict[tuple[int, int], str],
    pt: tuple[int, int],
) -> bool:
    """
    Key insight: in short, an X-MAS is when:
    1. You have an `A` in the middle,
    2. All corners are `M` or `S`, and
    3. Opposite corners don't match.
    """
    x, y = pt
    if mapping[pt] != "A":
        return False

    nw = mapping.get((x - 1, y - 1))
    if nw not in ("M", "S"):
        return False

    ne = mapping.get((x + 1, y - 1))
    if ne not in ("M", "S"):
        return False

    sw = mapping.get((x - 1, y + 1))
    if sw not in ("M", "S"):
        return False

    se = mapping.get((x + 1, y + 1))
    if se not in ("M", "S"):
        return False

    if nw == se or sw == ne:
        return False
    return True


def part2(
    problem_input: dict[tuple[int, int], str],
) -> int:
    return sum(check_x_mas(problem_input, x) for x in problem_input)


class Problem04(unittest.TestCase):
    def setUp(self) -> None:
        self.example_input = load_map("inputs/04-example.txt")
        self.problem_input = load_map("inputs/04.txt")

    def test_part1_example(self):
        self.assertEqual(18, part1(self.example_input))

    def test_part1_problem(self):
        self.assertEqual(2468, part1(self.problem_input))

    def test_part2_example(self):
        self.assertEqual(9, part2(self.example_input))

    def test_part2_problem(self):
        self.assertEqual(1864, part2(self.problem_input))
