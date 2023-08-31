import dataclasses
import logging

log = logging.getLogger(__name__)
logging.basicConfig(level=logging.DEBUG)


@dataclasses.dataclass
class State:
    memory: list[int]
    ip: int = 0
    # The input queue allows for queuing up inputs to the computer
    #  Useful for running non-interactively
    input_queue: list[int] = dataclasses.field(default_factory=list)

    # The output queue allows for inspecting outputs programmatically
    #  Useful for writing tests
    output_queue: list[int] = dataclasses.field(default_factory=list)

    def read(self, offset: int) -> int:
        try:
            return self.memory[offset]
        except IndexError:
            log.error(f"Tried to read from memory index={offset}")
            raise

    def write(self, offset: int, value: int) -> None:
        """nb. d5: Parameters that are written to will never be in immediate mode"""
        if offset < 0:
            raise IndexError(f"Offset must be positive, got index={offset} while writing value={value}")
        try:
            self.memory[offset] = value
        except IndexError:
            log.error(f"Tried to write value={value} to memory index={offset}")
            raise

    def read_input(self) -> int:
        """Helper: Provide input"""
        if self.input_queue:
            return self.input_queue.pop(0)
        else:
            return int(input("> "))

    def write_output(self, v: int) -> None:
        """Helper: Provide output somewhere"""
        self.output_queue.append(v)

    def opcode(self):
        return self.memory[self.ip] % 100

    def a(self, is_dest=False):
        mode = self.memory[self.ip] // 10000
        value = self.memory[self.ip + 3]
        if mode == 0 and not is_dest:
            value = self.read(value)
        return value

    def b(self, is_dest=False):
        mode = self.memory[self.ip] % 10000 // 1000
        value = self.memory[self.ip + 2]
        if mode == 0 and not is_dest:
            value = self.read(value)
        return value

    def c(self, is_dest=False):
        mode = self.memory[self.ip] % 1000 // 100
        value = self.memory[self.ip + 1]
        if mode == 0 and not is_dest:
            value = self.read(value)
        return value


def op_1(state: State):
    """
    add c, b, a
    load c
    load b
    add b, c
    store a
    """
    state.write(
        state.a(is_dest=True),
        state.c() + state.b(),
    )
    state.ip += 4
    return computer(state)


def op_2(state: State) -> State:
    """
    mult c, b, a:
    load b
    load c
    multiply b, c
    store a
    """
    state.write(
        state.a(is_dest=True),
        state.c() * state.b(),
    )
    state.ip += 4
    return computer(state)


def op_3(state: State) -> State:
    """
    read c
    Read input
    Store in c
    """
    state.write(
        state.c(is_dest=True),
        state.read_input(),
    )

    state.ip += 2
    return computer(state)


def op_4(state: State) -> State:
    """
    write c
    Load c
    Write to output
    """
    state.write_output(state.c())

    state.ip += 2
    return computer(state)


def op_5(state: State) -> State:
    """
    Jump-if-true
    jit c, b
    if c != 0:
        ip = b
    """
    if state.c() != 0:
        state.ip = state.b()
    else:
        state.ip += 3
    return computer(state)


def op_6(state: State) -> State:
    """
    Jump-if-false
    jif c, b
    if c == 0:
        ip = b
    """
    if state.c() == 0:
        state.ip = state.b()
    else:
        state.ip += 3
    return computer(state)


def op_7(state: State) -> State:
    """
    Less than
    lt c, b, a
    if c < b:
        a = 1
    else:
        a = 0
    """
    if state.c() < state.b():
        state.write(state.a(is_dest=True), 1)
    else:
        state.write(state.a(is_dest=True), 0)
    state.ip += 4
    return computer(state)


def op_8(state: State) -> State:
    """
    Equals
    eq c, b, a
    if c == b:
        a = 1
    else:
        a = 0
    """
    if state.c() == state.b():
        state.write(state.a(is_dest=True), 1)
    else:
        state.write(state.a(is_dest=True), 0)
    state.ip += 4
    return computer(state)


def op_99(state: State) -> State:
    """
    Exit computation; since we mutually recurse to run the computer, this means _not_ recurring.

    This is the only non-error exit from the mutual recursion.
    """
    return state


def computer(state: State) -> State:
    """
    Mutually recurse depending on the current value at the instruction pointer (IP).
    """
    log.debug("IP: %s, Opcode: %s", state.ip, state.opcode())
    match state.opcode():
        case 1:
            return op_1(state)
        case 2:
            return op_2(state)
        case 3:
            return op_3(state)
        case 4:
            return op_4(state)
        case 5:
            return op_5(state)
        case 6:
            return op_6(state)
        case 7:
            return op_7(state)
        case 8:
            return op_8(state)
        case 99:
            return op_99(state)
        case int(x):
            raise NotImplementedError(f"Unexpected opcode: {x}, instruction {state.memory[state.ip]}")


if __name__ == "__main__":
    import unittest


    class TestJump(unittest.TestCase):
        def test_jump1(self):
            self.assertEqual(
                computer(State([3, 9, 8, 9, 10, 9, 4, 9, 99, -1, 8], input_queue=[0])).output_queue,
                [0],
            )


    unittest.main()
