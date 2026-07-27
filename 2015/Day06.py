from pathlib import PurePath
from typing import List, Tuple

Point = Tuple[int, int]


def get_coordinates(line: str) -> Tuple[Point, Point]:
    parts = line.split()

    if parts[0] == "turn":
        x1, y1 = map(int, parts[2].split(","))
        x2, y2 = map(int, parts[4].split(","))
    else:  # "toggle"
        x1, y1 = map(int, parts[1].split(","))
        x2, y2 = map(int, parts[3].split(","))

    return (x1, y1), (x2, y2)


def turn(lights: List[List[int]], on: bool, p0: Point, p1: Point):
    for x in range(p0[0], p1[0] + 1):
        for y in range(p0[1], p1[1] + 1):
            lights[x][y] = 1 if on else 0


def toggle(lights: List[List[int]], p0: Point, p1: Point):
    for x in range(p0[0], p1[0] + 1):
        for y in range(p0[1], p1[1] + 1):
            lights[x][y] = 1 - lights[x][y]


def change_brightness(lights: List[List[int]], delta: int, p0: Point, p1: Point):
    for x in range(p0[0], p1[0] + 1):
        for y in range(p0[1], p1[1] + 1):
            if delta > 0:
                lights[x][y] += delta
            else:
                lights[x][y] = max(0, lights[x][y] + delta)


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    lights0 = [[0 for _ in range(1000)] for _ in range(1000)]
    lights1 = [[0 for _ in range(1000)] for _ in range(1000)]

    for line in [line.rstrip("\n") for line in lines]:
        p0, p1 = get_coordinates(line=line)

        if line.startswith("turn on"):
            turn(lights=lights0, on=True, p0=p0, p1=p1)
            change_brightness(lights=lights1, delta=1, p0=p0, p1=p1)
        elif line.startswith("turn off"):
            turn(lights=lights0, on=False, p0=p0, p1=p1)
            change_brightness(lights=lights1, delta=-1, p0=p0, p1=p1)
        elif line.startswith("toggle"):
            toggle(lights=lights0, p0=p0, p1=p1)
            change_brightness(lights=lights1, delta=2, p0=p0, p1=p1)

    print(f"{input_type:>6} Part 1: {sum(sum(row) for row in lights0)}")
    print(f"{input_type:>6} Part 2: {sum(sum(row) for row in lights1)}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day=day, input_path=input_path, input_type="Test")
    main(day=day, input_path=input_path, input_type="Puzzle")
