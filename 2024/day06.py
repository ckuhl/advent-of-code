import unittest


def load_input(filename: str) -> list[str]:
    with open(filename, "r") as f:
        return [x.strip() for x in f.readlines()]


def input_to_mapping(problem_input: list[str]) -> dict[tuple[int, int], str]:
    return {(x, y): c for y, line in enumerate(problem_input) for x, c in enumerate(line)}


def find_guard_in_map(mapping: dict[tuple[int, int], str]) -> tuple[int, int] | None:
    for k, v in mapping.items():
        if v in ("^", "<", ">", "v"):
            return k
    return None


def part1(problem_input: list[str]) -> int:
    mapping = input_to_mapping(problem_input)
    guard_pos = find_guard_in_map(mapping)
    directions = {0: (0, -1), 1: (1, 0), 2: (0, 1), 3: (-1, 0)}
    d = 0

    while guard_pos:
        next_pos = guard_pos[0] + directions[d][0], guard_pos[1] + directions[d][1]
        if mapping.get(next_pos) == "#":
            d = (d + 1) % 4
        elif mapping.get(next_pos):
            mapping[guard_pos] = "X"
            mapping[next_pos] = "^"
        else:
            mapping[guard_pos] = "X"
            break
        guard_pos = find_guard_in_map(mapping)

    return sum(map(lambda x: x == "X", mapping.values()))


def part2(problem_input: list[str]) -> int:
    return +1


class Problem06(unittest.TestCase):
    def setUp(self) -> None:
        self.example_input = load_input("inputs/06-example.txt")
        self.problem_input = load_input("inputs/06.txt")

    def test_part1_example(self):
        self.assertEqual(41, part1(self.example_input))

    def test_part1_problem(self):
        self.assertEqual(5404, part1(self.problem_input))

    def test_part2_example(self):
        self.assertEqual(6, part2(self.example_input))

    def test_part2_problem(self):
        self.assertEqual(-1, part2(self.problem_input))
