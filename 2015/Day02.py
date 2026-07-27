from math import prod
from pathlib import PurePath


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    total_area = 0
    total_length = 0

    for line in [line.rstrip("\n") for line in lines]:
        parts = [int(x) for x in line.split("x")]

        side_areas = [parts[0] * parts[1], parts[1] * parts[2], parts[2] * parts[0]]
        surface_area = 2 * sum(side_areas) + min(side_areas)
        total_area += surface_area

        length = 2 * (sum(parts) - max(parts)) + prod(parts)
        total_length += length

        # print(f"Area: {surface_area}  Length: {length}")

    print(f"{input_type:>6} Part 1: {total_area}")
    print(f"{input_type:>6} Part 2: {total_length}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day=day, input_path=input_path, input_type="Test")
    main(day=day, input_path=input_path, input_type="Puzzle")
