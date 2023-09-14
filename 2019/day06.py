from collections import defaultdict


def load() -> list[str]:
    return open(f"./input/day06.txt").readlines()


test_input = ['COM)B', 'B)C', 'C)D', 'D)E', 'E)F', 'B)G', 'G)H', 'D)I', 'E)J', 'J)K', 'K)L']

test_input2 = ['COM)B', 'B)C', 'C)D', 'D)E', 'E)F', 'B)G', 'G)H', 'D)I', 'E)J', 'J)K', 'K)L', 'K)YOU', 'I)SAN']


def parse_input(ls: list[str]) -> dict[str, list[str]]:
    orbits = defaultdict(list)
    for orbit in ls:
        parent, child = orbit.strip().split(")")
        orbits[parent].append(child)
    return orbits


def sub_orbits(orbit: str, orbits: dict[str, list[str]], level: int = 0) -> int:
    ct = level
    for child in orbits[orbit]:
        ct += sub_orbits(child, orbits, level + 1)
    return ct


def part1(orbits: dict[str, list[str]]) -> int:
    """
    Key insight:
    - Each object can only orbit one object
    - Thus, added intermediate layer adds one orbit to a leaf node
    - Thus, we're summing the depths of all leaves
    """
    return sub_orbits("COM", orbits)


def is_child(parent: str, leaf: str, orbits: dict[str, list[str]]) -> bool:
    """Given two points, determine if the latter is orbiting directly or indirectly"""
    if leaf in orbits[parent]:
        return True
    else:
        return any(is_child(x, leaf, orbits) for x in orbits[parent])


def common_root(l1: str, l2: str, orbits: dict[str, list[str]], root: str = "COM") -> str:
    """Given two points that may not be orbiting each other, find their common orbital root"""
    for sub in orbits[root]:
        if is_child(sub, l1, orbits) and is_child(sub, l2, orbits):
            return common_root(l1, l2, orbits, sub)
    return root


def count_dist(l1: str, l2: str, orbits: dict[str, list[str]]) -> int | float:
    """Given two points, in which l2 is orbiting l1 directly or indirectly, count the distance"""
    if not orbits[l1]:
        return float("-inf")
    elif l2 in orbits[l1]:
        return 1
    else:
        return 1 + max(count_dist(x, l2, orbits) for x in orbits[l1])


def part2(orbits: dict[str, list[str]]) -> int:
    """
    Key insight:
    - Find the lowest node that has both key leaves as children
    - Distance to each point to midpoint is most-direct
    - Sum distances, subtract two (for orbits of points themselves)
    """
    r = common_root("YOU", "SAN", orbits)
    return count_dist(r, "YOU", orbits) + count_dist(r, "SAN", orbits) - 2


if __name__ == "__main__":
    assert part1(parse_input(test_input)) == 42
    assert part1(parse_input(load())) == 253104

    assert part2(parse_input(test_input2)) == 4
    assert part2(parse_input(load())) == 499
