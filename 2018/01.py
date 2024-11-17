with open("inputs/01.txt", "r") as f:
    problem_input = f.read()

def parse_input(pi):
    pi = pi.split()
    pi = [int(x) for x in pi]
    return pi

def part_1(pi):
    parsed: list[int] = parse_input(pi)
    return sum(parsed)

def part_2(pi):
    parsed: list[int] = parse_input(pi)
    seen = {0}

    index = 0
    next_frequency = parsed[index % len(parsed)]
    while next_frequency not in seen:
        seen.add(next_frequency)
        index +=1
        next_frequency += parsed[index % len(parsed)]

    return next_frequency

if __name__ == "__main__":
    assert part_1("+1\n-2\n+3\n+1\n") == 3
    assert part_1("+1\n+1\n+1\n") == 3
    assert part_1("+1\n+1\n-2\n") == 0
    assert part_1("-1\n-2\n-3\n") == -6
    assert part_1(problem_input) == 585

    assert part_2("+1\n-2\n+3\n+1") == 2
    assert part_2("+1\n-1") == 0
    assert part_2("+3\n+3\n+4\n-2\n-4") == 10
    assert part_2("-6\n+3\n+8\n+5\n-6") == 5
    assert part_2("+7\n+7\n-2\n-7\n-4") == 14
    assert part_2(problem_input) == 83173

