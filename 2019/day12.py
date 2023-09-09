import math
import re

example1 = """<x=-1, y=0, z=2>
<x=2, y=-10, z=-7>
<x=4, y=-8, z=8>
<x=3, y=5, z=-1>
"""

example2 = """<x=-8, y=-10, z=0>
<x=5, y=5, z=10>
<x=2, y=-7, z=3>
<x=9, y=-8, z=-3>
"""

problem = """<x=-6, y=2, z=-9>
<x=12, y=-14, z=-4>
<x=9, y=5, z=-6>
<x=-1, y=-4, z=9>
"""


def parse_system(s: str) -> list[int]:
    """Helper: Load system from string into row"""
    return [int(x.group()) for x in re.finditer(r"-?\d+", s, re.MULTILINE)]


def time_step(
        last_velocity: list[int],
        last_distance: list[int],
) -> tuple[list[int], list[int]]:
    """Simulate a time step; return the next velocity and distance"""
    new_velocity = [0] * 12
    new_distance = [0] * 12

    # Observe: Each velocity is isolated per-axis
    for obj in range(0, 4):
        for axis in range(0, 3):
            # First, the new velocity is the previous velocity, plus...
            new_velocity[obj * 3 + axis] += last_velocity[obj * 3 + axis]

            # ...the gravity between each pair of moons
            # (We can include the moon pulling on itself because the delta will be zero)
            for other in range(0, 4):
                delta = last_distance[other * 3 + axis] - last_distance[obj * 3 + axis]
                if delta != 0:
                    new_velocity[obj * 3 + axis] += int(math.copysign(1, delta))

    # Now we apply gravity to update distances
    for obj in range(0, 4):
        for axis in range(0, 3):
            new_distance[obj * 3 + axis] = last_distance[obj * 3 + axis] + new_velocity[obj * 3 + axis]

    return new_velocity, new_distance


def total_energy(velocities: list[int], distances: list[int]) -> int:
    """Given the distances and velocities, output the total energy in the system"""
    total = 0
    for obj in range(0, 4):
        kinetic, potential = 0, 0
        for axis in range(0, 3):
            kinetic += abs(velocities[obj * 3 + axis])
            potential += abs(distances[obj * 3 + axis])
        total += kinetic * potential
    return total


def part1(system: str = problem, steps: int = 1000) -> int:
    """
    Observation:
    - This is a simple recurrence relation:
        - ∆velocity = previous distance(s)
        - ∆distance = the previous velocity
    """
    # Where distance[3n+{0,1,2}] = the x,y,z position of n
    # and velocity[3n+{0,1,2}] = the above, but for velocity
    distance = parse_system(system)
    velocity = [0 for _ in distance]

    for _ in range(steps):
        velocity, distance = time_step(velocity, distance)

    return total_energy(velocity, distance)


def part2(system: str = problem) -> int:
    """
    As the problem hints; this could run for a long period of time!
    Likely we'll need to optimize:
    - In part 1, we realized that each axis is independent of the others
    - We know that each axis will eventually "loop around" (i.e. end up in its starting place)
    - So if we store each separately, we can
    """
    raise NotImplementedError


if __name__ == "__main__":
    assert part1(example1, steps=10) == 179
    assert part1(example2, steps=100) == 1940
    assert part1() == 14907

    # assert part2(example1) == 2772
    # assert part2(example2) == 4_686_774_924
    # print(part2())
