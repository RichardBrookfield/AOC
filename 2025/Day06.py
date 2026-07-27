import operator
from functools import reduce
from pathlib import PurePath
from typing import Iterable, List


def product(numbers: Iterable[int]) -> int:
    return reduce(operator.mul, numbers, 1)


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    operands: List[List[int]] = []
    operators: List[str] = []

    for line in [line.rstrip("\n") for line in lines]:
        if line[0] in "+*":
            operators = [x for x in line.split()]
        else:
            numbers = [int(x) for x in line.split()]
            operands.append(numbers)

    total = 0

    for operand in range(len(operands[0])):
        numbers = [operands[row][operand] for row in range(len(operands))]
        total += sum(numbers) if operators[operand] == "+" else product(numbers)

    print(f"{input_type:>6} Part 1: {total}")

    operands.clear()
    operator_positions = [i for i in range(len(lines[-1])) if lines[-1][i] != " "] + [
        len(lines[-1]) + 1
    ]

    for operator in range(len(operator_positions) - 1):
        start = operator_positions[operator]
        end = operator_positions[operator + 1] - 1

        numbers: List[int] = []

        for pos in range(start, end):
            number_string = ""

            for line in range(0, len(lines) - 1):
                number_string += lines[line][pos]

            numbers.append(int(number_string.strip()))

        operands.append(numbers)

    total = 0

    for operator in range(len(operators)):
        numbers = [
            operands[operator][column] for column in range(len(operands[operator]))
        ]
        total += sum(numbers) if operators[operator] == "+" else product(numbers)

    print(f"{input_type:>6} Part 2: {total}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
