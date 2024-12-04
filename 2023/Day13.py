from pathlib import PurePath
from typing import List


def check(pattern: List[str]) -> int:
    for x in range(len(pattern[0]) - 1):
        same = True

        for y in range(len(pattern)):
            start = pattern[y][: x + 1][::-1]
            end = pattern[y][x + 1 :]
            length = min(len(start), len(end))

            if start[:length] != end[:length]:
                same = False
                break

        if same:
            return x + 1

    for y in range(len(pattern) - 1):
        same = True

        for yy in range(y + 1):
            if y + 1 + yy >= len(pattern):
                break

            if pattern[y - yy] != pattern[y + 1 + yy]:
                same = False
                break

        if same:
            return 100 * (y + 1)

    print("No reflection found")
    return 0


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    pattern = []
    total = 0

    for line in lines:
        line = line.strip("\n")

        if line:
            pattern.append(line)
        else:
            total += check(pattern)
            pattern.clear()

    if pattern:
        total += check(pattern)

    print(f"{input_type:>6} Part 1: {total}")
    print(f"{input_type:>6} Part 2: ")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
