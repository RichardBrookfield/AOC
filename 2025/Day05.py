from pathlib import PurePath
from typing import List, Set, Tuple

Ranges = List[Tuple[int, int]]


# Safest approach is to reset after each change to avoid inconsistencies.
def simplify_ranges(ranges: Ranges) -> Tuple[Ranges, bool]:
    # deduplicate during copy
    ranges_copy = list(set(ranges.copy()))

    # r completely within other
    for r in ranges:
        for other in [other for other in ranges if other != r]:
            if other[0] <= r[0] <= r[1] <= other[1]:
                ranges_copy.remove(r)
                return ranges_copy, True

    # r extends other from the lower end
    for r in ranges:
        for other in [other for other in ranges if other != r]:
            if r[0] <= other[0] <= r[1] <= other[1]:
                ranges_copy.remove(r)
                ranges_copy.remove(other)
                ranges_copy.append((r[0], other[1]))
                return ranges_copy, True

    # r extends other from the top end
    for r in ranges:
        for other in [other for other in ranges if other != r]:
            if other[0] <= r[0] <= other[1] <= r[1]:
                ranges_copy.remove(r)
                ranges_copy.remove(other)
                ranges_copy.append((other[0], r[1]))
                return ranges_copy, True

    # no changes
    return ranges, False


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    fresh_ranges: Ranges = []
    ingredients: List[int] = []

    reading_fresh = True

    for line in [line.rstrip("\n") for line in lines]:
        if len(line) == 0:
            reading_fresh = False
            continue

        if reading_fresh:
            parts = [int(part) for part in line.split("-")]
            fresh_ranges.append((parts[0], parts[1]))
        else:
            ingredients.append(int(line))

    fresh_items: Set[int] = set()

    for ingredient in ingredients:
        for fresh_range in fresh_ranges:
            if fresh_range[0] <= ingredient <= fresh_range[1]:
                fresh_items.add(ingredient)

    print(f"{input_type:>6} Part 1: {len(fresh_items)}")

    changed = True

    while changed:
        fresh_ranges, changed = simplify_ranges(fresh_ranges)

    print(f"{input_type:>6} Part 2: {sum([r[1]-r[0]+1 for r in fresh_ranges])}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
