import unittest

import day02
import day05
import day07
import day09
from common import computer, IntcodeComputer


class TestDay2(unittest.TestCase):
    """Test cases from Day 2; part 1"""

    def test_example0(self):
        prog = [1, 9, 10, 3, 2, 3, 11, 0, 99, 30, 40, 50]
        self.assertEqual(
            computer(IntcodeComputer(prog)).memory,
            [3500, 9, 10, 70, 2, 3, 11, 0, 99, 30, 40, 50]
        )

    def test_example1(self):
        prog = [1, 0, 0, 0, 99]
        self.assertEqual(
            computer(IntcodeComputer(prog)).memory,
            [2, 0, 0, 0, 99]
        )

    def test_example2(self):
        prog = [2, 3, 0, 3, 99]
        self.assertEqual(
            computer(IntcodeComputer(prog)).memory,
            [2, 3, 0, 6, 99]
        )

    def test_example3(self):
        prog = [2, 4, 4, 5, 99, 0]
        self.assertEqual(
            computer(IntcodeComputer(prog)).memory,
            [2, 4, 4, 5, 99, 9801]
        )

    def test_example4(self):
        prog = [1, 1, 1, 4, 99, 5, 6, 0, 99]
        self.assertEqual(
            computer(IntcodeComputer(prog)).memory,
            [30, 1, 1, 4, 2, 5, 6, 0, 99]
        )

    def test_part1(self):
        self.assertEqual(day02.part1(), 3101844)

    def test_part2(self):
        self.assertEqual(day02.part2(), 8478)


class TestDay5(unittest.TestCase):
    """Test cases from Day 5; part 2"""

    def test_example0(self):
        """Example from Part 1"""
        prog = [1002, 4, 3, 4, 33]
        self.assertEqual(
            computer(IntcodeComputer(prog)).memory,
            [1002, 4, 3, 4, 99]
        )

    def test_example1(self):
        """
        here are several programs that take one input, compare it to the value 8, and then produce one output:
        Using position mode, consider whether the input is equal to 8
        """
        prog = [3, 9, 8, 9, 10, 9, 4, 9, 99, -1, 8]
        self.assertEqual(
            computer(IntcodeComputer(prog, input_queue=[8])).output_queue,
            [1],
        )

    def test_example2(self):
        """Using position mode, consider whether the input is less than 8"""
        prog = [3, 9, 7, 9, 10, 9, 4, 9, 99, -1, 8]
        self.assertEqual(
            computer(IntcodeComputer(prog, input_queue=[8])).output_queue,
            [0],
        )

    def test_example3(self):
        """Using immediate mode, consider whether the input is equal to 8"""
        prog = [3, 3, 1108, -1, 8, 3, 4, 3, 99]
        self.assertEqual(
            computer(IntcodeComputer(prog, input_queue=[8])).output_queue,
            [1],
        )

    def test_example4(self):
        """
        Using immediate mode, consider whether the input is less than 8
        """
        prog = [3, 3, 1107, -1, 8, 3, 4, 3, 99]
        self.assertEqual(
            computer(IntcodeComputer(prog, input_queue=[8])).output_queue,
            [0],
        )

    def test_example5(self):
        """
        Here are some jump tests that take an input, then output 0 if the input was zero or 1 if the input was non-zero:

        Using position mode:
        output 0 if the input was zero or 1 if the input was non-zero
        """
        prog = [3, 12, 6, 12, 15, 1, 13, 14, 13, 4, 13, 99, -1, 0, 1, 9]
        self.assertEqual(
            computer(IntcodeComputer(prog, input_queue=[8])).output_queue,
            [1],
        )

    def test_example6(self):
        """
        Using immediate mode;
        output 0 if the input was zero or 1 if the input was non-zero
        """
        prog = [3, 3, 1105, -1, 9, 1101, 0, 0, 12, 4, 12, 99, 1]
        self.assertEqual(
            computer(IntcodeComputer(prog, input_queue=[8])).output_queue,
            [1],
        )

    def test_example7(self):
        """
        Here are some jump tests that take an input, then output 0 if the input was zero or 1 if the input was non-zero:

        This is the larger jump test.
        """
        prog = [
            3, 21, 1008, 21, 8, 20, 1005, 20, 22, 107, 8, 21, 20, 1006, 20, 31,
            1106, 0, 36, 98, 0, 0, 1002, 21, 125, 20, 4, 20, 1105, 1, 46, 104,
            999, 1105, 1, 46, 1101, 1000, 1, 20, 4, 20, 1105, 1, 46, 98, 99,
        ]
        for test_in, test_out in ((6, 999), (7, 999), (8, 1000), (9, 1001), (10, 1001)):
            self.assertEqual(
                computer(IntcodeComputer(prog, input_queue=[test_in])).output_queue,
                [test_out],
            )

    def test_part1(self):
        self.assertEqual(day05.part1().output_queue[-1], 5346030)

    def test_part2(self):
        self.assertEqual(day05.part2().output_queue, [513116])


class TestDay7(unittest.TestCase):
    """No new function was _directly_ introduced. Waiting on input and resuming computation was done so, implicitly."""

    def test_part1(self):
        """
        Part 1 does some modification of the input.
        Still, it is useful as an integration test.
        """
        self.assertEqual(day07.part1(), 225056)

    def test_part2(self):
        """
        Part 1 also does some modification of the input.
        Still, it is also useful as an integration test.
        """
        self.assertEqual(day07.part2(), 14260332)


class TestDay9(unittest.TestCase):
    def test_example0(self):
        """
        Quine!

        This is testing the functionality of the relative mode addressing in the Intcode computer.
        """
        prog = [109, 1, 204, -1, 1001, 100, 1, 100, 1008, 100, 16, 101, 1006, 101, 0, 99]

        self.assertEqual(
            computer(IntcodeComputer(prog)).output_queue,
            prog,
        )

    def test_example1(self):
        """
        Should output a 16-digit number.

        This is testing the ability to output large numbers.
        """
        prog = [1102, 34915192, 34915192, 7, 4, 7, 99, 0]
        self.assertEqual(
            computer(IntcodeComputer(prog)).output_queue,
            [1219070632396864],
        )

    def test_example2(self):
        """
        Should output the large number in the middle.

        This is also testing the ability to output large numbers."""
        prog = [104, 1125899906842624, 99]
        self.assertEqual(
            computer(IntcodeComputer(prog)).output_queue,
            [1125899906842624],
        )

    def test_part1(self):
        """Integration test"""
        self.assertEqual(day09.part1(), [2662308295])

    def test_part2(self):
        """Integration test"""
        self.assertEqual(day09.part2(), [63441])
