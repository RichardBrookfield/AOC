from pathlib import PurePath
from typing import List


def safe(numbers: List[int]) -> bool:
    increasing = numbers[0] < numbers[1]

    for i in range(len(numbers) - 1):
        if (
            numbers[i] == numbers[i + 1]
            or abs(numbers[i] - numbers[i + 1]) > 3
            or (numbers[i] < numbers[i + 1]) != increasing
        ):
            return False

    return True


def safe_with_removal(numbers: List[int]) -> bool:
    for i in range(len(numbers)):
        if safe(numbers[0:i] + numbers[i + 1 :]):
            return True

    return False


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    total = [0, 0]

    for line in lines:
        line = line.rstrip("\n")

        numbers = [int(n) for n in line.split(" ")]

        if safe(numbers):
            total[0] += 1

        if safe_with_removal(numbers):
            total[1] += 1

    print(f"{input_type:>6} Part 1: {total[0]}")
    print(f"{input_type:>6} Part 2: {total[1]}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
