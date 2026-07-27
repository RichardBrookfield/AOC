from pathlib import PurePath
from typing import Dict, Tuple

Position = Tuple[int, int]
Deliveries = Dict[Position, int]


def calculate_deliveries(line: str) -> Deliveries:
    position: Position = (0, 0)
    deliveries: Deliveries = {position: 1}

    for c in line:
        if c == "^":
            position = (position[0], position[1] - 1)
        elif c == "v":
            position = (position[0], position[1] + 1)
        elif c == ">":
            position = (position[0] + 1, position[1])
        elif c == "<":
            position = (position[0] - 1, position[1])
        else:
            assert False, f"Unexpected character: {c}"

        if position in deliveries:
            deliveries[position] += 1
        else:
            deliveries[position] = 1

    return deliveries


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    deliveries: Deliveries = {}

    for line in [line.rstrip("\n") for line in lines]:
        deliveries = calculate_deliveries(line=line)
        # print("Total deliveries: ", len(deliveries))

    print(f"{input_type:>6} Part 1: {len(deliveries)}")

    for line in [line.rstrip("\n") for line in lines]:
        if len(line) % 2 != 0:
            continue

        deliveries = calculate_deliveries(line=line[0::2]) | calculate_deliveries(line=line[1::2])
        # print("Total deliveries: ", len(deliveries))

    print(f"{input_type:>6} Part 2: {len(deliveries)}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day=day, input_path=input_path, input_type="Test")
    main(day=day, input_path=input_path, input_type="Puzzle")
