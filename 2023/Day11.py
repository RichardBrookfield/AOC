from pathlib import PurePath
from typing import List


def find_galaxy_distances(lines: List[str], expansion_factor: int) -> int:
    galaxies = []
    row = 0

    for line in lines:
        line = line.strip("\n")

        if "#" not in line:
            row += expansion_factor - 1
        else:
            for column in [
                column for column in range(len(line)) if line[column] == "#"
            ]:
                galaxies.append([row, column])

        row += 1

    empty_columns = [
        column
        for column in range(len(lines[0]))
        if column not in [galaxy[1] for galaxy in galaxies]
    ]

    galaxies: List[List[int]] = [
        [
            galaxy[0],
            galaxy[1]
            + len([column for column in empty_columns if column < galaxy[1]])
            * (expansion_factor - 1),
        ]
        for galaxy in galaxies
    ]

    total_distance = 0

    for i in range(len(galaxies) - 1):
        for j in range(i, len(galaxies)):
            total_distance += abs(galaxies[i][0] - galaxies[j][0]) + abs(
                galaxies[i][1] - galaxies[j][1]
            )

    return total_distance


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    total_distance = find_galaxy_distances(lines, 2)
    print(f"{input_type:>6} Part 1: {total_distance}")

    total_distance = find_galaxy_distances(
        lines, 10 if input_type == "Test" else 1000000
    )
    print(f"{input_type:>6} Part 2: {total_distance}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
