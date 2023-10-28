import sys

from common import IntcodeComputer

# FIXME: Yup, still gotta fix this
sys.setrecursionlimit(10_000_000)


class SpringDroid:
    def __init__(self):
        self.cpu = IntcodeComputer(program="./input/day21.txt")

    def program(self, program: str) -> None:
        self.cpu.computer()
        self.cpu.output_queue = []
        self.cpu.input_queue = [ord(x) for x in program]

    def outcome(self) -> int:
        """
        After running SpringDroid, provide the outcome of operation.
        Success provides an integer out (the hull damage calculation), failure provides a string detailing the failure.
        """
        if not self.cpu.output_queue:
            raise RuntimeError("SpringDroid has not yet been run!")

        if len(self.cpu.output_queue) >= 15:
            raise ValueError("".join(chr(x) for x in self.cpu.output_queue))
        else:
            return self.cpu.output_queue[-1]


def part1():
    """
    Hmm; we have four binary inputs and one possible output.
    In addition, we have two logical operations.
    This certainly looks like a problem asking for a truth table!

    Looking through a constructed table (in a spreadsheet), we see:
    1. If there is a hole in front of you (A=0), jump immediately.
    2. If there is a hole further out (B=0 || C=0) and a clear spot to land (D=1), jump now.
    3. Otherwise, uh, do nothing.
        3.1. You have 1000 and you can deal with that later.
        3.2. You have 0000 and nothing you do matters.
    """
    sd = SpringDroid()
    sd.program("""NOT B T
NOT C J
OR T J
AND D J
NOT A T
OR T J
WALK
""")
    sd.cpu.computer()
    return sd.outcome()


def part2():
    """
    Though we can see five more spaces, we really only care about one more.
    Why? Because the droid can still only jump four spaces.
    So what we need to think about now is if we can jump _twice_.
    First to D, and then again to H.
    """
    sd = SpringDroid()
    sd.program("""NOT B T
NOT C J
OR T J
AND D J
AND H J
NOT A T
OR T J
RUN
""")
    sd.cpu.computer()
    return sd.outcome()


if __name__ == "__main__":
    assert part1() == 19_351_175
    assert part2() == 1_141_652_864
