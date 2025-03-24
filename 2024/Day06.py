from pathlib import PurePath
from typing import Set, Tuple


def get_new_vector(
    rows: int,
    columns: int,
    blocks: Set[Tuple[int, int]],
    position: Tuple[int, int],
    direction: int,
) -> Tuple[int, int, int]:
    direction_offsets = [
        [-1, 0],
        [0, 1],
        [1, 0],
        [0, -1],
    ]

    new_position = (
        position[0] + direction_offsets[direction][0],
        position[1] + direction_offsets[direction][1],
    )

    if not (0 <= new_position[0] < rows) or not (0 <= new_position[1] < columns):
        return -1, -1, -1

    if new_position in blocks:
        direction = (direction + 1) % len(direction_offsets)
        return get_new_vector(rows, columns, blocks, position, direction)

    return new_position[0], new_position[1], direction


def move_guard(
    rows: int,
    columns: int,
    blocks: Set[Tuple[int, int]],
    guard: Tuple[int, int],
) -> Set[Tuple[int, int]]:
    direction = 0
    position = guard
    occupied: Set[Tuple[int, int]] = set()
    occupied.add(guard)

    while True:
        vector = get_new_vector(rows, columns, blocks, position, direction)
        position = (vector[0], vector[1])
        direction = vector[2]

        if position[0] == -1:
            break

        occupied.add(position)

    return occupied


def move_guard_in_loop(
    rows: int,
    columns: int,
    blocks: Set[Tuple[int, int]],
    guard: Tuple[int, int],
) -> bool:
    direction = 0
    position: Tuple[int, int] = guard
    vectors: Set[Tuple[int, int, int]] = set()
    vectors.add((guard[0], guard[1], direction))

    while True:
        vector = get_new_vector(rows, columns, blocks, position, direction)

        if vector[0] == -1:
            return False
        elif vector in vectors:
            return True
        else:
            vectors.add(vector)

        position = (vector[0], vector[1])
        direction = vector[2]


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    lines = [line.strip("\n") for line in lines if len(line) > 1]

    rows = len(lines)
    columns = len(lines[0])

    blocks: Set[Tuple[int, int]] = set()
    guard = (0, 0)

    for row in range(rows):
        for column in range(columns):
            if lines[row][column] == "#":
                blocks.add((row, column))
            elif lines[row][column] == "^":
                guard = (row, column)

    occupied = move_guard(rows, columns, blocks, guard)

    print(f"{input_type:>6} Part 1: {len(occupied)}")

    looped_routes = 0

    for new_block in [new_block for new_block in occupied if new_block != guard]:
        if move_guard_in_loop(rows, columns, blocks | {new_block}, guard):
            looped_routes += 1

    print(f"{input_type:>6} Part 2: {looped_routes}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
