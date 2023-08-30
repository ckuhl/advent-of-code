from common import State, computer


def load():
    default = open("day02.txt").readlines()
    return [int(y) for x in default for y in x.split(",")]


def part1(noun: int = 12, verb: int = 2) -> int:
    state = State(load())
    state.write(1, noun)
    state.write(2, verb)
    state = computer(state)
    return state.read(0)


def part2():
    for n in range(99):
        for v in range(99):
            if part1(n, v) == 19690720:
                return 100 * n + v


if __name__ == "__main__":
    assert part1() == 3101844
    assert part2() == 8478
