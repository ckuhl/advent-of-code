import re
import unittest


def load_input(filename: str) -> list[str]:
    """Helper: Load file from inputs directory, mangle into list of lines"""
    with open(filename, "r") as f:
        return f.readlines()


def part1(problem_input: list[str]) -> int:
    score = 0
    for line in problem_input:
        for match in re.findall(r"mul\((\d+),(\d+)\)", line):
            score += int(match[0]) * int(match[1])
    return score


def part2(problem_input: list[str]) -> int:
    score = 0
    enabled = True
    for line in problem_input:
        instructions = re.findall(r"mul\(\d+,\d+\)|do\(\)|don't\(\)", line)
        for instr in instructions:
            if instr == "do()":
                enabled = True
            elif instr == "don't()":
                enabled = False
            elif instr[:3] == "mul" and enabled:
                first, second = instr[4:-1].split(",")
                score += int(first) * int(second)
    return score


class Problem03(unittest.TestCase):
    def setUp(self) -> None:
        self.example1_input = load_input("inputs/03-example1.txt")
        self.example2_input = load_input("inputs/03-example2.txt")
        self.problem_input = load_input("inputs/03.txt")

    def test_part1_example(self):
        self.assertEqual(161, part1(self.example1_input))

    def test_part1_problem(self):
        self.assertEqual(170_778_545, part1(self.problem_input))

    def test_part2_example(self):
        self.assertEqual(48, part2(self.example2_input))

    def test_part2_problem(self):
        self.assertEqual(82_868_252, part2(self.problem_input))
