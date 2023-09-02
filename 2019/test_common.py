import unittest

from common import computer, IntcodeComputer


class TestDay2(unittest.TestCase):
    """Test cases from Day 2; part 1"""

    def test_example1(self):
        self.assertEqual(
            computer(IntcodeComputer([1, 0, 0, 0, 99])).memory,
            [2, 0, 0, 0, 99]
        )

    def test_example4(self):
        self.assertEqual(
            computer(IntcodeComputer([1, 1, 1, 4, 99, 5, 6, 0, 99])).memory,
            [30, 1, 1, 4, 2, 5, 6, 0, 99]
        )


class TestDay5(unittest.TestCase):
    """Test cases from Day 5; part 2"""

    def test_jump(self):
        self.assertEqual(
            computer(IntcodeComputer([3, 9, 8, 9, 10, 9, 4, 9, 99, -1, 8], input_queue=[0])).output_queue,
            [0],
        )


class TestDay7(unittest.TestCase):
    pass
