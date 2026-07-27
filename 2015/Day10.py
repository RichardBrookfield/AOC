from pathlib import PurePath
from typing import Dict

CACHE: Dict[str, str] = {}
CACHE_KEY_MAX_LENGTH = 100


def transform(input: str) -> str:
    if len(input) <= CACHE_KEY_MAX_LENGTH and input in CACHE:
        return CACHE[input]

    output = ""
    original_input = input

    while len(input) > CACHE_KEY_MAX_LENGTH:
        split_pos = CACHE_KEY_MAX_LENGTH

        while split_pos > 0 and input[split_pos - 1] == input[split_pos]:
            split_pos -= 1

        if split_pos == 0:
            break

        output += transform(input=input[:split_pos])
        input = input[split_pos:]

    while input:
        first = input[0]
        count = 1

        for char in input[1:]:
            if char == first:
                count += 1
            else:
                break

        output += str(count) + first
        input = input[count:]

    if len(original_input) <= CACHE_KEY_MAX_LENGTH:
        CACHE[original_input] = output

    return output


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    iterations = 5 if input_type == "Test" else 40
    output = ""

    for line in [line.rstrip("\n") for line in lines]:
        output = line

        for _ in range(iterations):
            output = transform(input=output)

    print(f"{input_type:>6} Part 1: {len(output)}")

    if input_type == "Puzzle":
        for _ in range(10):
            output = transform(input=output)

    print(f"{input_type:>6} Part 2: {len(output)}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day=day, input_path=input_path, input_type="Test")
    main(day=day, input_path=input_path, input_type="Puzzle")
