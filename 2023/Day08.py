from functools import reduce
from math import lcm
from pathlib import PurePath


def follow_path(paths: dict, directions: str) -> int:
    steps = 0
    offset = 0
    location = "AAA"

    while location != "ZZZ":
        location = paths[location][0 if directions[offset] == "L" else 1]
        steps += 1
        offset = (offset + 1) % len(directions)

    return steps


def follow_path_array(paths: dict, directions: str) -> int:
    locations = [k for k in paths.keys() if k[-1] == "A"]
    step_total = []
    step_offset = []

    for location in locations:
        steps = 0
        offset = 0
        start = location
        end_count = []

        while True:
            location = paths[location][0 if directions[offset] == "L" else 1]
            steps += 1
            offset = (offset + 1) % len(directions)

            if location[-1] == "Z":
                end_count.append(steps)

                if len(end_count) > 2:
                    # Check the results are suitable for a single LCM at the end.
                    if end_count[1] - end_count[0] != end_count[2] - end_count[1]:
                        print(f"Inconsitent step length: {start}")
                        return 0

                    if end_count[1] != 2 * end_count[0]:
                        print(f"Inconsistent ending position {start}")
                        return 0

                    break

        step_total.append(end_count[0])
        step_offset.append(end_count[1] - end_count[0])

    return reduce(lcm, step_total)


def main(day: int, input_path: str, input_type: str, suffix: str = ""):
    with open(f"{input_path}/{input_type}/Day{day:02}{suffix}.txt", "r") as f:
        lines = f.readlines()

    directions = None
    paths = {}

    for line in lines:
        line = line.strip("\n")

        if not line:
            continue

        if not directions:
            directions = line
            continue

        parts = line.split("=")
        source = parts[0].strip()
        destinations = parts[1].strip().replace("(", "").replace(")", "").split(", ")

        paths[source] = destinations

    if suffix != "-2":
        steps = follow_path(paths, directions)
        print(f"{input_type:>6} Part 1: {steps}")

    if input_type == "Puzzle" or suffix == "-2":
        total_ghosts = follow_path_array(paths, directions)
        print(f"{input_type:>6} Part 2: {total_ghosts}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test", "-1")
    main(day, input_path, "Test", "-2")
    main(day, input_path, "Puzzle")
