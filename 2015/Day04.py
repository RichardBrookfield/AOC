import hashlib
from pathlib import PurePath
from typing import Tuple


def find_hash(input: str) -> Tuple[int, int]:
    answer5 = 0
    answer6 = 0

    for i in range(1, 10000000):
        hash = hashlib.md5(f"{input}{i}".encode("utf-8")).hexdigest()

        if hash.startswith("0" * 5) and answer5 == 0:
            answer5 = i
        if hash.startswith("0" * 6) and answer6 == 0:
            answer6 = i

    # print(input, answer5, answer6)
    return answer5, answer6


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    answer5 = 0
    answer6 = 0

    for line in [line.rstrip("\n") for line in lines]:
        answer5, answer6 = find_hash(input=line)

    print(f"{input_type:>6} Part 1: {answer5}")
    print(f"{input_type:>6} Part 2: {answer6}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day=day, input_path=input_path, input_type="Test")
    main(day=day, input_path=input_path, input_type="Puzzle")
