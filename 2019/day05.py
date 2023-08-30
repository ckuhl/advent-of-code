from pathlib import Path

from common import State, computer


def load() -> list[int]:
    default = open(f"{Path(__file__).stem}.txt").readlines()
    return [int(y) for x in default for y in x.split(",")]


def part1() -> None:
    state = State(load(), input_queue=[1])
    computer(state)


if __name__ == "__main__":
    part1()  # 5346030 (should we assert on this?)
