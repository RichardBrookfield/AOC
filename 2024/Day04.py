import re
from pathlib import PurePath
from typing import List


def find_xmas_string(input: str) -> int:
    total = 0

    for search in ["XMAS", "SAMX"]:
        matches = re.findall(search, input)

        if matches:
            total += len(matches)

    return total


def find_xmas(lines: List[str], rows: int, columns: int) -> int:
    total = 0

    # rows
    for line in lines:
        total += find_xmas_string(line)

    # columns
    for column in range(columns):
        new_line = "".join([line[column] for line in lines])
        total += find_xmas_string(new_line)

    # trailing diagonal starting on the left of a row
    for start_row in range(rows):
        new_line = ""

        for row in range(0, start_row + 1):
            new_line += lines[row][start_row - row]

        total += find_xmas_string(new_line)

    # trailing diagonal starting on the bottom row (but not the first)
    for start_column in range(1, columns):
        new_line = ""

        for column in range(start_column, columns):
            new_line += lines[rows - 1 + start_column - column][column]

        total += find_xmas_string(new_line)

    # leading diagonal starting at the top row
    for start_column in range(columns):
        new_line = ""

        for column in range(start_column, columns):
            new_line += lines[column - start_column][column]

        total += find_xmas_string(new_line)

    # leading diagonal starting from the left (but not the first)
    for start_row in range(1, rows):
        new_line = ""

        for row in range(start_row, rows):
            new_line += lines[row][row - start_row]

        total += find_xmas_string(new_line)

    return total


def find_x_mas(lines: List[str], rows: int, columns: int) -> int:
    total = 0

    for row, column in [
        (row, column)
        for row in range(1, rows - 1)
        for column in range(1, columns - 1)
        if lines[row][column] == "A"
    ]:
        other_letters = (
            lines[row - 1][column + 1]
            + lines[row + 1][column + 1]
            + lines[row + 1][column - 1]
            + lines[row - 1][column - 1]
        )

        if (
            sorted(other_letters) == list("MMSS")
            and other_letters[0] != other_letters[2]
        ):
            total += 1

    return total


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    lines = [line.strip("\n") for line in lines if len(line) > 1]

    rows = len(lines)
    columns = len(lines[0])

    print(f"{input_type:>6} Part 1: {find_xmas(lines, rows, columns)}")
    print(f"{input_type:>6} Part 2: {find_x_mas(lines, rows, columns)}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
