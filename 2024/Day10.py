from pathlib import PurePath
from typing import List, Set, Tuple

offsets: List[Tuple[int, int]] = [(0, -1), (0, 1), (-1, 0), (1, 0)]


def count_trails(
    layout: List[List[int]],
    rows: int,
    columns: int,
    start: Tuple[int, int],
    distinct: bool = False,
) -> int:
    POSITION = 0
    ROUTE = 1

    positions: Set[Tuple[Tuple[int, int], str]] = set()
    positions.add((start, f"{start}" if distinct else ""))

    for level in range(1, 10):
        new_positions: Set[Tuple[Tuple[int, int], str]] = set()

        for position in positions:
            for offset in offsets:
                new_row = position[POSITION][0] + offset[0]
                new_column = position[POSITION][1] + offset[1]

                if not (0 <= new_row < rows and 0 <= new_column < columns):
                    continue

                if layout[new_row][new_column] != level:
                    continue

                new_position = (new_row, new_column)
                new_positions.add(
                    (
                        new_position,
                        f"{new_position}/{position[ROUTE]}" if distinct else "",
                    )
                )

        positions = new_positions

    return len(positions)


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    lines = [line.strip("\n") for line in lines if len(line) > 1]

    layout: List[List[int]] = []

    for line in lines:
        this_row: List[int] = []

        for char in line:
            this_row.append(int(char))

        layout.append(this_row)

    rows = len(lines)
    columns = len(lines[0])
    totals = [0, 0]

    for row, column in [
        (row, column)
        for row in range(rows)
        for column in range(columns)
        if layout[row][column] == 0
    ]:
        totals[0] += count_trails(layout, rows, columns, (row, column))
        totals[1] += count_trails(layout, rows, columns, (row, column), True)

    print(f"{input_type:>6} Part 1: {totals[0]}")
    print(f"{input_type:>6} Part 2: {totals[1]}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
