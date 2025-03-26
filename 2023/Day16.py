from pathlib import PurePath
from typing import Dict, List


def inside(beam: Dict[str, int | str], rows: int, columns: int) -> bool:
    return 0 <= int(beam["x"]) < columns and 0 <= int(beam["y"]) < rows


def new_beam(x: int, y: int, d: str) -> Dict[str, int | str]:
    return {"x": x, "y": y, "d": d}


def manipulate(
    beam: Dict[str, int | str], hardware: List[List[str]]
) -> List[Dict[str, int | str]]:
    item = hardware[int(beam["y"])][int(beam["x"])]

    if item == ".":
        return [beam]
    elif item == "|":
        return (
            [beam]
            if str(beam["d"]) in "ud"
            else [
                new_beam(int(beam["x"]), int(beam["y"]), "u"),
                new_beam(int(beam["x"]), int(beam["y"]), "d"),
            ]
        )
    elif item == "-":
        return (
            [beam]
            if str(beam["d"]) in "lr"
            else [
                new_beam(int(beam["x"]), int(beam["y"]), "l"),
                new_beam(int(beam["x"]), int(beam["y"]), "r"),
            ]
        )
    elif item == "/":
        new_direction = {"r": "u", "d": "l", "l": "d", "u": "r"}[str(beam["d"])]
        return [new_beam(int(beam["x"]), int(beam["y"]), new_direction)]
    elif item == "\\":
        new_direction = {"r": "d", "d": "r", "l": "u", "u": "l"}[str(beam["d"])]
        return [new_beam(int(beam["x"]), int(beam["y"]), new_direction)]
    else:
        print("Unknown hardware")

    return [beam]


def count_energised(
    initial_beam: Dict[str, int | str],
    rows: int,
    columns: int,
    hardware: List[List[str]],
) -> int:
    beams: List[Dict[str, int | str]] = []
    processed_beams: List[Dict[str, int | str]] = []
    beams.extend([initial_beam])

    while beams:
        new_beams: List[Dict[str, int | str]] = []

        for beam in beams:
            if beam["d"] == "r":
                beam["x"] = int(beam["x"]) + 1
            elif beam["d"] == "l":
                beam["x"] = int(beam["x"]) - 1
            elif beam["d"] == "u":
                beam["y"] = int(beam["y"]) - 1
            elif beam["d"] == "d":
                beam["y"] = int(beam["y"]) + 1

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

    hardware: List[List[str]] = []

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
            print(f"Row: {row:>3}/{rows}")

    for column in range(columns):
        energised_d = count_energised(
            new_beam(column, -1, "d"), rows, columns, hardware
        )
        energised_u = count_energised(
            new_beam(column, rows, "u"), rows, columns, hardware
        )

        best_energised = max(best_energised, energised_d, energised_u)

        if column and column % 10 == 0:
            print(f"Column: {column:>3}/{columns}")

    print(f"{input_type:>6} Part 2: {best_energised}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
