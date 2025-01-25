from pathlib import PurePath
from typing import Dict, Set, Tuple


def find_antinodes(
    antennae: Dict[Tuple[int, int], str],
    rows: int,
    columns: int,
    any_multiple: bool = False,
) -> int:
    antinodes: Set[Tuple[int, int]] = set()

    for k1, v1 in antennae.items():
        for k2 in [k2 for k2, v2 in antennae.items() if k2 != k1 and v2 == v1]:
            if any_multiple:
                antinodes.add(k1)
                antinodes.add(k2)

            multiple = 2

            while True:
                new_position = (
                    k1[0] + multiple * (k2[0] - k1[0]),
                    k1[1] + multiple * (k2[1] - k1[1]),
                )

                if 0 <= new_position[0] < rows and 0 <= new_position[1] < columns:
                    antinodes.add(new_position)
                else:
                    break

                if any_multiple:
                    multiple += 1
                else:
                    break

    return len(antinodes)


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    lines = [line.strip("\n") for line in lines if len(line) > 1]

    rows = len(lines)
    columns = len(lines[0])
    antennae: Dict[Tuple[int, int], str] = {}

    for row in range(rows):
        for column in range(columns):
            if lines[row][column] != ".":
                antennae[(row, column)] = lines[row][column]

    print(f"{input_type:>6} Part 1: {find_antinodes(antennae, rows, columns)}")
    print(f"{input_type:>6} Part 2: {find_antinodes(antennae, rows, columns, True)}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
