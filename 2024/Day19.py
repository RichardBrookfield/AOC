import re
from pathlib import PurePath
from typing import Dict, List, Set

# You'll do the same searches a lot recursively, so only do them once.
cached_find: Dict[str, int] = {}


def find_any_match(patterns: List[str], targets: List[str]) -> int:
    search_expression = "^((" + "|".join(patterns) + ")+)$"
    total = 0

    for target in targets:
        if re.match(search_expression, target):
            total += 1

    return total


def find_recursive_match(patterns: Set[str], target: str) -> int:
    if target in cached_find:
        return cached_find[target]

    total = 0

    if target in patterns:
        total += 1

    for i in range(1, len(target)):
        if target[:i] in patterns:
            total += find_recursive_match(patterns, target[i:])

    cached_find[target] = total
    return total


def find_all_matches(patterns: List[str], targets: List[str]) -> int:
    total = 0
    pattern_set = set(patterns)
    cached_find.clear()

    for target in targets:
        total += find_recursive_match(pattern_set, target)

    return total


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    lines = [line.strip("\n") for line in lines if len(line) > 1]
    patterns = [p.strip() for p in lines[0].split(",")]

    print(f"{input_type:>6} Part 1: {find_any_match(patterns, lines[1:])}")
    print(f"{input_type:>6} Part 2: {find_all_matches(patterns, lines[1:])}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
