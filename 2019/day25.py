import sys

from common import IntcodeComputer

# FIXME: Yup, still gotta fix this
sys.setrecursionlimit(10_000_000)

cpu = IntcodeComputer(program="./input/day25.txt")


def part1():
    """
    Part 1: Pick up items all over.

    Knapsack problem with unknown weights and unknown limit!
    Take: Semiconductor + Candy Cane + Food Ration + Coin + Mouse
    Answer: 100667393
    """
    while True:
        cpu.computer()
        message = "".join(chr(x) for x in cpu.output_queue)
        print(message)
        cpu.output_queue = []
        cpu.input_queue = [ord(x) for x in input()] + [ord("\n")]


def part2():
    """TBD"""
    raise NotImplementedError


if __name__ == "__main__":
    part1()
    part2()
