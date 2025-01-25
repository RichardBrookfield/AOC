from pathlib import PurePath
from typing import Dict, List, Set, Tuple

SHOW_TEST_CHEAT_LIST = False


offsets: List[Tuple[int, int]] = [(0, -1), (0, 1), (-1, 0), (1, 0)]


def find_map(
    obstructions: Set[Tuple[int, int]],
    rows: int,
    columns: int,
    start: Tuple[int, int],
    end: Tuple[int, int],
) -> Dict[Tuple[int, int], int]:
    positions: Set[Tuple[int, int]] = set([start])
    length_map = {start: 0}
    length = 0

    while len(positions) > 0:
        length += 1
        new_positions: Set[Tuple[int, int]] = set()

        for position, offset in [
            (position, offset) for position in positions for offset in offsets
        ]:
            new_position = (
                position[0] + offset[0],
                position[1] + offset[1],
            )

            if (
                not (0 <= new_position[0] < rows and 0 <= new_position[1] < columns)
                or new_position in length_map
                or new_position in new_positions
                or new_position in obstructions
            ):
                continue

            length_map[new_position] = length

            if new_position == end:
                return length_map

            new_positions.add(new_position)

        positions = new_positions

    return length_map


def add_saving(savings: Dict[int, int], saving: int, improvement_amount: int) -> bool:
    if saving < improvement_amount:
        return False

    if saving in savings:
        savings[saving] += 1
    else:
        savings[saving] = 1

    return True


def show_savings(savings: Dict[int, int], input_type: str) -> None:
    if SHOW_TEST_CHEAT_LIST and input_type == "Test":
        for k in sorted(savings.keys()):
            print(f"{savings[k]:>2} cheats(s) saving {k}")


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    lines = [line.strip("\n") for line in lines if len(line) > 1]

    improvement_amount = 100 if input_type == "Puzzle" else 0

    rows = len(lines) - 2
    columns = len(lines[0]) - 2
    obstructions: Set[Tuple[int, int]] = set()
    start = (0, 0)
    end = (0, 0)

    for row in range(rows):
        for column in range(columns):
            char = lines[row + 1][column + 1]
            position = (row, column)

            if char == "S":
                start = position
            elif char == "E":
                end = position
            elif char == "#":
                obstructions.add(position)

    start_map = find_map(obstructions, rows, columns, start, end)
    end_map = find_map(obstructions, rows, columns, end, start)

    best_length = start_map[end]
    total = 0
    savings: Dict[int, int] = {}

    # Look through start_map for two-move cheats that progress to an end_location with a suitable saving.
    for location in start_map:
        for offset in offsets:
            wall_location = (location[0] + offset[0], location[1] + offset[1])
            new_location = (wall_location[0] + offset[0], wall_location[1] + offset[1])

            if (
                wall_location in obstructions
                and new_location in end_map
                and add_saving(
                    savings,
                    best_length - (start_map[location] + 2 + end_map[new_location]),
                    improvement_amount,
                )
            ):
                total += 1

    show_savings(savings, input_type)

    print(f"{input_type:>6} Part 1: {total}")

    improvement_amount = 100 if input_type == "Puzzle" else 50

    total = 0
    savings.clear()

    # Now look for any move with a combined row+column of up to 20.
    for location, offset in [
        (location, offset)
        for location in start_map
        for offset in [
            (row, column)
            for row in range(-20, 21)
            for column in range(-20, 21)
            if abs(row) + abs(column) <= 20
        ]
    ]:
        new_location = (location[0] + offset[0], location[1] + offset[1])

        if new_location in end_map and add_saving(
            savings,
            best_length
            - (
                start_map[location]
                + abs(offset[0])
                + abs(offset[1])
                + end_map[new_location]
            ),
            improvement_amount,
        ):
            total += 1

    show_savings(savings, input_type)

    print(f"{input_type:>6} Part 2: {total}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
