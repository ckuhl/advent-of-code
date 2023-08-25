def load():
    default = open("day01.txt").readlines()
    return [int(x) for x in default]


def fuel_value(n: int) -> int:
    return n // 3 - 2


def fuel_requirement(nl: list[int]) -> int:
    return sum(fuel_value(x) for x in nl)


def part1():
    return fuel_requirement(load())


def recursive_fuel_value(n: int) -> int:
    fuel = fuel_value(n)
    if fuel >= 0:
        return fuel + recursive_fuel_value(fuel)
    else:
        return 0


def recursive_fuel_requirement(nl: list[int]) -> int:
    return sum(recursive_fuel_value(x) for x in nl)


def part2():
    return recursive_fuel_requirement(load())


if __name__ == "__main__":
    print(part1())
    print(part2())
