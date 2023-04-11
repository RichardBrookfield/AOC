from pathlib import PurePath


def full_overlap(a1: int, a2: int, b1: int, b2: int):
    return a1 <= b1 <= b2 <= a2 or b1 <= a1 <= a2 <= b2


def partial_overlap(a1: int, a2: int, b1: int, b2: int):
    return False if a2 < b1 or b2 < a1 else True


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    full_count = 0
    partial_count = 0

    for line in lines:
        line = line.rstrip("\n")

        ranges = line.split(",")
        from1, to1 = [int(i) for i in ranges[0].split("-")]
        from2, to2 = [int(i) for i in ranges[1].split("-")]

        if full_overlap(from1, to1, from2, to2):
            full_count += 1

        if partial_overlap(from1, to1, from2, to2):
            partial_count += 1

    print(f"{input_type:>6} Part 1: {full_count}")
    print(f"{input_type:>6} Part 2: {partial_count}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
