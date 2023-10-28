import dataclasses

EXAMPLE1 = """deal with increment 7
deal into new stack
deal into new stack"""

EXAMPLE2 = """cut 6
deal with increment 7
deal into new stack"""

EXAMPLE3 = """deal with increment 7
deal with increment 9
cut -2"""

EXAMPLE4 = """deal into new stack
cut -2
deal with increment 7
cut 8
cut -4
deal with increment 7
cut 3
deal with increment 9
deal with increment 3
cut -1"""


def parse(string_or_default: str | None = None) -> NotImplemented:
    if string_or_default is None:
        with open("./input/day22.txt") as f:
            string = f.readlines()
    else:
        string = string_or_default.split("\n")

    return string


@dataclasses.dataclass
class Table:
    deck: list[int]

    def __post_init__(self):
        self._size = len(self.deck)

    def deal_into_new(self):
        self.deck = self.deck[::-1]
        return self

    def cut_n(self, n: int):
        self.deck = self.deck[n:] + self.deck[:n]
        return self

    def deal_with_increment_n(self, n: int):
        """Initially tried to do this with some clever modulo arithmetic, but it failed for increments of len-1"""
        deck2 = [-1 for _ in range(self._size)]
        for m, i in enumerate(self.deck):
            deck2[(m * n) % self._size] = i
        self.deck = deck2
        return self


def manipulate_deck(
        string_or_default: str | None = None,
        deck_size: int = 10_007,
):
    actions = parse(string_or_default)
    deck = Table(list(range(deck_size)))
    for action in actions:
        if action.startswith("deal into new stack"):
            deck.deal_into_new()
        elif action.startswith("cut "):
            cut_size = int(action.split(" ")[-1])
            deck.cut_n(cut_size)
        elif action.startswith("deal with increment"):
            increment = int(action.split(" ")[-1])
            deck.deal_with_increment_n(increment)
        else:
            raise NotImplementedError(f"Unknown action {action=}")
    return deck.deck


def part1():
    return manipulate_deck().index(2019)


def part2(
        string_or_default: str | None = None,
        deck_size: int = 119_315_717_514_047,
        iterations: int = 101_741_582_076_661,
        position: int = 2_020,
) -> int:
    """
    So unlike part 1, here we _do_ want the card at a given position.
    This works in our favour - we don't need to track where all the cards are.
    We want the position of only one card

    Observe: Each iteration will be the same transform. In short, once could imagine that the cards are no longer
    the cards, but the position of a card once the iteration has completed. In short, if card 0 ends up in position 3
    and card 3 in position 0 after one iteration, after two iterations they will be in their respective place.

    Observe: Both the number of iterations and our deck size are prime. Perhaps there's something here we can work with.

    So we need to reverse the steps:
    - Undeal: (Symmetric)
    - Uncut: Add instead of subtract index
    - Undeal with increment (use Euclidian Algorithm - aha, we can use the primeness of the deck)

    Using this we can follow our index over one iteration.

    Following that: We can likely generalize this up a step to do the same for the number of steps necessary to shuffle.
    """
    raise NotImplementedError


if __name__ == "__main__":
    assert Table(list(range(10))).cut_n(3).deck == [3, 4, 5, 6, 7, 8, 9, 0, 1, 2]
    assert Table(list(range(10))).cut_n(-4).deck == [6, 7, 8, 9, 0, 1, 2, 3, 4, 5]
    assert Table(list(range(10))).deal_with_increment_n(3).deck == [0, 7, 4, 1, 8, 5, 2, 9, 6, 3]
    assert manipulate_deck(EXAMPLE1, 10) == [0, 3, 6, 9, 2, 5, 8, 1, 4, 7]
    assert manipulate_deck(EXAMPLE2, 10) == [3, 0, 7, 4, 1, 8, 5, 2, 9, 6]
    assert manipulate_deck(EXAMPLE3, 10) == [6, 3, 0, 7, 4, 1, 8, 5, 2, 9]
    assert manipulate_deck(EXAMPLE4, 10) == [9, 2, 5, 8, 1, 4, 7, 0, 3, 6]
    assert part1() == 6431
    print(part2())
