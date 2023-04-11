from pathlib import PurePath


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
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
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
