import re
from pathlib import PurePath
from typing import List


def multiply(input: str) -> int:
    numbers = input[4:-1].split(",")
    return int(numbers[0]) * int(numbers[1])


def process_lines(lines: List[str], with_logic: bool) -> int:
    whole_input = "".join([l.strip("\n") for l in lines])

    pattern = (
        r"(mul\(\d+,\d+\)|do\(\)|don't\(\))" if with_logic else r"(mul\(\d+,\d+\))"
    )

    matches = re.findall(pattern, whole_input)
    total = 0
    enabled = True

    if matches:
        for m in matches:
            if m == "do()":
                enabled = True
            elif m == "don't()":
                enabled = False
            elif enabled:
                total += multiply(m)

    return total


def main(day: int, input_path: str, input_type: str, suffix: str = ""):
    with open(f"{input_path}/{input_type}/Day{day:02}{suffix}.txt", "r") as f:
        lines = f.readlines()

    if input_type == "Test" and suffix == "-1" or input_type == "Puzzle":
        print(f"{input_type:>6} Part 1: {process_lines(lines, False)}")

    if input_type == "Test" and suffix == "-2" or input_type == "Puzzle":
        print(f"{input_type:>6} Part 2: {process_lines(lines, True)}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test", "-1")
    main(day, input_path, "Test", "-2")
    main(day, input_path, "Puzzle")
