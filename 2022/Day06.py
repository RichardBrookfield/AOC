from pathlib import PurePath


def find_marker(message: str, unique: int):
    for offset in range(len(message) - unique + 1):
        chunk = message[offset : offset + unique]

        if len(chunk) == len(set(chunk)):
            return offset + unique

    return -1


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    for line in lines:
        line = line.rstrip("\n")

        offset = find_marker(line, 4)
        message = find_marker(line, 14)

    print(f"{input_type:>6} Part 1: {offset}")
    print(f"{input_type:>6} Part 2: {message}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
