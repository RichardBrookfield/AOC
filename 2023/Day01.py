import re
from pathlib import PurePath


def extract_values(line: str) -> int:
    match = re.match(r"(?:[a-z]*)?(\d).*(\d)(?:[a-z]*)?", line)

    if match:
        tens = int(match.group(1))
        units = int(match.group(2))
    else:
        match = re.match(r"(?:[a-z]*)?(\d)(?:[a-z]*)?", line)

        if match:
            tens = int(match.group(1))
            units = tens
        else:
            return 0

    return 10 * tens + units


def replace_numbers(line: str) -> str:
    numbers = {
        "one": 1,
        "two": 2,
        "three": 3,
        "four": 4,
        "five": 5,
        "six": 6,
        "seven": 7,
        "eight": 8,
        "nine": 9,
    }

    match_found = True

    while match_found:
        match_found = False
        first_match = len(line)

        for k in numbers.keys():
            pos = line.find(k)

            if pos >= 0 and pos < first_match:
                first_match = pos

        for k, v in numbers.items():
            if line.find(k) == first_match:
                # Leave the remainder of the number for follow-on matches
                # e.g. "eightwone..." becomes "82w1ne..."
                line = line.replace(k, str(v) + k[1:])
                match_found = True
                break

    return line


def main(day: int, input_path: str, input_type: str, suffix: str = ""):
    with open(f"{input_path}/{input_type}/Day{day:02}{suffix}.txt", "r") as f:
        lines = f.readlines()

    total = [0, 0]

    for line in lines:
        line = line.rstrip("\n")

        total[0] += extract_values(line)
        line = replace_numbers(line)
        total[1] += extract_values(line)

    if input_type == "Test":
        if suffix == "-1":
            print(f"{input_type:>6} Part 1: {total[0]}")
        else:
            print(f"{input_type:>6} Part 2: {total[1]}")
    else:
        print(f"{input_type:>6} Part 1: {total[0]}")
        print(f"{input_type:>6} Part 2: {total[1]}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test", "-1")
    main(day, input_path, "Test", "-2")
    main(day, input_path, "Puzzle")
