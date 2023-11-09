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
    """FIXME: Part 1 could be rewritten using part 2"""
    return manipulate_deck().index(2019)


def linear_function(s: str) -> tuple[int, int]:
    if s.startswith("deal into new stack"):
        return -1, -1
    elif s.startswith("cut "):
        cut_size = int(s.split(" ")[-1])
        return 1, -cut_size
    elif s.startswith("deal with increment"):
        increment = int(s.split(" ")[-1])
        return increment, 0
    else:
        raise NotImplementedError(f"Unknown action {s=}")


def get_sequence(string_or_default: str | None = None):
    return [linear_function(x) for x in parse(string_or_default)]


def compose(first: tuple[int, int], second: tuple[int, int], mod: int) -> tuple[int, int]:
    """
    Compose two linear functions:
    First: (a, b)
    => ax + b mod n
    Second: (c, d)
    => cx + d mod n
    => c(ax + b) + d mod n
    => acx + bc + d mod n
    => (ac mod n, bc+d mod n)
    """
    a, b = first
    c, d = second
    return (a * c) % mod, (b * c + d) % mod


def compose_sequence(sequence: list[tuple[int, int]], mod: int) -> tuple[int, int]:
    """Now recursively compose these functions together"""
    first = sequence[0]
    for second in sequence[1:]:
        first = compose(first, second, mod)
    return first


def modular_inverse(original: tuple[int, int], mod: int) -> tuple[int, int]:
    """Shoutout Python for making this easy with negative modular powers"""
    a, b = original
    a_inv = pow(a, -1, mod)
    return a_inv, (-b * a_inv) % mod


def modular_exponentiate(original: tuple[int, int], mod: int, iterations: int) -> tuple[int, int]:
    """
    This one twisted my brain for a while. Answer written up in part 2 docstring.
    """
    a, b = original
    a_n = pow(a, iterations, mod)
    b_n = (a_n - 1) * pow(a - 1, mod - 2, mod) * b
    return a_n, b_n


def part2(
        string_or_default: str | None = None,
        deck_size: int = 119_315_717_514_047,
        iterations: int = 101_741_582_076_661,
        position: int = 2_020,
) -> int:
    """FIXME: Part 2 should be rewritten to use a modular function class with convenience methods within"""
    """
    So unlike part 1, here we _do_ want the card at a given position.
    This works in our favour - we don't need to track where all the cards are.
    We want the position of only one card.

    Observe: Both the number of iterations and our deck size are prime. Perhaps there's something here we can work with.

    Also observe: All deck manipulations are linear transforms of the deck. Combining this with the above, we realize
    that this is all leading towards modular arithmetic.

    Let's look back at part 1 and rewrite our three functions in a modular form:
    f(x) = ax + b mod c, where:
        x is the initial card position
        a, b are variables
        c is the size of the deck

    So we can rewrite our actions as linear transforms:
    - Deal: a = -1, b = -1:       -x -        1 mod c
    - Cut:  a =  1, b = -cut_size: x - cut_size mod c
    - Deal with increment: a = increment_size, b = 0: increment_size * x + 0 mod c
    """
    operations = get_sequence(string_or_default)
    """
    Using these we can follow our index over one iteration.
    """
    manipulate = compose_sequence(operations, deck_size)
    """
    We need to invert this function, as we want to find the _value at an index_; this is where our primes above
    come in handy. For this step, we use the power of Wikipedia to refresh my memory from university.
    """
    reverse_manipulate = modular_inverse(manipulate, deck_size)
    """

    Further, we can compose these to create _one_ function to immediately give us our index at the next step.
    Writing out a few steps by hand, we see:
        f^1(x)       = f(x)     = ax+b mod m                   = a^1x + b mod m
        f^2(x)    = f(f(x))   = a(ax+b mod m)+b mod m          = a^3x + (a^2+a+1)b mod m
        f^3(x) = f(f(f(x))) = a(a(ax+b mod m)+b mod m)+b mod m = a^2x + (a+1)b mod m
    Thus we can generalize this!
    f^n = a^nx + (a^{n-1} + a^{n-2} + ... + a + 1)b mod m 
    """
    a, b = modular_exponentiate(reverse_manipulate, deck_size, iterations)
    """
    Finally, we apply our generated function to the inputted card position.
    """
    return (a * position + b) % deck_size


if __name__ == "__main__":
    assert Table(list(range(10))).cut_n(3).deck == [3, 4, 5, 6, 7, 8, 9, 0, 1, 2]
    assert Table(list(range(10))).cut_n(-4).deck == [6, 7, 8, 9, 0, 1, 2, 3, 4, 5]
    assert Table(list(range(10))).deal_with_increment_n(3).deck == [0, 7, 4, 1, 8, 5, 2, 9, 6, 3]
    assert manipulate_deck(EXAMPLE1, 10) == [0, 3, 6, 9, 2, 5, 8, 1, 4, 7]
    assert manipulate_deck(EXAMPLE2, 10) == [3, 0, 7, 4, 1, 8, 5, 2, 9, 6]
    assert manipulate_deck(EXAMPLE3, 10) == [6, 3, 0, 7, 4, 1, 8, 5, 2, 9]
    assert manipulate_deck(EXAMPLE4, 10) == [9, 2, 5, 8, 1, 4, 7, 0, 3, 6]

    assert part1() == 6431
    assert part2() == 100_982_886_178_958
