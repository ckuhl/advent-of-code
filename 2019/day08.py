from collections import Counter
from pathlib import Path


def load() -> list[int]:
    default = open(f"{Path(__file__).stem}.txt").readline().strip()
    return [int(x) for x in default]


WIDTH, HEIGHT = 25, 6


def part1():
    """Insight: At no point do we care about positional data, we only ever care about counts"""
    data = load()
    fewest0 = {0: float("inf")}
    for i in range(0, len(data), WIDTH * HEIGHT):
        c = Counter(data[i:i + WIDTH * HEIGHT])
        if c[0] < fewest0[0]:
            fewest0 = c
    return fewest0[1] * fewest0[2]


def part2(height: int = HEIGHT, width: int = WIDTH, data: list[int] | None = None) -> str:
    """
    Insight: This will be faster if we composite back-to-front; logic is then:
    - Take back
    - for each layer above, overwrite all positions with the above 0 and 1, ignore 2
    """
    if data is None:
        data = load()

    layer_size = width * height
    s = "\n"
    for y in range(height):
        for x in range(width):
            depth = 0
            pos = y * width + x
            pixel = data[depth * layer_size + pos]
            while pixel == 2:
                depth += 1
                pixel = data[depth * layer_size + pos]

            if pixel == 1:
                s += "*"
            else:
                s += " "
        s += "\n"
    return s


if __name__ == "__main__":
    assert part1() == 1485
    assert part2(2, 2, [0, 2, 2, 2, 1, 1, 2, 2, 2, 2, 1, 2, 0, 0, 0, 0]) == "\n *\n* \n"
    assert part2() == """
***  *     **  *  * **** 
*  * *    *  * * *  *    
*  * *    *  * **   ***  
***  *    **** * *  *    
* *  *    *  * * *  *    
*  * **** *  * *  * *    
"""
