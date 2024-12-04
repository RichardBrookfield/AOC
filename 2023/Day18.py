from pathlib import PurePath


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    points = []
    position = [0, 0]
    points.append(position.copy())

    for line in lines:
        line = line.strip("\n")

        parts = line.split(" ")
        direction = parts[0]
        distance = int(parts[1])

        for _ in range(distance):
            if direction == "R":
                position[0] += 1
            elif direction == "L":
                position[0] -= 1
            elif direction == "D":
                position[1] += 1
            elif direction == "U":
                position[1] -= 1
            else:
                print(f"Unexpected direction: {direction}")

            if position in points:
                if position != [0, 0]:
                    print(f"Repeated position not at origin: {position}")
            else:
                points.append(position.copy())

    # print(points)

    min_x = min([p[0] for p in points])
    max_x = max([p[0] for p in points])
    min_y = min([p[1] for p in points])
    max_y = max([p[1] for p in points])

    grid = []
    columns = max_x - min_x + 1
    rows = max_y - min_y + 1

    single_row = [0] * columns

    for _ in range(rows):
        grid.extend([single_row.copy()])

    for p in points:
        grid[p[1] - min_y][p[0] - min_x] = 1

    first_edge = min([column for column in range(columns) if grid[1][column] == 1])
    while grid[1][first_edge] == 1:
        first_edge += 1

    within = []
    offsets = [[1, 0], [0, 1], [-1, 0], [0, -1]]
    within.append([1, first_edge])

    while within:
        new_within = []

        for point in within:
            row = point[0]
            column = point[1]
            grid[row][column] = 1

            for offset in offsets:
                new_row = row + offset[0]
                new_column = column + offset[1]

                if (
                    grid[new_row][new_column] == 0
                    and [new_row, new_column] not in within
                    and [new_row, new_column] not in new_within
                ):
                    new_within.append([new_row, new_column])

        within = new_within.copy()

    cleared = sum(
        [grid[row][column] for row in range(rows) for column in range(columns)]
    )

    print(f"{input_type:>6} Part 1: {cleared}")
    print(f"{input_type:>6} Part 2: ")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
