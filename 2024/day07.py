import unittest


def load_input(filename: str) -> list[str]:
    with open(filename, "r") as f:
        return f.readlines()


def parse_line(line: str) -> tuple[int, list[int]]:
    left, rest = line.split(":")
    return int(left), list(map(int, rest.split()))


def is_solvable(result: int, actions: list[int]) -> bool:
    """
    For part 1, I am being sneaky and working through this backward.

    We multiply and add left-to-right.
    So we can divide and subtract right-to-left.
    We can only divide if it is evenly divisible, but we can always subtract.
    """
    if result < 0:
        # Short circuit, we can't get negative numbers since all inputs are positive
        return False
    elif len(actions) == 1:
        return result == actions[0]
    elif result % actions[-1] == 0:
        return (
            is_solvable(result // actions[-1], actions[:-1])
            or is_solvable(result - actions[-1], actions[:-1])
        )
    else:
        return is_solvable(result - actions[-1], actions[:-1])


def part1(problem_input: list[str]) -> int:
    valid_sum = 0
    for result, steps in map(parse_line, problem_input):
        if is_solvable(result, steps):
            valid_sum += result
    return valid_sum


def is_cat_solvable(result: int, carry: int, actions: list[int]) -> bool:
    """
    We multiply and add left-to-right.
    So we can divide and subtract right-to-left.
    We can only divide if it is evenly divisible, but we can always subtract.
    """
    if not actions:
        return carry == result
    elif carry > result:
        return False
    cat_carry = int(str(carry) + str(actions[0]))

    return (
        is_cat_solvable(result, carry * actions[0], actions[1:])
        or is_cat_solvable(result, carry + actions[0], actions[1:])
        or is_cat_solvable(result, cat_carry, actions[1:])
    )


def part2(problem_input: list[str]) -> int:
    """
    It seems like concatenation is mostly a matter of substitution - replacing two digits with one.
    But since we get the list of all inputs, we can choose to fork at each step. I guess?
    """
    valid_sum = 0
    for result, steps in map(parse_line, problem_input):
        if is_cat_solvable(result, steps[0], steps[1:]):
            valid_sum += result
    return valid_sum


class Problem07(unittest.TestCase):
    def setUp(self) -> None:
        self.example_input = load_input("inputs/07-example1.txt")
        self.problem_input = load_input("inputs/07.txt")

    def test_part1_example(self):
        self.assertEqual(3_749, part1(self.example_input))

    def test_part1_problem(self):
        self.assertEqual(1_153_997_401_072, part1(self.problem_input))

    def test_part2_example(self):
        self.assertEqual(11_387, part2(self.example_input))

    def test_part2_problem(self):
        self.assertEqual(97_902_809_384_118, part2(self.problem_input))
