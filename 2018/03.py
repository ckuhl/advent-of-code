import collections
import re


def get_claims(problem_input):
    claims = collections.defaultdict(list)

    for line in problem_input.strip().split("\n"):
        num, x1, y1, w, h = map(int, re.findall("[0-9]+", line))
        for x in range(x1, x1 + w):
            for y in range(y1, y1 + h):
                claims[(x, y)] = claims[(x, y)] + [num]
    return claims


def part_1(problem_input):
    claims = get_claims(problem_input)
    return len([k for k, v in claims.items() if len(v) > 1])


def part_2(problem_input):
    claims = get_claims(problem_input)
    overlapping, nonoverlapping = set(), set()
    for _, v in claims.items():
        if len(v) == 1:
            nonoverlapping.add(v[0])
        else:
            for i in v:
                overlapping.add(i)

    return (nonoverlapping - overlapping).pop()

if __name__ == "__main__":
    example_input = """#1 @ 1,3: 4x4
    #2 @ 3,1: 4x4
    #3 @ 5,5: 2x2"""
    with open("inputs/03.txt", "r") as f:
        problem_input = f.read()

    assert part_1(example_input) == 4
    assert part_1(problem_input) == 109716
    assert part_2(example_input) == 3
    assert part_2(problem_input) == 124

