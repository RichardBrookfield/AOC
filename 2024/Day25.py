from pathlib import PurePath
from typing import List


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    lines = [line.strip("\n") for line in lines]

    locks: List[List[int]] = []
    keys: List[List[int]] = []
    device: List[str] = []

    for l in range(len(lines)):
        line = lines[l]

        if len(line) != 0:
            device.append(line)

        if len(line) == 0 or l == len(lines) - 1:
            signature: List[int] = []

            for i in range(len(device[0])):
                signature.append(len([d for d in device if d[i] == "#"]) - 1)

            if device[0] == "#####":
                locks.append(signature)
            else:
                keys.append(signature)

            device.clear()

    total = 0

    for lock in locks:
        for key in keys:
            fits = True

            for pin in range(5):
                if lock[pin] + key[pin] > 5:
                    fits = False

            if fits:
                total += 1

    print(f"{input_type:>6} Part 1: {total}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
