from pathlib import PurePath
from typing import List


def find_longest_hike(
    grid: List[List[str]],
    slippery: bool,
    show_progress: bool = False,
) -> int:
    paths = []
    complete_paths = []
    start = [0, 1]
    rows = len(grid)
    columns = len(grid[0])
    end = [rows - 1, columns - 2]
    offsets = [[0, 1], [1, 0], [0, -1], [-1, 0]]

    paths.append([":0,1:", start])
    paths_updated = True

    while paths_updated:
        paths_updated = False
        new_paths = []

        for path in paths:
            route = path[0]
            position = path[1]

            for offset in offsets:
                new_row = position[0] + offset[0]
                new_column = position[1] + offset[1]
                new_position = [new_row, new_column]

                if (
                    new_row < 0
                    or new_row >= rows
                    or new_column < 0
                    or new_column >= columns
                ):
                    continue

                new_marker = grid[new_row][new_column]

                if new_marker == "#":
                    continue

                if slippery and (
                    new_marker == ">"
                    and offset[1] == -1
                    or new_marker == "<"
                    and offset[1] == 1
                    or new_marker == "v"
                    and offset[0] == -1
                    or new_marker == "^"
                    and offset[0] == 1
                ):
                    continue

                position_string = f"{new_row},{new_column}"

                if f":{position_string}:" in route:
                    continue

                new_route = f"{route}{position_string}:"

                if [new_row, new_column] == end:
                    complete_paths.append(new_route)

                # Need to find equivalent paths here...
                found = False
                set_new_route = set(new_route[1:-1].split(":"))

                for new_path in new_paths:
                    if (
                        new_path[1] == new_position
                        and set(new_path[0][1:-1].split(":")) == set_new_route
                    ):
                        found = True
                        break

                if not found:
                    new_paths.append([new_route, new_position])
                    paths_updated = True

            paths = new_paths

        if show_progress and len(paths) > 0:
            print(
                "Current best",
                len(paths),
                max([len(path[0].split(":")) - 3 for path in paths]),
            )

    print("Best", [len(path[1:-1].split(":")) - 1 for path in complete_paths])
    return max([len(path[1:-1].split(":")) - 1 for path in complete_paths])


def position_as_int(row: int, column: int) -> int:
    return 1000 * row + column


def add_position_to_route(route: str, position: str) -> str:
    return (
        ":"
        + ":".join([p for p in sorted(f"{route[1:-1]}:{position}".split(":"))])
        + ":"
    )


# THIS DOESN'T WORK
# USE A SORTED STRING (FUNCTION?) TO AVOID SET CREATION
#
# ALTERNATIVE - DO AS ABOVE BUT ADD ADDITIONAL PATH ITEM OF "SUM OF POSITIONS (AS INT)"
# AGAIN TO AVOID SET CREATION/COMPARISON)
#
# THIS DOESN'T APPEAR TO BE WORKING EITHER.
# MIGHT NEED TO ADOPT A LEFT/STRAIGHT/RIGHT AND BACKTRACK APPROACH.
def find_longest_hike2(
    grid: List[List[str]],
    slippery: bool,
    show_progress: bool = False,
) -> int:
    paths = []
    complete_paths = []
    start = [0, 1]
    rows = len(grid)
    columns = len(grid[0])
    end = [rows - 1, columns - 2]
    offsets = [[0, 1], [1, 0], [0, -1], [-1, 0]]

    paths.append([":0,1:", start])
    paths_updated = True

    while paths_updated:
        paths_updated = False
        new_paths = []

        for path in paths:
            route = path[0]
            position = path[1]

            for offset in offsets:
                new_row = position[0] + offset[0]
                new_column = position[1] + offset[1]
                new_position = [new_row, new_column]

                if (
                    new_row < 0
                    or new_row >= rows
                    or new_column < 0
                    or new_column >= columns
                ):
                    continue

                new_marker = grid[new_row][new_column]

                if new_marker == "#":
                    continue

                if slippery and (
                    new_marker == ">"
                    and offset[1] == -1
                    or new_marker == "<"
                    and offset[1] == 1
                    or new_marker == "v"
                    and offset[0] == -1
                    or new_marker == "^"
                    and offset[0] == 1
                ):
                    continue

                position_string = f"{new_row},{new_column}"

                if f":{position_string}:" in route:
                    continue

                new_route = add_position_to_route(route, position_string)

                if [new_row, new_column] == end:
                    complete_paths.append(new_route)

                # Need to find equivalent paths here...
                found = False

                for new_path in new_paths:
                    if new_path[1] == new_position and new_path[0] == new_route:
                        found = True
                        break

                if not found:
                    new_paths.append([new_route, new_position])
                    paths_updated = True

            paths = new_paths

        if show_progress and len(paths) > 0:
            print(
                "Current best",
                len(paths),
                max([len(path[0].split(":")) - 3 for path in paths]),
            )

    print("Best", [len(path[1:-1].split(":")) - 1 for path in complete_paths])
    return max([len(path[1:-1].split(":")) - 1 for path in complete_paths])


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    grid = []

    for line in lines:
        line = line.strip("\n")

        grid.append(list(line))

    # longest_hike = find_longest_hike(grid, True)
    # print(f"{input_type:>6} Part 1: {longest_hike}")

    longest_hike = find_longest_hike2(grid, False, input_type == "Puzzle")
    print(f"{input_type:>6} Part 2: {longest_hike}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    # main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
