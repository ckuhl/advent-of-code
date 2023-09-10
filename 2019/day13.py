import sys
from pathlib import Path

from common import IntcodeComputer

# FIXME: We gotta make this less recursive
sys.setrecursionlimit(1_000_000)


def load() -> list[int]:
    default = open(f"{Path(__file__).stem}.txt").readlines()
    return [int(y) for x in default for y in x.split(",")]


def count_blocks(state: IntcodeComputer) -> int:
    """
    Count the number of tiles in the display that are blocks.
    While we could use a clever sum(x == 2 for x...), this works sufficiently well and is understandable.
    """
    count = 0
    for n, i in enumerate(state.output_queue):
        if n % 3 == 2 and i == 2:
            count += 1
    return count


def part1():
    cpu = IntcodeComputer(load())
    cpu.computer()

    return count_blocks(cpu)


def are_blocks_remaining(screen: dict[tuple[int, int], int]) -> bool:
    """Reimplementation of the above; but now we only care that any """
    return 2 in screen.values()


def paddle_posx(screen: dict[tuple[int, int], int]) -> int:
    """
    Return the x-coordinate of the paddle.

    Since the paddle is a single tile wide/high, we can exit early.
    """
    for k, v in screen.items():
        if v == 3:
            return k[0]
    raise NotImplementedError


def ball_posx(screen: dict[tuple[int, int], int]) -> int:
    """
    Return the x-coordinate of the ball.

    Since the ball is a single tile wide/high, we can exit early.
    """
    for k, v in screen.items():
        if v == 4:
            return k[0]
    raise NotImplementedError


def update_screen(cpu: IntcodeComputer) -> dict[tuple[int, int], int]:
    """
    Mapping of (x, y): tile_type

    While this could be a single dictionary comprehension, that feels overwrought.
    """
    screen = {}
    for i in range(0, len(cpu.output_queue), 3):
        screen[(cpu.output_queue[i], cpu.output_queue[i + 1])] = cpu.output_queue[i + 2]
    return screen


def part2():
    """
    Observation: Playing brick break entails keeping the paddle under the ball.
    To break all the blocks is really just to keep the paddle under the ball until there are no blocks left.

    Key insight: It's not clear in the question, but it only outputs _updated_ tiles; not all tiles each iteration
    """
    cpu = IntcodeComputer(load())

    # Set game to free-play
    cpu.memory[0] = 2

    cpu.computer()
    screen = update_screen(cpu)

    while are_blocks_remaining(screen):
        paddle, ball = paddle_posx(screen), ball_posx(screen)

        # Move the paddle to stay under the ball
        if paddle > ball:
            cpu.input_queue.append(-1)
        elif paddle < ball:
            cpu.input_queue.append(1)
        else:
            cpu.input_queue.append(0)

        # Clear the queue so that we don't do extra work updating the screen dict.
        cpu.output_queue = []
        cpu.computer()
        screen.update(update_screen(cpu))

    return screen[(-1, 0)]


if __name__ == "__main__":
    assert part1() == 273
    assert part2() == 13140
