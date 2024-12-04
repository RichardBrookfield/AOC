from pathlib import PurePath


def race_options(time: int, distance: int) -> int:
    return len([t for t in range(1, time) if t * (time - t) > distance])


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    times = [int(t) for t in lines[0].strip("\n").split(" ")[1:] if t]
    distances = [int(d) for d in lines[1].strip("\n").split(" ")[1:] if d]
    total = 1

    for race in range(len(times)):
        total *= race_options(times[race], distances[race])

    print(f"{input_type:>6} Part 1: {total}")

    time = int(lines[0].strip("\n").split(":")[1].replace(" ", ""))
    distance = int(lines[1].strip("\n").split(":")[1].replace(" ", ""))
    total = race_options(time, distance)

    print(f"{input_type:>6} Part 2: {total}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
