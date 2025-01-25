from pathlib import PurePath
from typing import List, Set, Tuple

offsets: List[Tuple[int, int]] = [(0, -1), (0, 1), (-1, 0), (1, 0)]


def find_route(obstruction_list: List[str], grid_size: int) -> int:
    obstructions: Set[Tuple[int, int]] = set()

    for obstruction_line in obstruction_list:
        parts = obstruction_line.split(",")
        obstructions.add((int(parts[0]), int(parts[1])))

    locations: List[Tuple[int, int]] = []
    visited: List[Tuple[int, int]] = []

    position = (0, 0)
    locations.append(position)
    visited.append(position)

    route_length = 0

    while len(locations) > 0:
        new_locations: List[Tuple[int, int]] = []
        route_length += 1

        for route in locations:
            for offset in offsets:
                new_position = (
                    route[0] + offset[0],
                    route[1] + offset[1],
                )

                if (
                    not (
                        0 <= new_position[0] <= grid_size
                        and 0 <= new_position[1] <= grid_size
                    )
                    or new_position in obstructions
                    or new_position in visited
                ):
                    continue

                if new_position == (grid_size, grid_size):
                    return route_length
                else:
                    new_locations.append(new_position)
                    visited.append(new_position)

        locations = new_locations

    return -1


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    lines = [line.strip("\n") for line in lines if len(line) > 1]

    grid_size = 6 if input_type == "Test" else 70
    limit = 12 if input_type == "Test" else 1024

    print(f"{input_type:>6} Part 1: {find_route(lines[0:limit], grid_size)}")

    highest_working = limit
    lowest_failure = len(lines)

    while lowest_failure - highest_working > 1:
        middle = int((lowest_failure + highest_working) / 2)

        if -1 == find_route(lines[0:middle], grid_size):
            lowest_failure = middle
        else:
            highest_working = middle

    print(f"{input_type:>6} Part 2: {lines[highest_working]}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
