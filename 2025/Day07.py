from pathlib import PurePath
from typing import Dict, List, Tuple

Point = Tuple[int, int]
Points = List[Point]
Beams = Dict[Point, int]


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    beam_positions: Beams = {}
    splitters: Points = []
    row = 0

    for line in [line.rstrip("\n") for line in lines]:
        if row == 0:
            beam_positions[(line.index("S"), row)] = 1
        else:
            start_column = 0

            while "^" in line[start_column:]:
                position = line.index("^", start_column)
                splitters.append((position, row))
                start_column = position + 1

        row += 1

    splits = 0

    for row in range(2, len(lines) + 1):
        new_positions: Beams = {}

        for position, beams in beam_positions.items():
            one_row_down = (position[0], position[1] + 1)

            if one_row_down in splitters:
                next_row_positions = [
                    (position[0] - 1, position[1] + 1),
                    (position[0] + 1, position[1] + 1),
                ]
                splits += 1
            else:
                next_row_positions = [one_row_down]

            for new_row_position in next_row_positions:
                if new_row_position in new_positions:
                    new_positions[new_row_position] += beams
                else:
                    new_positions[new_row_position] = beams

        beam_positions = new_positions

    print(f"{input_type:>6} Part 1: {splits}")
    print(f"{input_type:>6} Part 2: {sum([v for v in beam_positions.values()])}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
