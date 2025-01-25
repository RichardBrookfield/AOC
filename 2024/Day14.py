from pathlib import PurePath
from typing import List, Tuple


def move_robots(
    positions: List[Tuple[int, int]],
    velocities: List[Tuple[int, int]],
    rows: int,
    columns: int,
    seconds: int,
) -> None:
    for p in range(len(positions)):
        position = positions[p]
        velocity = velocities[p]

        new_row = (position[0] + seconds * velocity[0]) % rows
        new_column = (position[1] + seconds * velocity[1]) % columns

        positions[p] = (new_row, new_column)


def quadrant_product(
    positions: List[Tuple[int, int]],
    rows: int,
    columns: int,
) -> int:
    row_ranges: List[Tuple[int, int]] = [
        (0, int((rows - 1) / 2)),
        (int((rows + 1) / 2), rows),
    ]
    column_ranges: List[Tuple[int, int]] = [
        (0, int((columns - 1) / 2)),
        (int((columns + 1) / 2), columns),
    ]

    product = 1

    for rr in row_ranges:
        for cr in column_ranges:
            robot_count = [
                p
                for p in positions
                if p[0] in range(rr[0], rr[1]) and p[1] in range(cr[0], cr[1])
            ]
            product *= len(robot_count)

    return product


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    lines = [line.strip("\n") for line in lines if len(line) > 1]
    positions: List[Tuple[int, int]] = []
    velocities: List[Tuple[int, int]] = []

    for line in lines:
        parts = line.split(" ")

        position = [int(n) for n in parts[0][2:].split(",")]
        positions.append((position[1], position[0]))

        velocity = [int(v) for v in parts[1][2:].split(",")]
        velocities.append((velocity[1], velocity[0]))

    rows, columns = (7, 11) if input_type == "Test" else (103, 101)

    positions_copy = positions.copy()
    move_robots(positions_copy, velocities, rows, columns, 100)
    print(f"{input_type:>6} Part 1: {quadrant_product(positions_copy, rows, columns)}")

    if input_type == "Test":
        return

    # If you output the positions there are two repeating patterns.
    # One is horizontal for i = 43 and every 103 iterations.
    # The vertical starting at 68 and every 101 iterations.

    # It's a simple matter to calculate when they coincide.
    a = 43
    b = 68

    while True:
        if a == b:
            break
        if a < b:
            a += 103
        else:
            b += 101

    print(f"{input_type:>6} Part 2: {a}")

    # And if we print that...
    move_robots(positions, velocities, rows, columns, a)

    for row in range(rows):
        line = ["."] * columns
        for p in [p for p in positions if p[0] == row]:
            line[p[1]] = "X"
        print("".join(line) + "\n")

    print("\n")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
