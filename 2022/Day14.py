from pathlib import PurePath


def read_layout(all_parts, lines):
    for line in lines:
        line = line.rstrip("\n")

        text_parts = line.split(" -> ")
        parts = []

        for part in text_parts:
            x, y = part.split(",")
            parts.append([int(x), int(y)])

        all_parts.append(parts)


def add_walls(cave, all_parts, max_x, max_y):
    for x in range(max_x):
        row = ["."] * (max_y + 1)
        cave.append(row)

    for parts in all_parts:
        for p in range(len(parts) - 1):
            from_x, from_y = parts[p][0], parts[p][1]
            to_x, to_y = parts[p + 1][0], parts[p + 1][1]

            if from_x > to_x:
                from_x, to_x = to_x, from_x
            if from_y > to_y:
                from_y, to_y = to_y, from_y

            cave[from_x][from_y] = "#"

            while not (from_x == to_x and from_y == to_y):
                from_x += 1 if to_x > from_x else 0
                from_y += 1 if to_y > from_y else 0
                cave[from_x][from_y] = "#"


def add_sand(cave, max_x: int, max_y: int) -> bool:
    x, y = 500, 0

    while cave[x][y] == ".":
        if cave[x][y + 1] == ".":
            y += 1
        elif cave[x - 1][y + 1] == ".":
            x -= 1
            y += 1
        elif cave[x + 1][y + 1] == ".":
            x += 1
            y += 1
        else:
            cave[x][y] = "o"
            return True

        if x + 1 >= max_x or y + 1 >= max_y:
            break

    return False


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    all_parts = []
    read_layout(all_parts, lines)

    all_x = [p[0] for p in [p for parts in all_parts for p in parts]]
    all_y = [p[1] for p in [p for parts in all_parts for p in parts]]
    max_x = max(all_x) + 80
    max_y = max(all_y) + 2

    cave = []
    add_walls(cave, all_parts, max_x, max_y)

    sand_added = 0

    while True:
        if add_sand(cave, max_x, max_y):
            sand_added += 1
        else:
            break

    print(f"{input_type:>6} Part 1: {sand_added}")

    for x in range(max_x):
        cave[x][max_y] = "#"

    while True:
        if add_sand(cave, max_x, max_y + 1):
            sand_added += 1
        else:
            break

    print(f"{input_type:>6} Part 2: {sand_added}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
