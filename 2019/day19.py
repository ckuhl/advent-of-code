from common import IntcodeComputer


def check_beam_pos(x: int, y: int) -> int:
    cpu = IntcodeComputer(f"./input/day19.txt", input_queue=[x, y])
    cpu.computer()
    return cpu.output_queue.pop()


def part1():
    """The drone can't move between runs; so we need to rerun it once for each position. """
    beam_impact = 0
    for y in range(0, 50):
        for x in range(0, 50):
            beam_impact += check_beam_pos(x, y)
    return beam_impact


def segments_overlap(
        segments: list[list[int]],
        height: int,
        width: int,
) -> bool | int:
    """Return True if there are `height` rows, and there are `width` sequential spaces filled in all rows."""
    if len(segments) < height:
        return False

    count = 0
    for n, index in enumerate(zip(*segments)):
        if all(index):
            count += 1
        else:
            count = 0

        if count == width:
            return n - width + 1

    return False


def provide_line(initial_offset: int = 5):
    """
    Generator helper: Efficiently yield successive lines of the beam
    Caveat: This needs some "bootstrapping" as the first few lines have no beam positions.
    This keeps track of where the previous line started and stopped, and scans from each of those to find the new pos's.
    """
    y = initial_offset
    previous_start = 0
    previous_end = None

    while True:
        # Fill the start
        line = [0 for _ in range(previous_start)]

        in_beam = False
        x = previous_start
        while not in_beam:
            drone_response = check_beam_pos(x, y)
            line.append(drone_response)
            if drone_response:
                previous_start = x
                in_beam = True
            x += 1

        # Fill the middle
        if previous_end:
            for i in range(previous_start, previous_end - 1):
                line.append(1)

        # Fill the end
        x = previous_end or x
        while in_beam:
            drone_response = check_beam_pos(x, y)
            line.append(drone_response)
            if not drone_response:
                previous_end = x
                in_beam = False
            x += 1

        yield line
        y += 1


def find_bounding_box_corner(width: int = 100, height: int = 100) -> tuple[int, int]:
    """
    Finds the top left corner of the bounding box of a given size in the tractor beam

    1. Since the beam moves in one direction, we can start each y-scan with the left offset of the previous row and
       scan until the first non-beam value.
    2. We can define each row as an interval - that is to say, a row is [n, m] where n is the first # and m is the last.
    3. The problem is thus: "Find where we first have 10 line segments overlap for 10 sequential steps."
    3.1. *the key is that it is the same segments overlapping for all 10 steps, we can't have a stair-step pattern.
    3.2. So really we want to only track the latest 10 line segments, dropping older ones.

    So we likely want:
    1. A line-segment queue that holds no more than 10 segments.
    2. A function to inspect if the 10 segments overlap for 10 steps.
    3. A way to scan space efficiently (i.e. do not start from 0 each row, but the left of the previous row).

    Further notice:
    - Obviously, we cannot start until we're > 100 rows in.
        - Inspecting the output manually, we can skip the first 50 rows
        - This avoids problems with rows with zero items

    Finally, the stupid insight that took me way too long...
    - If the bottom left and top right corners are in the beam, the top left and bottom right _must_ be there.
    """
    offset = 50  # The offset helps us skip problematic initial lines

    segments = []
    for y, line in enumerate(provide_line(offset), start=offset):
        # First, add the new line
        segments.append(line)

        # If we have more than enough lines, we can drop the old ones
        if len(segments) > height:
            segments.pop(0)

        # We find the top right first, not the bottom left - because there may be a higher box that isn't left-aligned
        # I'm sad for how long it took me to figure this out
        top_right_x = len(segments[0]) - 1 - segments[0][::-1].index(1)

        # Case 1: We don't have enough lines
        # Case 2: The beam right edge is not more than 100 lines from 0
        if len(segments[0]) <= top_right_x or top_right_x <= 100:
            continue
        # if the top right isn't 1, continue
        elif segments[0][top_right_x] == 0:
            continue
        # if the bottom left isn't 1, continue
        elif segments[-1][top_right_x - width + 1] == 0:
            continue
        else:
            return top_right_x - width + 1, y - height + 1


def part2():
    x, y = find_bounding_box_corner()
    return x * 10_000 + y


if __name__ == "__main__":
    assert part1() == 186
    assert part2() == 9231141
