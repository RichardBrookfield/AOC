from pathlib import PurePath
from typing import Dict, List, Set, Tuple

offsets: List[Tuple[int, int]] = [(0, 1), (1, 0), (0, -1), (-1, 0)]

LOCATION = 0
DIRECTION = 1
SCORE = 2
ROUTE = 3


def find_routes(
    locations: List[Tuple[int, int]],
    start: Tuple[int, int],
    end: Tuple[int, int],
) -> List[Tuple[Tuple[int, int], int, int, str]]:
    routes: List[Tuple[Tuple[int, int], int, int, str]] = []
    best_routes: Dict[Tuple[Tuple[int, int], int], int] = {}

    direction = 0
    count = 0
    best_score = 1000000000
    routes_added = True

    routes.append((start, direction, 0, f"{start}"))

    while routes_added:
        routes_added = False
        new_routes: List[Tuple[Tuple[int, int], int, int, str]] = []

        for r in routes:
            if r[LOCATION] == end:
                if r[SCORE] <= best_score:
                    best_score = r[SCORE]
                    new_routes.append(r)
                continue

            for direction in range(len(offsets)):
                new_direction = (r[DIRECTION] + direction) % len(offsets)
                score = 1 if direction == 0 else 2001 if direction == 2 else 1001
                new_location = (
                    r[LOCATION][0] + offsets[new_direction][0],
                    r[LOCATION][1] + offsets[new_direction][1],
                )

                if new_location not in locations:
                    continue

                new_location_str = f"{new_location}"
                new_score = r[SCORE] + score

                if new_location_str in r[ROUTE]:
                    continue

                if (new_location, new_direction) in best_routes and best_routes[
                    (new_location, new_direction)
                ] < new_score:
                    continue
                else:
                    best_routes[(new_location, new_direction)] = new_score

                if new_score <= best_score:
                    new_routes.append(
                        (
                            new_location,
                            new_direction,
                            new_score,
                            r[ROUTE] + new_location_str,
                        )
                    )
                    routes_added = True

        count += 1

        if count % 50 == 0:
            print(f"Count: {count:>3}  Routes: {len(routes):>4}")

        routes = new_routes

    return routes


def main(day: int, input_path: str, input_type: str, suffix: str = ""):
    with open(f"{input_path}/{input_type}/Day{day:02}{suffix}.txt", "r") as f:
        lines = f.readlines()

    lines = [line.strip("\n") for line in lines if len(line) > 1]

    rows = len(lines) - 2
    columns = len(lines[0]) - 2

    locations: List[Tuple[int, int]] = []
    start = (0, 0)
    end = (0, 0)

    for row, column in [
        (row, column) for row in range(rows) for column in range(columns)
    ]:
        char = lines[row + 1][column + 1]

        if char == "S":
            start = (row, column)
        elif char == "E":
            end = (row, column)
        elif char == ".":
            locations.append((row, column))

    locations.extend([start, end])

    routes = find_routes(locations, start, end)

    best_score = min([route[SCORE] for route in routes])

    print(f"{input_type:>6} Part 1: {best_score}")

    locations_on_any_best_route: Set[Tuple[int, int]] = set()

    for location in locations:
        location_str = f"{location}"

        for route in [route for route in routes if route[SCORE] == best_score]:
            if location_str in route[ROUTE]:
                locations_on_any_best_route |= set([location])
                break

    print(f"{input_type:>6} Part 2: {len(locations_on_any_best_route)}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test", "-1")
    main(day, input_path, "Test", "-2")
    main(day, input_path, "Puzzle")
