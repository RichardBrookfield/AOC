from pathlib import PurePath
from typing import List

cached_results = {}


def find_length(pattern: str, lengths: List[int], length_offset: int) -> int:
    this_length = lengths[length_offset]

    if len(pattern) < this_length:
        return 0

    remaining_lengths = sum(lengths[length_offset:])

    if remaining_lengths + len(lengths) - length_offset - 1 > len(pattern):
        return 0

    if remaining_lengths > len(pattern.replace(".", "")):
        return 0

    used = pattern[0:this_length]
    left = pattern[this_length:]

    if "." in used:
        return 0
    else:
        key = f"{left}:{'/'.join([str(l) for l in lengths[length_offset:]])}"

        if key in cached_results:
            return cached_results[key]

        combinations = find_gap(left, lengths, length_offset + 1)
        cached_results[key] = combinations
        return combinations


def find_gap(pattern: str, lengths: List[int], length_offset: int) -> int:
    if length_offset == len(lengths):
        return 0 if "#" in pattern else 1

    combinations = 0

    for gap in range(0 if length_offset == 0 else 1, len(pattern)):
        used = pattern[0:gap]
        left = pattern[gap:]

        if "#" in used:
            return combinations
        elif length_offset == len(lengths):
            return combinations
        else:
            combinations += find_length(left, lengths, length_offset)

    return combinations


def find_combinations(pattern: str, lengths: List[int]) -> int:
    return find_gap(pattern, lengths, 0)


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    total_combinations1 = 0
    total_combinations2 = 0

    for line in lines:
        line = line.strip("\n")

        parts = line.split(" ")
        pattern = parts[0]
        lengths = [int(i) for i in parts[1].split(",")]

        total_combinations1 += find_combinations(pattern, lengths)

        new_lengths = lengths.copy()
        new_pattern = pattern

        for _ in range(4):
            new_lengths += lengths
            new_pattern += "?" + pattern

        total_combinations2 += find_combinations(new_pattern, new_lengths)

    print(f"{input_type:>6} Part 1: {total_combinations1}")
    print(f"{input_type:>6} Part 2: {total_combinations2}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
