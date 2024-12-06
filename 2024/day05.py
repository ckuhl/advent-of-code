import unittest
from collections import defaultdict


def load_input(filename: str) -> list[str]:
    with open(filename, "r") as f:
        return [x.strip() for x in f.readlines()]


def process_order_rules(lines: list[str]) -> dict[int, set[int]]:
    """We actually invert this - place the number that _follows_ as the key and any preceding one as the value"""
    rules = defaultdict(set)
    for line in lines:
        first, second = line.split("|")
        rules[int(second)].add(int(first))

    return rules


def preprocess_lines(
    lines: list[str],
) -> tuple[dict[int, [set[int]]], list[list[int]]]:
    split = lines.index("")
    rules = process_order_rules(lines[:split])
    updates = [list(map(int, x.split(","))) for x in lines[split + 1:]]
    return rules, updates,


def is_valid_update(
    rules: dict[int, [set[int]]],
    update: list[int],
) -> bool:
    forbidden_pages = set()
    for page in update:
        if page in forbidden_pages:
            return False
        forbidden_pages = forbidden_pages.union(rules[page])
    return True


def part1(problem_input: list[str]) -> int:
    order_rules, updates = preprocess_lines(problem_input)
    page_count = 0
    for update in updates:
        if is_valid_update(order_rules, update):
            midpoint = (len(update) - 1) // 2
            page_count += update[midpoint]
    return page_count


def part2(problem_input: list[str]) -> int:
    """
    We need to "fix" a page. We can "cheat" and reuse the logic for finding invalid configurations to detect _when_ we
    first encounter an invalid page, and then move it backward one step and try again.
    """
    order_rules, updates = preprocess_lines(problem_input)
    page_count = 0
    for update in updates:
        if is_valid_update(order_rules, update):
            continue

        while not is_valid_update(order_rules, update):
            forbidden_pages = set()
            for i, page in enumerate(update):
                if page in forbidden_pages:
                    update[i], update[i - 1] = update[i - 1], update[i],
                forbidden_pages = forbidden_pages.union(order_rules[page])
        midpoint = (len(update) - 1) // 2
        page_count += update[midpoint]
    return page_count


class Problem04(unittest.TestCase):
    def setUp(self) -> None:
        self.example_input = load_input("inputs/05-example.txt")
        self.problem_input = load_input("inputs/05.txt")

    def test_part1_example(self):
        self.assertEqual(143, part1(self.example_input))

    def test_part1_problem(self):
        self.assertEqual(4662, part1(self.problem_input))

    def test_part2_example(self):
        self.assertEqual(123, part2(self.example_input))

    def test_part2_problem(self):
        self.assertEqual(5900, part2(self.problem_input))
