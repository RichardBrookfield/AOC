from math import prod
from pathlib import PurePath
from typing import Tuple


def validate_selections(selections: str) -> Tuple[bool, int]:
    possible = True

    minimum = {
        "red": 0,
        "green": 0,
        "blue": 0,
    }

    for selection in selections.split(";"):
        for choice in selection.split(","):
            choice_parts = choice.strip().split(" ")
            number = int(choice_parts[0])
            colour = choice_parts[1]

            maximum = {
                "red": 12,
                "green": 13,
                "blue": 14,
            }.get(colour)

            if number > maximum:
                possible = False

            if minimum[colour] < number:
                minimum[colour] = number

    return possible, prod(minimum.values())


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    total = [0, 0]

    for line in lines:
        line = line.strip("\n")

        game_parts = line.split(":")

        game_number = int(game_parts[0][5:])
        total[0] += game_number

        valid, power = validate_selections(game_parts[1])

        if not valid:
            total[0] -= game_number

        total[1] += power

    print(f"{input_type:>6} Part 1: {total[0]}")
    print(f"{input_type:>6} Part 2: {total[1]}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
