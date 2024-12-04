from pathlib import PurePath
from typing import List


def inside(beam: dict, rows: int, columns: int) -> bool:
    return 0 <= beam["x"] < columns and 0 <= beam["y"] < rows


def new_beam(x: int, y: int, d: str) -> dict:
    return {"x": x, "y": y, "d": d}


def manipulate(beam: dict, hardware: List[List[str]]) -> List[dict]:
    item = hardware[beam["y"]][beam["x"]]

    if item == ".":
        return [beam]
    elif item == "|":
        return (
            [beam]
            if beam["d"] in "ud"
            else [
                new_beam(beam["x"], beam["y"], "u"),
                new_beam(beam["x"], beam["y"], "d"),
            ]
        )
    elif item == "-":
        return (
            [beam]
            if beam["d"] in "lr"
            else [
                new_beam(beam["x"], beam["y"], "l"),
                new_beam(beam["x"], beam["y"], "r"),
            ]
        )
    elif item == "/":
        new_direction = {"r": "u", "d": "l", "l": "d", "u": "r"}[beam["d"]]
        return [new_beam(beam["x"], beam["y"], new_direction)]
    elif item == "\\":
        new_direction = {"r": "d", "d": "r", "l": "u", "u": "l"}[beam["d"]]
        return [new_beam(beam["x"], beam["y"], new_direction)]
    else:
        print("Unknown hardware")

    return [beam]


def count_energised(
    initial_beam: dict, rows: int, columns: int, hardware: List[List[str]]
) -> int:
    beams = []
    processed_beams = []
    beams.extend([initial_beam])

    while beams:
        new_beams = []

        for beam in beams:
            if beam["d"] == "r":
                beam["x"] += 1
            elif beam["d"] == "l":
                beam["x"] -= 1
            elif beam["d"] == "u":
                beam["y"] -= 1
            elif beam["d"] == "d":
                beam["y"] += 1

            if not inside(beam, rows, columns) or beam in processed_beams:
                continue
            else:
                processed_beams.extend([beam.copy()])

            new_beams.extend(manipulate(beam, hardware))

        beams = new_beams

    return len(set([(p["x"], p["y"]) for p in processed_beams]))


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    hardware = []

    for line in lines:
        hardware.append(list(line.strip("\n")))

    rows = len(hardware)
    columns = len(hardware[0])

    energised = count_energised(new_beam(-1, 0, "r"), rows, columns, hardware)
    print(f"{input_type:>6} Part 1: {energised}")

    best_energised = 0

    for row in range(rows):
        energised_r = count_energised(new_beam(-1, row, "r"), rows, columns, hardware)
        energised_l = count_energised(
            new_beam(columns, row, "l"), rows, columns, hardware
        )

        best_energised = max(best_energised, energised_l, energised_r)

        if row and row % 10 == 0:
            print(f"Row: {row}/{rows}")

    for column in range(columns):
        energised_d = count_energised(
            new_beam(column, -1, "d"), rows, columns, hardware
        )
        energised_u = count_energised(
            new_beam(column, rows, "u"), rows, columns, hardware
        )

        best_energised = max(best_energised, energised_d, energised_u)

        if column and column % 10 == 0:
            print(f"Column: {column}/{columns}")

    print(f"{input_type:>6} Part 2: {best_energised}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
