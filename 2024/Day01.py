from pathlib import PurePath
from typing import List


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    first: List[int] = []
    second: List[int] = []
    total = [0, 0]

    for line in lines:
        line = line.rstrip("\n")

        numbers = [int(n) for n in line.split(" ") if len(n) > 0]
        first.append(numbers[0])
        second.append(numbers[1])

    first = sorted(first)
    second = sorted(second)

    for i in range(len(first)):
        total[0] += abs(first[i] - second[i])
        total[1] += first[i] * len([n for n in second if n == first[i]])

    print(f"{input_type:>6} Part 1: {total[0]}")
    print(f"{input_type:>6} Part 2: {total[1]}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
