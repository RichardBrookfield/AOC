from pathlib import PurePath
from typing import List


def tilt_north(pattern: List[List[str]]) -> None:
    for x in range(len(pattern[0])):
        movement = True

        while movement:
            movement = False

            for y in range(len(pattern) - 1):
                if pattern[y][x] == "." and pattern[y + 1][x] == "O":
                    pattern[y][x], pattern[y + 1][x] = pattern[y + 1][x], pattern[y][x]
                    movement = True


def tilt_west(pattern: List[List[str]]) -> None:
    for y in range(len(pattern)):
        movement = True

        while movement:
            movement = False

            for x in range(len(pattern[0]) - 1):
                if pattern[y][x] == "." and pattern[y][x + 1] == "O":
                    pattern[y][x], pattern[y][x + 1] = pattern[y][x + 1], pattern[y][x]
                    movement = True


def tilt_south(pattern: List[List[str]]) -> None:
    for x in range(len(pattern[0])):
        movement = True

        while movement:
            movement = False

            for y in range(len(pattern) - 1, 0, -1):
                if pattern[y][x] == "." and pattern[y - 1][x] == "O":
                    pattern[y][x], pattern[y - 1][x] = pattern[y - 1][x], pattern[y][x]
                    movement = True


def tilt_east(pattern: List[List[str]]) -> None:
    for y in range(len(pattern)):
        movement = True

        while movement:
            movement = False

            for x in range(len(pattern[0]) - 1, 0, -1):
                if pattern[y][x] == "." and pattern[y][x - 1] == "O":
                    pattern[y][x], pattern[y][x - 1] = pattern[y][x - 1], pattern[y][x]
                    movement = True


def tilt_cycle(pattern: List[List[str]]) -> None:
    tilt_north(pattern)
    tilt_west(pattern)
    tilt_south(pattern)
    tilt_east(pattern)


def calculate_load(pattern: List[List[str]]) -> int:
    load = 0

    for y in range(len(pattern)):
        for x in range(len(pattern[0])):
            if pattern[y][x] == "O":
                load += len(pattern) - y

    return load


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    pattern: List[List[str]] = []
    loads: List[int] = []

    for line in lines:
        line = line.strip("\n")
        pattern.append(list(line))

    tilt_north(pattern)

    load = calculate_load(pattern)

    print(f"{input_type:>6} Part 1: {load}")

    tilt_west(pattern)
    tilt_south(pattern)
    tilt_east(pattern)
    loads.append(calculate_load(pattern))

    full_range = 200
    half_range = int(full_range / 2)
    quarter_range = int(full_range / 4)

    for _ in range(full_range):
        tilt_cycle(pattern)
        loads.append(calculate_load(pattern))

    pattern_found = False
    pattern_offset = 1

    while not pattern_found and pattern_offset < quarter_range:
        offset = half_range + pattern_offset

        if (
            loads[half_range : half_range + quarter_range]
            == loads[offset : offset + quarter_range]
        ):
            pattern_found = True
            break
        else:
            pattern_offset += 1

    target = 1000000000
    end_offset = half_range + (target - half_range) % pattern_offset - 1

    if pattern_found:
        print(f"{input_type:>6} Part 2: {loads[end_offset]}")
    else:
        print("Pattern not found")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
