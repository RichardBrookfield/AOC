from pathlib import PurePath
from typing import Dict, List, Tuple

KNOWN_NUMBER = 32772608
DICT_LIST = 0
DICT_COUNT = 1


def blink_once(numbers: List[int]) -> List[int]:
    new_numbers: List[int] = []

    for number in numbers:
        number_string = str(number)

        if number == 0:
            new_numbers.append(1)
        elif len(number_string) % 2 == 0:
            half = int(len(number_string) / 2)
            new_numbers.extend(
                [
                    int(number_string[:half]),
                    int(number_string[half:]),
                ]
            )
        else:
            new_numbers.append(2024 * number)

    return new_numbers


def add_to_summary(
    summary: Dict[str, Tuple[List[int], int]],
    numbers: List[int],
    new_occurrences: int = 1,
) -> None:
    if str(numbers) in summary:
        summary[str(numbers)] = (
            numbers,
            summary[str(numbers)][DICT_COUNT] + new_occurrences,
        )
    else:
        summary[str(numbers)] = (numbers, new_occurrences)


def blink(numbers: List[int], repeats: int) -> int:
    number_summary: Dict[str, Tuple[List[int], int]] = {str(numbers): (numbers, 1)}

    for _ in range(repeats):
        new_summary: Dict[str, Tuple[List[int], int]] = {}

        for v in number_summary.values():
            new_numbers = blink_once(v[DICT_LIST])

            # The KNOWN_NUMBER often occurs at intervals in the workings.
            # Thefore extract snippets around it, and we can deal with identical sequences as a group.
            while KNOWN_NUMBER in new_numbers:
                this_offset = new_numbers.index(KNOWN_NUMBER)

                if KNOWN_NUMBER in new_numbers[this_offset + 1 :]:
                    next_offset = new_numbers.index(KNOWN_NUMBER, this_offset + 1)

                    add_to_summary(
                        new_summary,
                        new_numbers[this_offset + 1 : next_offset + 1],
                        v[DICT_COUNT],
                    )
                    del new_numbers[this_offset + 1 : next_offset + 1]
                else:
                    break

            add_to_summary(new_summary, new_numbers, v[DICT_COUNT])

        number_summary = new_summary

    return sum([len(v[0]) * v[1] for v in number_summary.values()])


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    lines = [line.strip("\n") for line in lines if len(line) > 1]
    numbers = [int(n.strip()) for n in lines[0].split(" ")]

    print(f"{input_type:>6} Part 1: {blink(numbers, 25)}")

    if input_type == "Puzzle":
        print(f"{input_type:>6} Part 1: {blink(numbers, 75)}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
