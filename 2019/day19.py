from common import IntcodeComputer


def check_beam_pos(x: int, y: int) -> int:
    cpu = IntcodeComputer(f"./input/day19.txt", input_queue=[x, y])
    cpu.computer()
    return cpu.output_queue.pop()


def part1():
    """
    Simple enough; the question before starting is:
    Can the drove move, or do we need one drone per tile?
    """
    beam_impact = 0
    for y in range(0, 50):
        for x in range(0, 50):
            drone_response = check_beam_pos(x, y)
            if drone_response == 1:
                beam_impact += 1
                print("#", end="")
            else:
                print(" ", end="")
        print()
    return beam_impact


def part2():
    """Todo: Solve part 2 once off the plane"""
    raise NotImplementedError


if __name__ == "__main__":
    assert part1() == 186
    print(part2())
