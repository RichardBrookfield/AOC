from pathlib import PurePath
from typing import List, Tuple


def move(
    grid: List[List[str]], position: List[int], direction: str
) -> Tuple[List[int], str]:
    new_position = position.copy()

    if direction == "U":
        new_position[0] -= 1
    elif direction == "D":
        new_position[0] += 1
    elif direction == "R":
        new_position[1] += 1
    elif direction == "L":
        new_position[1] -= 1

    pipe = grid[new_position[0]][new_position[1]]

    if pipe == "|" and direction in "UD" or pipe == "-" and direction in "LR":
        pass
    elif pipe == "L":
        if direction == "D":
            direction = "R"
        elif direction == "L":
            direction = "U"
        else:
            raise Exception("Invalid L direction")
    elif pipe == "J":
        if direction == "D":
            direction = "L"
        elif direction == "R":
            direction = "U"
        else:
            raise Exception("Invalid J direction")
    elif pipe == "7":
        if direction == "R":
            direction = "D"
        elif direction == "U":
            direction = "L"
        else:
            raise Exception("Invalid 7 direction")
    elif pipe == "F":
        if direction == "U":
            direction = "R"
        elif direction == "L":
            direction = "D"
        else:
            raise Exception("Invalid F direction")

    return new_position, direction


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

    if grid[start[0] - 1][start[1]] == "|":
        direction = "U"
    elif grid[start[0] + 1][start[1]] == "|":
        direction = "D"
    else:
        raise Exception("No convenient pipe")

    enclosed: List[List[int]] = []

    for _ in range(rows):
        enclosed.append([0] * columns)

    position = start.copy()
    steps = 0

    while True:
        # Make a note of coordinates to the left and right.
        # Exclude points which are actually on the pipe path.
        # Flood fill both outwards.
        # Check which set contains [0, 0].
        # Count the items in the other set.
        position, direction = move(grid, position, direction)
        steps += 1

        enclosed[position[0]][position[1]] = 2

        if position == start:
            break

    # for e in enclosed:
    #     print(e)
    # for row in range(rows):
    #     for column in range(columns):
    #         if grid[row][column] != "." and enclosed[row][column] == 0:
    #             enclosed[row][column] = 8

    points = [
        [row, column]
        for row in (0, rows - 1)
        for column in (0, columns - 1)
        if enclosed[row][column] == 0
    ]
    offsets = [[1, 0], [0, 1], [-1, 0], [0, -1]]

    while points:
        new_points: List[List[int]] = []

        for point in points:
            row = point[0]
            column = point[1]
            enclosed[row][column] = 1
            # print("process", row, column)

            for offset in offsets:
                new_row = row + offset[0]
                new_column = column + offset[1]
                # print("  check", new_row, new_column)

                if (
                    0 <= new_row < rows
                    and 0 <= new_column < columns
                    and enclosed[new_row][new_column] == 0
                    and [new_row, new_column] not in points
                    and [new_row, new_column] not in new_points
                ):
                    new_points.append([new_row, new_column])
                    # print("    accepted")
                # else:
                #     print("    rejected")

        points = new_points

    # for e in enclosed:
    #     print(e)
    with open("output10.txt", "w") as f:
        for e in enclosed:
            f.write("".join([str(x) for x in e]))
            f.write("\n")

    total_enclosed = len(
        [
            (row, column)
            for row in range(rows)
            for column in range(columns)
            if enclosed[row][column] == 0
        ]
    )

    print(f"{input_type:>6} Part 1: {int(steps/2)}")
    print(f"{input_type:>6} Part 2: {total_enclosed}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
