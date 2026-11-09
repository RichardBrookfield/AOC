from pathlib import PurePath

Lights = set[tuple[int, int]]

neighbour_offsets: list[tuple[int, int]] = [
    (r, c) for r in range(-1, 2) for c in range(-1, 2) if (r, c) != (0, 0)
]


def get_new_state(lights: Lights, rows: int, columns: int) -> Lights:
    new_lights: Lights = set()

    for r in range(rows):
        for c in range(columns):
            neighbours_on = sum(
                (r + dr, c + dc) in lights for dr, dc in neighbour_offsets
            )

            if (r, c) in lights:
                if neighbours_on in [2, 3]:
                    new_lights.add((r, c))
            else:
                if neighbours_on == 3:
                    new_lights.add((r, c))

    return new_lights


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    lights: Lights = set()
    rows = 0
    columns = len(lines[0].rstrip("\n"))

    for line in [line.rstrip("\n") for line in lines]:
        for i, char in enumerate(line):
            if char == "#":
                lights.add((rows, i))

        rows += 1

    generations = 4 if input_type == "Test" else 100
    lights_part1 = lights.copy()

    for _ in range(generations):
        lights_part1 = get_new_state(lights=lights_part1, rows=rows, columns=columns)

    print(f"{input_type:>6} Part 1: {len(lights_part1)}")

    corners = [(0, 0), (0, columns - 1), (rows - 1, 0), (rows - 1, columns - 1)]

    lights_part2 = lights.copy() | set(corners)

    for _ in range(generations):
        lights_part2 = get_new_state(
            lights=lights_part2, rows=rows, columns=columns
        ) | set(corners)

    print(f"{input_type:>6} Part 2: {len(lights_part2)}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day=day, input_path=input_path, input_type="Test")
    main(day=day, input_path=input_path, input_type="Puzzle")
