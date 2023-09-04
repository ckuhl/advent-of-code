import itertools
from pathlib import Path

from common import IntcodeComputer, computer, State


def load() -> list[int]:
    default = open(f"{Path(__file__).stem}.txt").readlines()
    return [int(y) for x in default for y in x.split(",")]


part2_example1 = [
    3, 26, 1001, 26, -4, 26, 3, 27, 1002, 27, 2, 27, 1, 27, 26, 27, 4, 27, 1001, 28, -1, 28, 1005, 28, 6, 99, 0, 0, 5,
]


def amplifier(program: list[int], phase: int, input_signal: int) -> int:
    state = IntcodeComputer(program, input_queue=[phase, input_signal])
    state = computer(state)
    return state.output_queue.pop()


def amplify(program: list[int], phase_order: list[int], input_signal=0) -> int:
    if phase_order:
        return amplify(
            program,
            phase_order[1:],
            input_signal=amplifier(program, phase_order[0], input_signal),
        )
    else:
        return input_signal


def part1():
    m = 0
    for order in itertools.permutations(range(5), 5):
        new = amplify(load(), order)
        if new > m:
            m = new
    return m


def part2():
    """
    Insight(s):
    - The input for one is now the output for the next
    - We need to block on waiting for input
    - We could get all multiprocessing, but likely it would be easier to go loop-y
    """
    best_signal = 0
    for phase_order in itertools.permutations(range(5, 10), 5):
        computers = [IntcodeComputer(load(), input_queue=[x]) for x in phase_order]
        current_signal = 0
        while not any([x.state == State.STOPPED for x in computers]):
            for n, c in enumerate(computers):
                c.input_queue.append(current_signal)
                run = computer(c)
                computers[n] = run
                current_signal = run.output_queue.pop()

        if current_signal > best_signal:
            best_signal = current_signal

    return best_signal


if __name__ == "__main__":
    assert part1() == 225056
    assert part2() == 14260332
