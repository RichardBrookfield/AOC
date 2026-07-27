from itertools import permutations
from pathlib import PurePath
from typing import Dict, Tuple

Adjustments = Dict[Tuple[str, str], int]


def find_happiness(people: set[str], adjustments: Adjustments) -> int:
    max_happiness = -1000000

    for arrangement in permutations(people):
        happiness = 0

        for i in range(len(arrangement)):
            person0 = arrangement[i]
            person1 = arrangement[(i + 1) % len(people)]

            happiness += adjustments.get((person0, person1), 0)
            happiness += adjustments.get((person1, person0), 0)

        max_happiness = max(max_happiness, happiness)

    return max_happiness


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    adjustments: Adjustments = {}

    for line in [line.rstrip("\n") for line in lines]:
        parts = line.split()
        person0 = parts[0]
        person1 = parts[10].rstrip(".")
        adjustments[(person0, person1)] = int(parts[3]) * (
            1 if parts[2] == "gain" else -1
        )

    people = set(person for person, _ in adjustments.keys())

    max_happiness = find_happiness(people=people, adjustments=adjustments)
    print(f"{input_type:>6} Part 1: {max_happiness}")

    people.add("Me")
    max_happiness = find_happiness(people=people, adjustments=adjustments)
    print(f"{input_type:>6} Part 2: {max_happiness}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day=day, input_path=input_path, input_type="Test")
    main(day=day, input_path=input_path, input_type="Puzzle")
