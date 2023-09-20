import sys

from common import IntcodeComputer

# FIXME: We gotta make this less recursive
sys.setrecursionlimit(1_000_000)


def get_ascii_map() -> str:
    cpu = IntcodeComputer(f"./input/day17.txt")
    cpu = cpu.computer()
    return "".join(chr(x) for x in cpu.output_queue)


example = """..#..........
..#..........
#######...###
#.#...#...#.#
#############
..#...#...#..
..#####...^.."""


def part1(map_string: str) -> int:
    array = [[y for y in x] for x in map_string.split()]
    alignment_parameter_score = 0
    for y, row in enumerate(array[1:-1]):
        for x, char in enumerate(row[1:-1]):
            if "#" == array[y][x] == array[y][x - 1] == array[y][x + 1] == array[y - 1][x] == array[y + 1][x]:
                alignment_parameter_score += x * y
    return alignment_parameter_score


def part2():
    """
    Why yes, this is a manual transcription of the scaffolding:

    L,8,R,10,L,8,R,8,L,12,R,8,R,8,L,8,R,10,L,8,R,8,L,8,R,6,R,6,R,10,L,8,L,8,R,6,R,6,R,
    10,L,8,L,8,R,10,L,8,R,8,L,12,R,8,R,8,L,8,R,6,R,6,R,10,L,8,L,12,R,8,R,8,L,12,R,8,R,8,

    And then yes again, that is a manual solution for the problem.
    Sometimes you'll spend more time automating a throwaway problem than doing it by hand. This isn't a good thing.
    """
    main_routine = "C,B,C,A,A,C,B,A,B,B\n"
    function_a = "L,8,R,6,R,6,R,10,L,8\n"
    function_b = "L,12,R,8,R,8\n"
    function_c = "L,8,R,10,L,8,R,8\n"

    robot = IntcodeComputer(f"./input/day17.txt")
    robot.memory[0] = 2
    robot.computer()
    for input_string in (main_routine, function_a, function_b, function_c, "n\n"):
        robot.input_queue = [ord(x) for x in input_string]
        robot.computer()
    robot.computer()
    return robot.output_queue[-1]


if __name__ == "__main__":
    assert part1(example) == 76
    assert part1(get_ascii_map()) == 6680
    assert part2() == 1_103_905
