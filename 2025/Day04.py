from pathlib import PurePath
from typing import Dict, List, Tuple

Point = Tuple[int, int]


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    warehouse: Dict[Point, bool] = {}
    row = 0

    for line in [line.rstrip("\n") for line in lines]:
        for column in range(len(line)):
            warehouse[(column, row)] = line[column] == "@"

        row += 1

    first_round = True
    accessible_items: List[Point] = []
    total_removed = 0

    while True:
        for point in [k for k in warehouse.keys() if warehouse[k]]:
            adjacent_items = 0

            for offset_column, offset_row in [
                (x, y)
                for x in range(-1, 2)
                for y in range(-1, 2)
                if not (x == 0 and y == 0)
            ]:
                other_position = (point[0] + offset_column, point[1] + offset_row)

                if warehouse.get(other_position, False):
                    adjacent_items += 1

            if adjacent_items < 4:
                accessible_items.append(point)

        if first_round:
            print(f"{input_type:>6} Part 1: {len(accessible_items)}")
            first_round = False

        if len(accessible_items) == 0:
            break

        total_removed += len(accessible_items)

        for point in accessible_items:
            warehouse[point] = False

        accessible_items.clear()

    print(f"{input_type:>6} Part 2: {total_removed}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
