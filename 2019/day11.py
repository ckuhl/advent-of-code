from pathlib import Path

from common import computer, IntcodeComputer, State


def load() -> list[int]:
    default = open(f"{Path(__file__).stem}.txt").readlines()
    return [int(y) for x in default for y in x.split(",")]


class PaintBot:
    def __init__(self):
        """
        Is position an innate characteristic of a robot? No.
        Do I really care? No!
        """
        self.cpu = IntcodeComputer(load())
        self.pos = (0, 0)
        self._direction = 0

    def step(self, panel: int) -> tuple[int, int]:
        """Whenever we step, we:
        1. Add input so the computer can continue;
        2. Run until it outputs and halts waiting for more input; and
        3. Returns the produced output (direction change, paint colour)
        """
        self.cpu.input_queue.append(panel)
        self.cpu = computer(self.cpu)
        return self.cpu.output_queue.pop(), self.cpu.output_queue.pop()

    def turn(self, turn: int):
        """Given a turn direction, update the internal position"""
        if turn == 0:
            disp = -1
        elif turn == 1:
            disp = 1
        else:
            raise NotImplementedError

        self._direction = (self._direction + disp) % 4

    def direction(self):
        """Human / useful output of direction"""
        return {
            0: (0, 1),
            1: (1, 0),
            2: (0, -1),
            3: (-1, 0),
        }[self._direction]

    def forward(self):
        self.pos = self.pos[0] + self.direction()[0], self.pos[1] + self.direction()[1]


def part1(painted_panels: dict[tuple[int, int], int] | None = None):
    """Run the robot until it stops. All spots are black (zero) unless otherwise specified."""
    if painted_panels is None:
        painted_panels = {}

    bot = PaintBot()
    while bot.cpu.state != State.STOPPED:
        dir_change, paint_colour = bot.step(painted_panels.get(bot.pos, 0))
        painted_panels[bot.pos] = paint_colour
        bot.turn(dir_change)
        bot.forward()

    return painted_panels


def part2():
    """
    Run the robot until it stops; start it on a white spot (i.e. 1); display output.
    Due to human frailty when it comes to directions, this had to be rotated, hence the inverted loop axes.
    """
    panels = part1({(0, 0): 1})
    s = "\n"
    for y in range(0, 6):
        for x in range(1, 41):
            s += "*" if panels[(x, -y)] else " "
        s += "\n"
    return s


if __name__ == "__main__":
    assert len(part1()) == 2016
    assert part2() == """
***   **  ***  ***   **  ***  ***  *  * 
*  * *  * *  * *  * *  * *  * *  * *  * 
*  * *  * *  * *  * *    ***  *  * **** 
***  **** ***  ***  *    *  * ***  *  * 
* *  *  * *    * *  *  * *  * *    *  * 
*  * *  * *    *  *  **  ***  *    *  * 
"""
