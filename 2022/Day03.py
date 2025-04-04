from pathlib import PurePath
from typing import List


def find_common(str1: str, str2: str, all: bool) -> str:
    common = ""

    for c in str1:
        if str2.find(c) >= 0:
            common += c

            if not all:
                break

    return common


def letter_value(common: str):
    letter = common[:1]
    return (
        ord(letter) - ord("a") + 1 if letter.islower() else ord(letter) - ord("A") + 27
    )


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    total_part1 = 0
    total_part2 = 0
    triplets: List[str] = []

    for line in lines:
        line = line.rstrip("\n")

        half = int(len(line) / 2)

        half1 = line[0:half]
        half2 = line[half:]

        common_letter = find_common(half1, half2, all=False)
        total_part1 += letter_value(common_letter)

        triplets.append(line)

        if len(triplets) == 3:
            first_match = find_common(triplets[0], triplets[1], all=True)
            full_match = find_common(first_match, triplets[2], all=True)
            total_part2 += letter_value(full_match)
            triplets.clear()

    print(f"{input_type:>6} Part 1: {total_part1}")
    print(f"{input_type:>6} Part 2: {total_part2}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
