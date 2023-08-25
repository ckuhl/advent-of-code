import dataclasses


@dataclasses.dataclass
class State:
    memory: list[int]
    pc: int = 0

    def read(self, offset: int) -> int:
        return self.memory[offset]

    def write(self, offset: int, value: int) -> None:
        self.memory[offset] = value


def op_1(state: State):
    pos1 = state.read(state.pc + 1)
    pos2 = state.read(state.pc + 2)
    pos3 = state.read(state.pc + 3)

    state.write(
        pos3,
        state.read(pos1) + state.read(pos2)
    )
    state.pc += 4
    return computer(state)


def op_2(state: State):
    pos1 = state.read(state.pc + 1)
    pos2 = state.read(state.pc + 2)
    pos3 = state.read(state.pc + 3)

    state.write(
        pos3,
        state.read(pos1) * state.read(pos2)
    )
    state.pc += 4
    return computer(state)


def op_99(state: State):
    return state


def computer(state: State) -> State:
    opcode = state.read(state.pc)
    if opcode == 1:
        return op_1(state)
    elif opcode == 2:
        return op_2(state)
    elif opcode == 99:
        return op_99(state)
    else:
        raise NotImplementedError
