from pathlib import PurePath
from typing import List

UNUSED = -1


def map_to_layout(input: str) -> List[int]:
    layout: List[int] = []
    file_number = 0
    is_file = True

    for char in input:
        if is_file:
            layout.extend([file_number] * int(char))
            file_number += 1
        else:
            layout.extend([-1] * int(char))

        is_file = not is_file

    return layout


def checksum(layout: List[int]) -> int:
    checksum = 0

    for i in [i for i in range(len(layout)) if layout[i] != -1]:
        checksum += i * layout[i]

    return checksum


def compress_part1(layout: List[int]) -> List[int]:
    new_layout = layout.copy()
    i = 0

    while i < len(new_layout):
        if layout[i] == UNUSED:
            next_value = layout[i]

            while next_value == UNUSED:
                next_value = new_layout.pop(-1)

            new_layout[i] = next_value
            pass

        i += 1

    return new_layout


def compress_part2(layout: List[int]) -> List[int]:
    new_layout = layout.copy()

    file_number = new_layout[-1]

    while 0 < file_number:
        file_start = new_layout.index(file_number)
        file_end = file_start

        while (
            file_end + 1 < len(new_layout) and new_layout[file_end + 1] == file_number
        ):
            file_end += 1

        file_length = file_end - file_start + 1
        gap_start = 0

        while True:
            try:
                gap_start = new_layout.index(-1, gap_start)

                if gap_start > file_start:
                    break
            except ValueError:
                break

            gap_end = gap_start

            while new_layout[gap_end + 1] == UNUSED:
                gap_end += 1

            gap_length = gap_end - gap_start + 1

            if gap_length >= file_length:
                gap_end = gap_start + file_length - 1

                new_layout = (
                    new_layout[:gap_start]
                    + new_layout[file_start : file_end + 1]
                    + new_layout[gap_end + 1 : file_start]
                    + [-1] * file_length
                    + new_layout[file_end + 1 :]
                )

                break
            else:
                gap_start = gap_end + 1

        file_number -= 1

    return new_layout


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    lines = [line.strip("\n") for line in lines if len(line) > 1]

    layout = map_to_layout(lines[0])

    print(f"{input_type:>6} Part 1: {checksum(compress_part1(layout))}")
    print(f"{input_type:>6} Part 2: {checksum(compress_part2(layout))}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
