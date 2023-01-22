import os
from math import floor


# Covert between offsets (1D) and points to record the route.
def offset_from_point(point, columns: int):
    return point[0] * columns + point[1]


def point_from_offset(offset: int, columns: int):
    return [floor(offset / columns), offset % columns]


def find_route(heights, start, end_height: int, going_up: bool = True):
    rows = len(heights)
    columns = len(heights[0])
    moves = [[1, 0], [0, 1], [-1, 0], [0, -1]]

    routes = []
    visited_offsets = []

    routes.append([])
    routes[0].append(offset_from_point(start, columns))

    while True:
        for r in routes:
            end = point_from_offset(r[-1], columns)

            if heights[end[0]][end[1]] == end_height:
                # Number of steps is one less than the number of points
                return len(r) - 1

        new_routes = []

        for route in routes:
            previous_end = route[-1]
            point = point_from_offset(previous_end, columns)

            for m in moves:
                new = [point[0] + m[0], point[1] + m[1]]

                if new[0] < 0 or new[0] >= rows or new[1] < 0 or new[1] >= columns:
                    continue

                if going_up:
                    if heights[new[0]][new[1]] > heights[point[0]][point[1]] + 1:
                        continue
                else:
                    if heights[new[0]][new[1]] < heights[point[0]][point[1]] - 1:
                        continue

                new_offset = offset_from_point(new, columns)

                if new_offset not in visited_offsets:
                    visited_offsets.append(new_offset)
                    new_routes.append(route + [new_offset])

        if not new_routes:
            # Return the worst case (all points)
            return rows * columns

        routes = new_routes


def main(day: int, input_type: str):
    with open(f"input/{input_type}/Day{str(day).zfill(2)}.txt", "r") as f:
        lines = f.readlines()

    rows = 0
    start, end, heights = [], [], []
    high_point = 27

    for line in lines:
        line = line.rstrip("\n")
        heights.append([])

        for c in line:
            if c.islower():
                height = ord(c) - ord("a") + 1
            elif c == "S":
                height = 0
                start = [rows, len(heights[rows])]
            else:
                height = high_point
                end = [rows, len(heights[rows])]

            heights[rows].append(height)

        rows += 1

    best_route_part1 = find_route(heights, start, high_point)
    print(f"{input_type:>6} Part 1: {best_route_part1}")

    best_route_part2 = find_route(heights, end, 1, going_up=False)
    print(f"{input_type:>6} Part 2: {best_route_part2}")


if __name__ == "__main__":
    day = int(os.path.basename(__file__)[3:5])

    main(day, "Test")
    main(day, "Puzzle")
