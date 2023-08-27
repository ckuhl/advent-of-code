"""FIXME: All of this can be refactored much more nicely"""

problem = "108457-562041"


def parse_range(r: str) -> range:
    return range(*[int(x) for x in r.split("-")])


def is_valid(n: int) -> bool:
    n = str(n)
    has_repeat = False
    for c, d in zip(n, n[1:]):
        if c > d:
            return False
        if c == d and not has_repeat:
            has_repeat = True
    return has_repeat


def part1():
    assert is_valid(122345) is True
    assert is_valid(111123) is True
    assert is_valid(135679) is False
    assert is_valid(111111) is True
    assert is_valid(223450) is False
    assert is_valid(123789) is False
    return sum([is_valid(x) for x in parse_range(problem)])


def is_valid2(n: int) -> bool:
    n = str(n)
    prev, ct = None, 1
    has_double = False
    for c in n:
        if prev is None:
            prev = c
        elif prev > c:
            return False
        elif prev == c:
            ct += 1
        else:
            if ct == 2:
                has_double = True
            prev, ct = c, 1
    if ct == 2:
        # If it happens on the last character
        has_double = True
    return has_double


def part2():
    assert is_valid2(112233) is True
    assert is_valid2(123444) is False
    assert is_valid2(111122) is True
    return sum([is_valid2(x) for x in parse_range(problem)])


if __name__ == "__main__":
    print(part1())
    print(part2())
