from pathlib import PurePath
from typing import List


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    grid: List[List[str]] = []

    for line in lines:
        line = line.strip("\n")

        grid.append(list(line))

    rows = len(grid)
    columns = len(grid[0])

    start = list(
        [
            (row, column)
            for row in range(rows)
            for column in range(columns)
            if grid[row][column] == "S"
        ][0]
    )

    locations: List[List[int]] = []
    locations.append(start)
    offsets = [[1, 0], [0, 1], [-1, 0], [0, -1]]
    steps = 0

    while steps < 6 and input_type == "Test" or steps < 64 and input_type == "Puzzle":
        new_locations: List[List[int]] = []

        for point in locations:
            row = point[0]
            column = point[1]

            for offset in offsets:
                new_row = row + offset[0]
                new_column = column + offset[1]

                if (
                    0 <= new_column < columns
                    and 0 <= new_row < rows
                    and grid[new_row][new_column] in "S."
                    and [new_row, new_column] not in locations
                    and [new_row, new_column] not in new_locations
                ):
                    new_locations.append([new_row, new_column])

        locations = new_locations
        steps += 1

    print(f"{input_type:>6} Part 1: {len(locations)}")
    print(f"{input_type:>6} Part 2: ")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
