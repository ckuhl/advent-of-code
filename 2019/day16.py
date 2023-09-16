import itertools


def pattern(idx: int):
    """Lazy generator of the expected pattern"""
    base = (0, 1, 0, -1)
    return itertools.cycle([x for x in base for _ in range(idx)])


def fft_phase(input_signal: list[int]) -> list[int]:
    """Calculate the full iteration."""
    ct = len(input_signal)
    output_signal = [0] * ct

    for i in range(ct):
        p = pattern(i + 1)
        next(p)

        for j, k in zip(input_signal, p):
            output_signal[i] += j * k

    return [int(x[-1]) for x in map(str, output_signal)]


def fft(signal: list[int], iterations: int) -> list[int]:
    """nb. This is slow. But it works. And it only needs to run once."""
    for _ in range(iterations):
        signal = fft_phase(signal)
    return signal


def part1(formatted_input: str | None = None, iterations: int = 100) -> str:
    """This part can be brute-forced. Let's do so."""
    formatted_input = [int(x) for x in formatted_input or open(f"./input/day16.txt").read().strip()]
    signal = fft(formatted_input, iterations)
    return "".join([str(x) for x in signal[:8]])


def part2(formatted_input: str | None = None):
    """
    This part cannot be brute-forced. Alas.
    """
    raise NotImplementedError


if __name__ == "__main__":
    assert part1("80871224585914546619083218645595") == "24176176"
    assert part1("19617804207202209144916044189917") == "73745418"
    assert part1("69317163492948606335995924319873") == "52432133"
    assert part1() == "94935919"
    print(part2())
