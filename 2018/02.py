from collections import Counter

example_input = """
abcdef
bababc
abbcde
abcccd
aabcdd
abcdee
ababab
"""

example_input2 = """
abcde
fghij
klmno
pqrst
fguij
axcye
wvxyz
"""

with open("inputs/02.txt", "r") as f:
    problem_input = f.read()

def part_1(problem_input):
    counted_input = [Counter(x) for x in problem_input.split()]
    two_letter_count = filter(lambda x: 2 in x.values(), counted_input)
    three_letter_count = filter(lambda x: 3 in x.values(), counted_input)
    return len(list(two_letter_count)) * len(list(three_letter_count))

def part_2(problem_input):
    """
    Sneaky bit: We want to avoid matching a string against itself, for example
    if it has a repeated character so that two substrings of it will be the
    same.
    """
    seen = set()
    for line in problem_input.split():
        line_seen = set()
        for i in range(len(line)):
            sub_id = line[:i] + line[i + 1:]
            if sub_id in seen:
                return sub_id
            else:
                line_seen.add(sub_id)
        seen = seen.union(line_seen)
    raise RuntimeError("No lines found matching")

if __name__ == "__main__":
    assert part_1(example_input) == 12
    assert part_1(problem_input) == 7808
    assert part_2(example_input2) == "fgij"
    assert part_2(problem_input) == "efmyhuckqldtwjyvisipargno"

