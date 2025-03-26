from pathlib import PurePath
from typing import Dict, List, Tuple


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    total = 0
    symbol_coverage: List[List[int]] = []
    star_coverage: Dict[Tuple[int, int], int] = {}
    star_ordinal = 0

    for line_number in range(len(lines)):
        line = lines[line_number].strip("\n")

        for i in range(len(line)):
            if not line[i].isdigit() and line[i] != ".":
                is_star = line[i] == "*"

                for x, y in [
                    (x, y)
                    for x in range(
                        max(line_number - 1, 0), min(line_number + 2, len(lines))
                    )
                    for y in range(max(i - 1, 0), min(i + 2, len(line)))
                ]:
                    if [x, y] not in symbol_coverage:
                        symbol_coverage.append([x, y])

                    if is_star and (x, y) not in star_coverage:
                        star_coverage[(x, y)] = star_ordinal

                star_ordinal += 1

    star_results: List[List[int]] = []

    for _ in range(star_ordinal):
        star_results.append([0, 1])

    for line_number in range(len(lines)):
        line = lines[line_number].strip("\n")

        i = 0

        while i < len(line):
            if line[i].isdigit():
                j = i

                while j < len(line) - 1 and line[j + 1].isdigit():
                    j += 1

                part_number = int(line[i : j + 1])
                found_symbol = False
                star_ordinal = None

                for y in range(max(i, 0), min(j + 1, len(line))):
                    if [line_number, y] in symbol_coverage:
                        found_symbol = True

                    if (line_number, y) in star_coverage:
                        star_ordinal = star_coverage[(line_number, y)]

                if found_symbol:
                    total += part_number

                if star_ordinal is not None:
                    star_results[star_ordinal][0] += 1
                    star_results[star_ordinal][1] *= part_number

                i = j

            i += 1

    print(f"{input_type:>6} Part 1: {total}")

    star_total = 0

    for star_result in star_results:
        if star_result[0] == 2:
            star_total += star_result[1]

    print(f"{input_type:>6} Part 2: {star_total}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
