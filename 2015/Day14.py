from pathlib import PurePath
from typing import Dict, Tuple

Reindeer = Dict[str, Tuple[int, int, int]]


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    reindeer: Reindeer = {}

    for line in [line.rstrip("\n") for line in lines]:
        parts = line.split()
        name = parts[0]
        speed = int(parts[3])
        duration = int(parts[6])
        rest = int(parts[13])

        reindeer[name] = (speed, duration, rest)

    trial_length = 2503 if input_type == "Puzzle" else 1000

    distances = {name: 0 for name in reindeer.keys()}
    points = distances.copy()

    for seconds in range(trial_length):
        for name, (speed, duration, rest) in reindeer.items():
            if seconds % (duration + rest) < duration:
                distances[name] += speed

        for name, distance in distances.items():
            if distance == max(distances.values()):
                points[name] += 1

    print(f"{input_type:>6} Part 1: {max(distances.values())}")
    print(f"{input_type:>6} Part 2: {max(points.values())}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day=day, input_path=input_path, input_type="Test")
    main(day=day, input_path=input_path, input_type="Puzzle")
