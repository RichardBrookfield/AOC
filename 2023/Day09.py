from pathlib import PurePath
from typing import List


def find_next_number(numbers: List[int], include_number: bool = True) -> int:
    differences = []

    for i in range(len(numbers) - 1):
        differences.append(numbers[i + 1] - numbers[i])

    if max(differences) == min(differences) == 0:
        return 0

    next = differences[-1] + find_next_number(differences, False)

    return next + numbers[-1] if include_number else next


def find_previous_number(numbers: List[int], include_number: bool = True) -> int:
    differences = []

    for i in range(len(numbers) - 1):
        differences.append(numbers[i + 1] - numbers[i])

    if max(differences) == min(differences) == 0:
        return 0

    previous = differences[0] - find_previous_number(differences, False)

    return numbers[0] - previous if include_number else previous


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    total_next = 0
    total_previous = 0

    for line in lines:
        line = line.strip("\n")
        numbers = [int(n) for n in line.split(" ")]

        total_next += find_next_number(numbers)
        total_previous += find_previous_number(numbers)

    print(f"{input_type:>6} Part 1: {total_next}")
    print(f"{input_type:>6} Part 2: {total_previous}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
