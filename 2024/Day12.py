from pathlib import PurePath
from typing import Dict, List, Tuple

offsets: List[Tuple[int, int]] = [(0, -1), (0, 1), (-1, 0), (1, 0)]


def find_regions(
    all_points: Dict[Tuple[int, int], str]
) -> Dict[int, List[Tuple[int, int]]]:
    regions: Dict[int, List[Tuple[int, int]]] = {}
    region = 0
    points = all_points.copy()

    while len(points) > 0:
        first_item = next(iter(points))
        current_letter = points[first_item]
        region_list = {(first_item[0], first_item[1])}

        while True:
            adjacent_points = [
                (point[0] + offset[0], point[1] + offset[1])
                for point in region_list
                for offset in offsets
            ]
            new_points = [
                point
                for point in adjacent_points
                if point not in region_list
                and point in all_points
                and all_points[point] == current_letter
            ]

            if len(new_points) == 0:
                break
            else:
                region_list |= set(new_points)

        regions[region] = list(region_list)
        region += 1

        for point in region_list:
            del points[point]

    return regions


def find_cost1(
    all_points: Dict[Tuple[int, int], str],
    regions: Dict[int, List[Tuple[int, int]]],
) -> int:
    cost = 0

    for region in regions.values():
        letter = all_points[region[0]]

        edge_fences = 0
        inner_fences = 0

        for point in region:
            offset_points = [
                (point[0] + offset[0], point[1] + offset[1]) for offset in offsets
            ]
            edge_fences += len([op for op in offset_points if op not in all_points])
            inner_fences += len(
                [
                    op
                    for op in offset_points
                    if op in all_points and all_points[op] != letter
                ]
            )

        cost += len(region) * (edge_fences + inner_fences)

    return cost


def find_cost2(
    all_points: Dict[Tuple[int, int], str],
    regions: Dict[int, List[Tuple[int, int]]],
) -> int:
    total_cost = 0

    for region in regions.values():
        letter = all_points[region[0]]
        cost = 0

        # The fences are either above or left of the corresponding point.
        # They are also further split because the inner and outer faces are distinct.
        vertical_facing_left: List[Tuple[int, int]] = []
        vertical_facing_right: List[Tuple[int, int]] = []
        horizontal_facing_up: List[Tuple[int, int]] = []
        horizontal_facing_down: List[Tuple[int, int]] = []

        for point in region:
            offset_points = [
                (point[0] + offset[0], point[1] + offset[1]) for offset in offsets
            ]

            for op in [
                op
                for op in offset_points
                if op not in all_points or op in all_points and all_points[op] != letter
            ]:
                if point[0] == op[0]:
                    if point[1] - op[1] == 1:
                        vertical_facing_left.append((point[0], point[1]))
                    else:
                        vertical_facing_right.append((op[0], op[1]))
                else:
                    if point[0] - op[0] == 1:
                        horizontal_facing_down.append((point[0], point[1]))
                    else:
                        horizontal_facing_up.append((op[0], op[1]))

        # Need to rationalise the fence lists here, or carefully count them.
        for horizontal_fences in [horizontal_facing_up, horizontal_facing_down]:
            rows = [hf[0] for hf in horizontal_fences]
            min_row = min(rows)
            max_row = max(rows)

            for row in range(min_row, max_row + 1):
                columns = sorted([hf[1] for hf in horizontal_fences if hf[0] == row])

                if len(columns) == 0:
                    pass
                elif len(columns) == 1:
                    cost += 1
                else:
                    cost += 1

                    for i in range(len(columns) - 1):
                        if columns[i] + 1 != columns[i + 1]:
                            cost += 1

        for vertical_fences in [vertical_facing_left, vertical_facing_right]:
            columns = [vf[1] for vf in vertical_fences]
            min_column = min(columns)
            max_column = max(columns)

            for column in range(min_column, max_column + 1):
                rows = sorted([vf[0] for vf in vertical_fences if vf[1] == column])

                if len(rows) == 0:
                    pass
                elif len(rows) == 1:
                    cost += 1
                else:
                    cost += 1

                    for i in range(len(rows) - 1):
                        if rows[i] + 1 != rows[i + 1]:
                            cost += 1

        total_cost += len(region) * cost

    return total_cost


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    lines = [line.strip("\n") for line in lines if len(line) > 1]
    rows = len(lines)
    columns = len(lines[0])

    all_points: Dict[Tuple[int, int], str] = {
        (row, column): lines[row][column]
        for row in range(rows)
        for column in range(columns)
    }

    regions = find_regions(all_points)

    print(f"{input_type:>6} Part 1: {find_cost1(all_points, regions)}")
    print(f"{input_type:>6} Part 2: {find_cost2(all_points, regions)}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
