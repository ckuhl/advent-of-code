import unittest


def read_input(filename: str) -> list[list[int]]:
    """
    Helper: Read in the input files to a list of list of integers:
    Input:
    >>> example = "example.txt"
    1 2 3 4 5
    6 7 8 9 0
    >>> read_input(example)
    [[1, 2, 3, 4, 5], [6, 7, 8, 9, 0]]
    """
    with open(filename, "r") as f:
        return [list(map(int, line.split())) for line in f.readlines()]


def is_safe(report: list[int]) -> bool:
    """
    A safe report is either monotonically increasing or decreasing, with successive levels neither identical nor
    differing by more than three.
    """
    differences = [x - y for x, y in zip(report[:-1], report[1:])]
    if all(map(lambda x: 0 < x < 4, differences)):
        return True
    elif all(map(lambda x: 0 > x > -4, differences)):
        return True
    else:
        return False


def part1(report_list: list[list[int]]) -> int:
    return sum([is_safe(report) for report in report_list])


def part2(report_list: list[list[int]]) -> int:
    safe_reports = 0
    for report in report_list:
        for i in range(len(report)):
            dampened_report = report[:i] + report[i + 1 :]
            if is_safe(dampened_report):
                safe_reports += 1
                break
    return safe_reports


class Problem02(unittest.TestCase):
    def setUp(self) -> None:
        self.example_input = read_input("inputs/02-example.txt")
        self.problem_input = read_input("inputs/02.txt")

    def test_part1_example(self):
        self.assertEqual(2, part1(self.example_input))

    def test_part1_problem(self):
        self.assertEqual(549, part1(self.problem_input))

    def test_part2_example(self):
        self.assertEqual(4, part2(self.example_input))

    def test_part2_problem(self):
        self.assertEqual(589, part2(self.problem_input))
