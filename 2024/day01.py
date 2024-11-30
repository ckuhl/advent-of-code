import collections
import unittest


def load_input(filename: str) -> list[str]:
    """Helper: Load file from inputs directory, mangle into list of lines"""
    with open(filename, "r") as f:
        return f.readlines()


def construct_lists(problem: list[str]) -> tuple[list[int], list[int]]:
    left_column, right_column = [], []
    for line in problem:
        left_id, right_id = map(int, line.split())
        left_column.append(left_id)
        right_column.append(right_id)
    return left_column, right_column


def part1(problem: list[str]) -> int:
    left, right = construct_lists(problem)
    distances = [abs(x - y) for x, y in zip(sorted(left), sorted(right))]
    return sum(distances)


def part2(problem: list[str]) -> int:
    left, right = construct_lists(problem)
    occurrences = collections.Counter(right)
    return sum([x * occurrences[x] for x in left])


class Problem01(unittest.TestCase):
    def setUp(self) -> None:
        self.example_input = load_input("inputs/01-example.txt")
        self.problem_input = load_input("inputs/01.txt")

    def test_part1_example(self):
        self.assertEqual(part1(self.example_input), 11)

    def test_part1_problem(self):
        self.assertEqual(part1(self.problem_input), 1530215)

    def test_part2_example(self):
        self.assertEqual(part2(self.example_input), 31)

    def test_part2_problem(self):
        self.assertEqual(part2(self.problem_input), 26800609)
