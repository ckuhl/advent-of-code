import sys

from common import IntcodeComputer

# FIXME: Yup, still gotta fix this
sys.setrecursionlimit(10_000)


class Nic:
    def __init__(self, address: int):
        self.cpu = IntcodeComputer(f"./input/day23.txt", input_queue=[address])

    def get_messages(self) -> list[tuple[int, int, int]]:
        messages = []
        wip = []
        for i in self.cpu.output_queue:
            wip.append(i)
            if len(wip) == 3:
                messages.append(tuple(wip))
                wip = []
        self.cpu.output_queue = []
        return messages

    def provide_message(self, msg: tuple[int, int]) -> None:
        self.cpu.input_queue.append(msg[0])
        self.cpu.input_queue.append(msg[1])

    def run(self):
        if not self.cpu.input_queue:
            self.cpu.input_queue.append(-1)
        self.cpu.computer()


class Router:
    def __init__(self, with_nat: bool = False):
        self.computers: dict[int, Nic] = {x: Nic(x) for x in range(50)}
        self.message_queue: list[tuple[int, int, int]] = []

        self.with_nat = with_nat
        self._nat_message: tuple[int | None, int | None] = None, None
        self._last_delivered: tuple[int | None, int | None] = None, None

    def collect_messages(self) -> int | None:
        for nic in self.computers.values():
            for message in nic.get_messages():
                if message[0] != 255:
                    self.message_queue.append(message)
                elif self.with_nat:
                    # Part 2: With NAT, save message for idle period
                    self._nat_message = message[1:]
                else:
                    # Part 1: No NAT, return Y value sent to 255
                    return message[2]
        return None

    def distribute_messages(self) -> int or None:
        if self.message_queue:
            for message in self.message_queue:
                self.computers[message[0]].provide_message(message[1:])
            self.message_queue = []
            return None
        elif self._last_delivered[1] == self._nat_message[1]:
            return self._nat_message[1]
        else:
            self._last_delivered = self._nat_message
            self.computers[0].provide_message(self._nat_message)
            return None

    def simulate_step(self) -> None:
        for nic in self.computers.values():
            nic.run()
        return None

    def run(self) -> int:
        result = None
        while not result:
            result = result or self.distribute_messages()
            self.simulate_step()
            result = result or self.collect_messages()
        return result


def part1() -> int:
    """
    The problem states that the computers will run without necessarily waiting for input.
    Since they don't need to care about order, we can simply... run them one at a time.
    """
    return Router(with_nat=False).run()


def part2():
    """
    Twist! Now we need memory!
    Note that we can check if all computers are idle by checking if we have any messages to distribute.
    Then we need to track the current NAT message and the previous NAT message
    """
    return Router(with_nat=True).run()


if __name__ == "__main__":
    assert part1() == 27182
    assert part2() == 19285
