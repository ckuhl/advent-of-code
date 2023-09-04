import dataclasses
import enum
import logging

log = logging.getLogger(__name__)
logging.basicConfig(level=logging.DEBUG)


class State(enum.Enum):
    RUNNING = enum.auto()
    STOPPED = enum.auto()
    NEEDS_INPUT = enum.auto()


@dataclasses.dataclass
class IntcodeComputer:
    memory: list[int]

    # Internal pointer, should point to current/next instruction
    ip: int = 0

    # Internal tracker for relative addressing
    relative_base: int = 0

    # The input queue allows for queuing up inputs to the computer
    #  Useful for running non-interactively
    input_queue: list[int] = dataclasses.field(default_factory=list)

    # The output queue allows for inspecting outputs programmatically
    #  Useful for writing tests
    output_queue: list[int] = dataclasses.field(default_factory=list)

    state: State = State.RUNNING

    def read(self, address: int) -> int:
        try:
            return self.memory[address]
        except IndexError:
            if address > 0:
                log.info("Tried to read addr=%s, extending memory by %s", address, address + 1 - len(self.memory))
                self.memory = self.memory + [0] * (address + 1 - len(self.memory))
                return self.memory[address]
            else:
                raise IndexError(f"Tried to read from negative address={address}")

    def write(self, address: int, value: int) -> None:
        try:
            self.memory[address] = value
        except IndexError:
            if address > 0:
                self.memory = self.memory + [0] * (address + 1 - len(self.memory))
                return self.write(address, value)
            else:
                raise IndexError(f"Tried to write value={value} to negative address={address}")

    def read_input(self) -> int:
        """Helper: Provide input"""
        return self.input_queue.pop(0)

    def write_output(self, v: int) -> None:
        """Helper: Provide output somewhere"""
        self.output_queue.append(v)

    def opcode(self):
        return self.memory[self.ip] % 100

    # FIXME: Given the repetition in the below, we should generalize

    def a(self, is_dest=False):
        """Get the third (A) input value by mode"""
        mode = self.memory[self.ip] // 10000
        value = self.memory[self.ip + 3]
        if mode == 2 and is_dest:
            return value + self.relative_base
        elif is_dest:
            return value
        elif mode == 0:
            return self.read(value)
        elif mode == 1:
            return value
        elif mode == 2:
            return self.read(value + self.relative_base)
        else:
            raise NotImplementedError

    def b(self, is_dest=False):
        """Get the second (B) input value by mode"""
        mode = self.memory[self.ip] % 10000 // 1000
        value = self.memory[self.ip + 2]
        if mode == 2 and is_dest:
            return value + self.relative_base
        elif is_dest:
            return value
        elif mode == 0:
            return self.read(value)
        elif mode == 1:
            return value
        elif mode == 2:
            return self.read(value + self.relative_base)
        else:
            raise NotImplementedError

    def c(self, is_dest=False):
        """Get the first (C) input value by mode"""
        mode = self.memory[self.ip] % 1000 // 100
        value = self.memory[self.ip + 1]
        if mode == 2 and is_dest:
            return value + self.relative_base
        elif is_dest:
            return value
        elif mode == 0:
            return self.read(value)
        elif mode == 1:
            return value
        elif mode == 2:
            return self.read(value + self.relative_base)
        else:
            raise NotImplementedError


def op_1(state: IntcodeComputer):
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


def op_2(state: IntcodeComputer) -> IntcodeComputer:
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


def op_3(state: IntcodeComputer) -> IntcodeComputer:
    """
    read c
    Read input
    Store in c

    If we need input and there is none, we will return and wait for more input to be provided
    """
    if not state.input_queue:
        state.state = State.NEEDS_INPUT
        return state

    elif state.state == State.NEEDS_INPUT:
        state.state = State.RUNNING

    state.write(
        state.c(is_dest=True),
        state.read_input(),
    )

    state.ip += 2
    return computer(state)


def op_4(state: IntcodeComputer) -> IntcodeComputer:
    """
    write c
    Load c
    Write to output
    """
    state.write_output(state.c())

    state.ip += 2
    return computer(state)


def op_5(state: IntcodeComputer) -> IntcodeComputer:
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


def op_6(state: IntcodeComputer) -> IntcodeComputer:
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


def op_7(state: IntcodeComputer) -> IntcodeComputer:
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


def op_8(state: IntcodeComputer) -> IntcodeComputer:
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


def op_9(state: IntcodeComputer) -> IntcodeComputer:
    """
    Adjust relative base
    arb c
    rb += c
    """
    state.relative_base += state.c()
    state.ip += 2
    return computer(state)


def op_99(state: IntcodeComputer) -> IntcodeComputer:
    """
    Exit computation; since we mutually recurse to run the computer, this means _not_ recurring.

    This is the only non-error exit from the mutual recursion.
    """
    state.state = State.STOPPED
    return state


def computer(state: IntcodeComputer) -> IntcodeComputer:
    """
    Mutually recurse depending on the current value at the instruction pointer (IP).

    While this could be inside the above dataclass, keeping it separate helps avoid getting _too_ imperative.
    """
    log.debug("IP: %s, RB: %s, Opcode: %s", state.ip, state.relative_base, state.opcode())
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
        case 9:
            return op_9(state)
        case 99:
            return op_99(state)
        case int(x):
            raise NotImplementedError(f"Unexpected opcode: {x}, instruction {state.memory[state.ip]}")
