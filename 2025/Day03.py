from pathlib import PurePath
from typing import Dict

search_cache: Dict[str, int] = {}


def find_highest(input: str, digits: int) -> int:
    cache_index = f"{input}/{digits}"

    if len(input) < digits:
        return 0
    elif digits == len(input):
        search_cache[cache_index] = int(input)
    elif digits == 1:
        search_cache[cache_index] = int(max(list(input)))
    elif cache_index not in search_cache:
        with_first = int(f"{input[0]}{find_highest(input[1:], digits-1)}")
        without_first = find_highest(input[1:], digits)

        search_cache[cache_index] = max(with_first, without_first)

    return search_cache[cache_index]


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    total2 = 0
    total12 = 0

    for line in [line.rstrip("\n") for line in lines]:
        # For two characters it's O(n^2) to use this approach.
        highest = max(
            [
                int(line[i] + line[j])
                for i in range(0, len(line))
                for j in range(i + 1, len(line))
            ]
        )
        total2 += highest

        # For 12 characters it would be O(n^12), so we'll do a cached search.
        search_cache.clear()
        highest = find_highest(line, 12)
        total12 += highest

    print(f"{input_type:>6} Part 1: {total2}")
    print(f"{input_type:>6} Part 2: {total12}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
