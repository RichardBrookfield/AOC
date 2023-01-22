import os


def main(day: int, input_type: str):
    with open(f"input/{input_type}/Day{str(day).zfill(2)}.txt", "r") as f:
        lines = f.readlines()

    current_total = 0

    calories = list()

    for line in lines:
        line = line.rstrip("\n")

        if not line:
            calories.append(current_total)
            current_total = 0
        else:
            current_total += int(line)

    calories.sort(reverse=True)

    print(f"{input_type:>6} Part 1: {sum(calories[:1])}")
    print(f"{input_type:>6} Part 2: {sum(calories[:3])}")


if __name__ == "__main__":
    day = int(os.path.basename(__file__)[3:5])

    main(day, "Test")
    main(day, "Puzzle")
