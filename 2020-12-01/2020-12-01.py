TARGET = 2020


def part1():
    numbers = {int(x) for x in open('2020-12-01.txt')}
    duals = {TARGET - x for x in numbers}

    first, second = numbers.intersection(duals)

    print(f'{first} * {second} = {first * second}')


def part2():
    numbers = [int(x) for x in open('2020-12-01.txt')]

    # Selecting the first item of our three...
    for n, first in enumerate(numbers):
        # ...we search the _rest_ of the list...
        rest = set(numbers[n:])
        # ... for numbers that sum to 2020 - the first number
        dual = {TARGET - first - x for x in rest}

        intersection = rest.intersection(dual)
        if intersection:
            second, third = intersection
            print(f'{first} * {second} * {third} = {first * second * third}')


if __name__ == '__main__':
    part1()
    part2()
