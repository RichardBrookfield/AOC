import os


def find_marker(message: str, unique: int):
    for offset in range(len(message) - unique + 1):
        chunk = message[offset : offset + unique]

        if len(chunk) == len(set(chunk)):
            return offset + unique

    return -1


def main(day: int, input_type: str):
    with open(f"input/{input_type}/Day{str(day).zfill(2)}.txt", "r") as f:
        lines = f.readlines()

    for line in lines:
        line = line.rstrip("\n")

        offset = find_marker(line, 4)
        message = find_marker(line, 14)

    print(f"{input_type:>6} Part 1: {offset}")
    print(f"{input_type:>6} Part 2: {message}")


if __name__ == "__main__":
    day = int(os.path.basename(__file__)[3:5])

    main(day, "Test")
    main(day, "Puzzle")
