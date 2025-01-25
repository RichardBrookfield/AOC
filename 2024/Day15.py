from pathlib import PurePath
from typing import List, Set, Tuple

EMPTY = 0
BOX = 1
PILLAR = 2
LEFT_BOX = 3
RIGHT_BOX = 4

offsets = {
    "^": (-1, 0),
    "v": (1, 0),
    "<": (0, -1),
    ">": (0, 1),
}


def move1(
    warehouse: List[List[int]],
    moves: str,
    robot: Tuple[int, int],
    rows: int,
    columns: int,
) -> None:
    for move in moves:
        offset = offsets[move]
        new_position = (robot[0] + offset[0], robot[1] + offset[1])

        if not (0 <= new_position[0] < rows and 0 <= new_position[1] < columns):
            continue
        elif warehouse[new_position[0]][new_position[1]] == PILLAR:
            continue
        elif warehouse[new_position[0]][new_position[1]] == EMPTY:
            robot = new_position
        else:
            empty_position = new_position

            while True:
                empty_position = (
                    empty_position[0] + offset[0],
                    empty_position[1] + offset[1],
                )

                if not (
                    0 <= empty_position[0] < rows and 0 <= empty_position[1] < columns
                ):
                    break
                elif warehouse[empty_position[0]][empty_position[1]] == PILLAR:
                    break
                elif warehouse[empty_position[0]][empty_position[1]] == EMPTY:
                    warehouse[new_position[0]][new_position[1]] = EMPTY
                    warehouse[empty_position[0]][empty_position[1]] = BOX
                    robot = new_position
                    break


def move2(
    warehouse: List[List[int]],
    moves: str,
    robot: Tuple[int, int],
    rows: int,
    columns: int,
) -> None:
    for move in moves:
        offset = offsets[move]
        new_position = (robot[0] + offset[0], robot[1] + offset[1])

        if not (0 <= new_position[0] < rows and 0 <= new_position[1] < columns):
            continue
        elif warehouse[new_position[0]][new_position[1]] == PILLAR:
            continue
        elif warehouse[new_position[0]][new_position[1]] == EMPTY:
            robot = new_position
        else:
            empty_position = new_position

            if move in "<>":
                while True:
                    empty_position = (
                        empty_position[0] + offset[0],
                        empty_position[1] + offset[1],
                    )

                    if not (
                        0 <= empty_position[0] < rows
                        and 0 <= empty_position[1] < columns
                    ):
                        break
                    elif warehouse[empty_position[0]][empty_position[1]] == PILLAR:
                        break
                    elif warehouse[empty_position[0]][empty_position[1]] == EMPTY:
                        delta = 1 if move == "<" else -1

                        for column in range(empty_position[1], new_position[1], delta):
                            warehouse[new_position[0]][column] = warehouse[
                                new_position[0]
                            ][column + delta]

                        warehouse[new_position[0]][new_position[1]] = EMPTY
                        robot = new_position
                        break
            else:
                to_move: Set[Tuple[int, int]] = set()
                to_check: Set[Tuple[int, int]] = set()
                new_check: Set[Tuple[int, int]] = set()

                to_check.add(empty_position)
                can_move = True

                while len(to_check) > 0:
                    out_of_bounds = False
                    hit_pillar = False

                    for p in to_check:
                        offset_p = (p[0] + offset[0], p[1] + offset[1])

                        if warehouse[p[0]][p[1]] != EMPTY:
                            to_move.add(p)
                            new_check.add(offset_p)

                            if not (
                                0 <= offset_p[0] < rows and 0 <= offset_p[1] < columns
                            ):
                                out_of_bounds = True
                                break
                            elif warehouse[offset_p[0]][offset_p[1]] == PILLAR:
                                hit_pillar = True
                                break

                        if warehouse[p[0]][p[1]] == LEFT_BOX:
                            right_half = (p[0], p[1] + 1)

                            if right_half not in to_move:
                                new_check.add(right_half)
                        elif warehouse[p[0]][p[1]] == RIGHT_BOX:
                            left_half = (p[0], p[1] - 1)

                            if left_half not in to_move:
                                new_check.add(left_half)

                    if hit_pillar or out_of_bounds:
                        can_move = False
                        break

                    # to_move |= to_check
                    to_check = new_check.copy()
                    new_check.clear()

                if not can_move:
                    continue

                if move == "^":
                    for row in range(rows):
                        for p in [p for p in to_move if p[0] == row]:
                            warehouse[row - 1][p[1]] = warehouse[row][p[1]]
                            warehouse[row][p[1]] = EMPTY
                elif move == "v":
                    for row in range(rows - 1, -1, -1):
                        for p in [p for p in to_move if p[0] == row]:
                            warehouse[row + 1][p[1]] = warehouse[row][p[1]]
                            warehouse[row][p[1]] = EMPTY

                robot = new_position


def sum_coordinates(
    warehouse: List[List[int]],
    rows: int,
    columns: int,
    part: int,
) -> int:
    total = 0

    for row, column in [
        (row, column)
        for row in range(rows)
        for column in range(columns)
        if warehouse[row][column] in [BOX, LEFT_BOX]
    ]:
        total += 100 * (row + 1) + column + part

    return total


def process_part1(lines: List[str]) -> int:
    rows = 0
    columns = len(lines[0]) - 2

    warehouse: List[List[int]] = []
    robot = (0, 0)
    moves = ""

    for line in lines[1:]:
        if line[0] == "#" and len(line.strip("#")) > 0:
            warehouse.append([EMPTY] * columns)

            for column in range(columns):
                if line[column + 1] == "O":
                    warehouse[rows][column] = BOX
                elif line[column + 1] == "#":
                    warehouse[rows][column] = PILLAR
                elif line[column + 1] == "@":
                    robot = (rows, column)

            rows += 1
        elif line[0] in offsets.keys():
            moves += line

    move1(warehouse, moves, robot, rows, columns)

    return sum_coordinates(warehouse, rows, columns, 1)


def process_part2(lines: List[str]) -> int:
    rows = 0
    map_columns = len(lines[0]) - 2
    real_columns = (len(lines[0]) - 2) * 2

    warehouse: List[List[int]] = []
    robot = (0, 0)
    moves = ""

    for line in lines[1:]:
        if line[0] == "#" and len(line.strip("#")) > 0:
            warehouse.append([EMPTY] * real_columns)

            for column in range(map_columns):
                if line[column + 1] == "O":
                    warehouse[rows][2 * column] = LEFT_BOX
                    warehouse[rows][2 * column + 1] = RIGHT_BOX
                elif line[column + 1] == "#":
                    warehouse[rows][2 * column] = PILLAR
                    warehouse[rows][2 * column + 1] = PILLAR
                elif line[column + 1] == "@":
                    robot = (rows, 2 * column)

            rows += 1
        elif line[0] in offsets.keys():
            moves += line

    move2(warehouse, moves, robot, rows, real_columns)

    return sum_coordinates(warehouse, rows, real_columns, 2)


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    lines = [line.strip("\n") for line in lines if len(line) > 1]

    print(f"{input_type:>6} Part 1: {process_part1(lines)}")
    print(f"{input_type:>6} Part 2: {process_part2(lines)}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
