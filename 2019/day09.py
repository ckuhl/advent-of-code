from pathlib import Path

from common import IntcodeComputer


def load() -> list[int]:
    default = open(f"{Path(__file__).stem}.txt").readlines()
    return [int(y) for x in default for y in x.split(",")]


def part1():
    prog = IntcodeComputer(load(), input_queue=[1])
    return prog.computer().output_queue


def part2():
    """
    RecursionError: maximum recursion depth exceeded; uh oh, time to refactor.
    Mangling the system recursion limit works but it doesn't feel satisfying...
    """
    prog = IntcodeComputer(load(), input_queue=[2])
    import sys
    limit = sys.getrecursionlimit()
    sys.setrecursionlimit(1_000_000)
    result = prog.computer().output_queue
    sys.setrecursionlimit(limit)
    return result


if __name__ == "__main__":
    assert part1() == [2662308295]
    assert part2() == [63441]
