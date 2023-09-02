from pathlib import Path

from common import IntcodeComputer, computer


def load() -> list[int]:
    default = open(f"{Path(__file__).stem}.txt").readlines()
    return [int(y) for x in default for y in x.split(",")]


def part1() -> IntcodeComputer:
    state = IntcodeComputer(load(), input_queue=[1])
    return computer(state)


def part2() -> IntcodeComputer:
    state = IntcodeComputer(load(), input_queue=[5])
    return computer(state)


if __name__ == "__main__":
    assert part1().output_queue == [0, 0, 0, 0, 0, 0, 0, 0, 0, 5346030]
    assert part2().output_queue == [513116]
