import math
from pathlib import Path


def load() -> list[str]:
    return open(f"{Path(__file__).stem}.txt").readlines()


problem = load()

example1 = """10 ORE => 10 A
1 ORE => 1 B
7 A, 1 B => 1 C
7 A, 1 C => 1 D
7 A, 1 D => 1 E
7 A, 1 E => 1 FUEL""".split()


def process(rule_strings: list[str]) -> dict[str, tuple[int, list[tuple[str, int]]]]:
    """
    Process input strings into a mapping of rules
    """
    dependencies = {}
    rules = {}
    for rule in rule_strings:
        pairs = [x.split(", ") for x in rule.strip().split(" => ")]
        output = pairs[1][0].split()
        inputs = [x.split() for x in pairs[0]]

        rules[output[1]] = (int(output[0]), [(x[1], int(x[0])) for x in inputs])
        dependencies[output[1]] = [x[1] for x in inputs]
    return rules


def used_in_inputs(rules: dict[str, tuple[int, list[tuple[str, int]]]], chemical: str) -> bool:
    """How inefficient. Yuck."""
    for _, v in rules.values():
        for c, _ in v:
            if chemical == c:
                return True
    return False


def replace(
        rules: dict[str, tuple[int, list[tuple[str, int]]]],
        inputs: dict[str, int],
) -> tuple[dict[str, tuple[int, list[tuple[str, int]]]], dict[str, int]]:
    for k in inputs:
        if not used_in_inputs(rules, k):
            increment, new_inputs = rules.pop(k)
            needed = inputs.pop(k)

            # Gotta round up at this point
            multiplier = math.ceil(needed / increment)
            for i, count in new_inputs:
                inputs[i] = inputs.get(i, 0) + count * multiplier

            return rules, inputs


def part1(problem_string=problem, fuel_needed: int = 1) -> int:
    """
    1. Simplify: Combine like (this could also be done in a dict)
    2. Replace: Search for a rule that can replace some part of the existing inputs:
        2.1. A rule can replace some part of the existing inputs if:
            The part of the inputs is not itself an input to any other existing rule.
        2.2. If the rule produces more than needed, round up.
    """
    rules = process(problem_string)
    inputs = {"FUEL": fuel_needed}
    while set(inputs.keys()) != {"ORE"}:
        rules, inputs = replace(rules, inputs)
    return inputs["ORE"]


def part2():
    """
    Lazy approach: We know that to get 1 fuel, we need 1_582_325 ore. We can do a bisect to get closer.

    We know _roughly_ how much we want; 1:1_582_325 ratio should get us in the ballpark.
    We can use that ratio to estimate starting value, and then use half that starting value as a starting step.
    If we can add the step and stay under, do so;
    If we add the step and go over, halve the step and try again.
    When the step is one, we're done.
    """
    maximum_ore = 1_000_000_000_000

    initial_value = int(maximum_ore / part1())
    step = int(initial_value / 2)
    curr_guess = initial_value + step

    ore_used = 0
    while ore_used < maximum_ore or step != 1:
        ore_used = part1(fuel_needed=curr_guess)
        if ore_used < maximum_ore:
            curr_guess += step
        else:
            curr_guess -= step
            step //= 2
    else:
        # Since we only change the size of the step when "stepping back", we reverse that here
        curr_guess += step

    return curr_guess


if __name__ == "__main__":
    assert part1() == 1_582_325
    assert part2() == 2_267_486, part2()
