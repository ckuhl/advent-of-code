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
        if _ % 100 == 0:
            print(f"Iteration {_}")
        signal = fft_phase(signal)
    return signal


def part1(formatted_input: str | None = None, iterations: int = 100, offset: int = 0) -> str:
    """This part can be brute-forced. Let's do so."""
    formatted_input = [int(x) for x in formatted_input or open(f"./input/day16.txt").read().strip()]
    signal = fft(formatted_input, iterations)
    return "".join([str(x) for x in signal[offset:offset + 8]])


def get_offset(input_signal: list[int]) -> int:
    return int("".join(str(x) for x in input_signal[0:7]))


def partial_phase(partial_signal: list[int]) -> list[int]:
    """
    We apply a partial of the phase algorithm, assuming:
    * The entire signal we're given is in the second half of the signal, and
    * The signal has been reversed
    """
    output_signal = [partial_signal[0]]
    prev = partial_signal[0]
    for i in partial_signal[1:]:
        prev = (prev + i) % 10
        output_signal.append(prev)
    return output_signal


def part2(formatted_input: str | None = None):
    """
    This part cannot be brute-forced. Alas.
    Insight though:
    # signal_offset  = 5_976_267
    # repeated_input = 6_500_000

    We know we repeat the pattern n times, where n is the offset of each digit. Our signal offset is > 50% of the way
    through the input, which means that we're only dealing with the pattern value only ever being 1.

    So we can simplify our calculation to:
    n_k' = n_k
    n_{k-1}' = (n_k + n_{k-1}) mod 10
    n_{k-2}' = (n_k + n_{k-1} + n_{k-1}) mod 10
    ...

    We can further save effort by reversing the signal and working from the last element forward. Since each leftward
    element only adds one more term, and modular arithmetic is congruent, we can "carry forward" each digit's
    computation.
    """
    formatted_input = [int(x) for x in formatted_input or open(f"./input/day16.txt").read().strip()]
    offset = get_offset(formatted_input)
    # We only care about our signal and proceeding
    relevant_signal = (formatted_input * 10_000)[offset:]
    relevant_signal.reverse()
    for _ in range(100):
        relevant_signal = partial_phase(relevant_signal)
    relevant_signal.reverse()
    return "".join(str(x) for x in relevant_signal[:8])


if __name__ == "__main__":
    assert part1("80871224585914546619083218645595") == "24176176"
    assert part1("19617804207202209144916044189917") == "73745418"
    assert part1("69317163492948606335995924319873") == "52432133"
    assert part1() == "94935919"
    assert part2() == "24158285"
