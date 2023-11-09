import sys

from common import IntcodeComputer

# FIXME: Yup, still gotta fix this
sys.setrecursionlimit(10_000_000)

cpu = IntcodeComputer(program="./input/day25.txt")

if __name__ == "__main__":
    """
    Pick up all the items that don't stop the game; figure this out through trial and error.

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
