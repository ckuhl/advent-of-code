import dataclasses
import logging

log = logging.getLogger(__name__)
logging.basicConfig(level=logging.DEBUG)


@dataclasses.dataclass
class State:
    memory: list[int]
    pc: int = 0
    # The input queue allows for queuing up inputs to the computer
    #  Useful for running non-interactively
    input_queue: list[int] = lambda: []

    def read(self, offset: int) -> int:
        try:
            return self.memory[offset]
        except IndexError:
            log.error(f"Tried to read from memory index={offset}")
            raise

    def write(self, offset: int, value: int) -> None:
        """nb. d5: Parameters that are written to will never be in immediate mode"""
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

    @staticmethod
    def write_output(v: int) -> None:
        """Helper: Provide output somewhere"""
        print(v)


def op_1(state: State):
    """
    op a, b, c
    load a
    load b
    sum a, b
    store c
    """
    decoded = decode(state.read(state.pc))
    pos1 = state.read(state.pc + 1)
    if decoded.C == 0:
        pos1 = state.read(pos1)
    pos2 = state.read(state.pc + 2)
    if decoded.B == 0:
        pos2 = state.read(pos2)
    pos3 = state.read(state.pc + 3)

    state.write(
        pos3,
        pos1 + pos2,
    )
    state.pc += 4
    return computer(state)


def op_2(state: State) -> State:
    """
    op a, b, c:
    load value at index  a
    load value at index b
    multiply v_a, v_b
    store in c
    """
    decoded = decode(state.read(state.pc))
    pos1 = state.read(state.pc + 1)
    if decoded.C == 0:
        pos1 = state.read(pos1)
    pos2 = state.read(state.pc + 2)
    if decoded.B == 0:
        pos2 = state.read(pos2)
    pos3 = state.read(state.pc + 3)

    state.write(pos3, pos1 * pos2)
    state.pc += 4
    return computer(state)


def op_3(state: State) -> State:
    """
    op a
    Read input
    Store in a
    """
    state.write(
        state.read(state.pc + 1),
        state.read_input(),
    )

    state.pc += 2
    return computer(state)


def op_4(state: State) -> State:
    """
    op a
    Load a
    Write to output
    """
    pos1 = state.read(
        state.read(state.pc + 1)
    )
    state.write_output(pos1)

    state.pc += 2
    return computer(state)


def op_99(state: State) -> State:
    """
    Exit computation; since we mutually recurse to run the computer, this means _not_ recurring.

    This is the only non-error exit from the mutual recursion.
    """
    return state


@dataclasses.dataclass
class Instruction:
    operation: int
    A: int
    B: int
    C: int


def decode(op: int) -> Instruction:
    """
    ABCDE
    _1002
    DE - Instruction
    C - First argument mode
    B - Second argument mode
    A - Third argument mode (leading zeroes are omitted, so we pad)
    """
    return Instruction(
        operation=op % 100,
        A=op // 10000,
        B=op % 10000 // 1000,
        C=op % 1000 // 100,
    )


def computer(state: State) -> State:
    """
    Mutually recurse depending on the current value at the program counter (PC).
    """
    opcode = state.read(state.pc)
    log.debug("Step: %s, PC: %s", opcode, state.pc)
    match opcode % 100:
        case 1:
            return op_1(state)
        case 2:
            return op_2(state)
        case 3:
            return op_3(state)
        case 4:
            return op_4(state)
        case 99:
            return op_99(state)
        case int(x):
            raise NotImplementedError(f"Unexpected opcode: {x}")
