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

    def __extend_to(self, address: int) -> None:
        """Helper: Extend memory when accessed beyond last member"""
        desired_increase = address + 1 - len(self.memory)
        log.info("Extending memory from %d by %d to %d", len(self.memory), desired_increase, address)
        self.memory = self.memory + [0] * desired_increase

    def read(self, address: int) -> int:
        """
        Read value from memory, extending if necessary.
        Throw an exception if a negative value is requested.
        We use try-except because it is faster in the happy path.
        """
        try:
            return self.memory[address]
        except IndexError:
            if address > 0:
                self.__extend_to(address)
                return self.memory[address]
            else:
                raise IndexError(f"Tried to read from negative address={address}")

    def write(self, address: int, value: int) -> None:
        """
        Write a value to memory, extending if necessary.
        Throw an exception if a negative value is requested.
        We use try-except because it is faster in the happy path.
        """
        try:
            self.memory[address] = value
        except IndexError:
            if address > 0:
                self.__extend_to(address)
                return self.write(address, value)
            else:
                raise IndexError(f"Tried to write value={value} to negative address={address}")

    def opcode(self):
        """Opcodes can be two digits, and so we mod by 100."""
        return self.read(self.ip) % 100

    def _register(self, index: int, is_dest):
        mode = self.memory[self.ip] % (10 ** (index + 2)) // (10 ** (index + 1))
        value = self.memory[self.ip + index]

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

    def a(self, is_dest=False):
        return self._register(3, is_dest)

    def b(self, is_dest=False):
        return self._register(2, is_dest)

    def c(self, is_dest=False):
        return self._register(1, is_dest)

    def op_1(self):
        """
        Add c and b, and store in a.
        ---
        add c, b, a
        load c
        load b
        add b, c
        store a
        """
        self.write(
            self.a(is_dest=True),
            self.c() + self.b(),
        )
        self.ip += 4
        return self.computer()

    def op_2(self):
        """
        Multiply c and b, and store in a.
        ---
        mult c, b, a:
        load b
        load c
        multiply b, c
        store a
        """
        self.write(
            self.a(is_dest=True),
            self.c() * self.b(),
        )
        self.ip += 4
        return self.computer()

    def op_3(self):
        """
        Read input
        ---
        Read c from stdin
        Store in c
        ---
        If we need input and there is none, we will return and wait for more input to be provided
        """
        if not self.input_queue:
            self.state = State.NEEDS_INPUT
            return self

        elif self.state == State.NEEDS_INPUT:
            self.state = State.RUNNING

        self.write(
            self.c(is_dest=True),
            self.input_queue.pop(0),
        )

        self.ip += 2
        return self.computer()

    def op_4(self):
        """
        Write c
        ---
        Load c
        Write to stdout
        """
        self.output_queue.append(self.c())

        self.ip += 2
        return self.computer()

    def op_5(self):
        """
        Jump-if-true
        ---
        jit c, b
        if c != 0:
            ip = b
        """
        if self.c() != 0:
            self.ip = self.b()
        else:
            self.ip += 3
        return self.computer()

    def op_6(self):
        """
        Jump-if-false
        ---
        jif c, b
        if c == 0:
            ip = b
        """
        if self.c() == 0:
            self.ip = self.b()
        else:
            self.ip += 3
        return self.computer()

    def op_7(self):
        """
        Less than
        ---
        lt c, b, a
        if c < b:
            a = 1
        else:
            a = 0
        """
        if self.c() < self.b():
            self.write(self.a(is_dest=True), 1)
        else:
            self.write(self.a(is_dest=True), 0)
        self.ip += 4
        return self.computer()

    def op_8(self):
        """
        Equals
        ---
        eq c, b, a
        if c == b:
            a = 1
        else:
            a = 0
        """
        if self.c() == self.b():
            self.write(self.a(is_dest=True), 1)
        else:
            self.write(self.a(is_dest=True), 0)
        self.ip += 4
        return self.computer()

    def op_9(self):
        """
        Adjust relative base
        ---
        arb c
        rb += c
        """
        self.relative_base += self.c()
        self.ip += 2
        return self.computer()

    def op_99(self):
        """
        Exit computation; since we mutually recurse to run the computer, this means _not_ recurring.

        This is the only non-error exit from the mutual recursion.
        """
        self.state = State.STOPPED
        return self

    def computer(self):
        """
        Mutually recurse depending on the current value at the instruction pointer (IP).

        While this could be inside the above dataclass, keeping it separate helps avoid getting _too_ imperative.
        """
        log.debug("IP: %s, RB: %s, Opcode: %s", self.ip, self.relative_base, self.opcode())
        match self.opcode():
            case 1:
                return self.op_1()
            case 2:
                return self.op_2()
            case 3:
                return self.op_3()
            case 4:
                return self.op_4()
            case 5:
                return self.op_5()
            case 6:
                return self.op_6()
            case 7:
                return self.op_7()
            case 8:
                return self.op_8()
            case 9:
                return self.op_9()
            case 99:
                return self.op_99()
            case int(x):
                raise NotImplementedError(f"Unexpected opcode: {x}, instruction {self.memory[self.ip]}")
