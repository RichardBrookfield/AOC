from pathlib import PurePath


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    cubes = []

    for line in lines:
        line = line.rstrip("\n")

        x, y, z = [int(value) for value in line.split(",")]
        cubes.append([x, y, z])

    cube_count = len(cubes)
    adjacent = 0

    # Find adjacent cubes in specific axis direction, eliminating duplication.
    positive_offsets = [[1, 0, 0], [0, 1, 0], [0, 0, 1]]

    for cube in cubes:
        for po in positive_offsets:
            delta_cube = [cube[0] + po[0], cube[1] + po[1], cube[2] + po[2]]

            if delta_cube in cubes:
                adjacent += 1

    exposed = cube_count * 6 - adjacent * 2

    print(f"{input_type:>6} Part 1: {exposed}")

    min_coord = [cubes[0][0], cubes[0][1], cubes[0][2]]
    max_coord = [cubes[0][0], cubes[0][1], cubes[0][2]]

    for i in range(1, cube_count):
        for j in range(3):
            min_coord[j] = min(min_coord[j], cubes[i][j])
            max_coord[j] = max(max_coord[j], cubes[i][j])

    for i in range(3):
        min_coord[i] -= 1
        max_coord[i] += 1

    adjacent_offsets = [
        [1, 0, 0],
        [0, 1, 0],
        [0, 0, 1],
        [-1, 0, 0],
        [0, -1, 0],
        [0, 0, -1],
    ]

    flood_fill = []
    new_items = [[min_coord[0], min_coord[1], min_coord[2]]]
    newest_items = []

    while len(new_items) != 0:
        for ni in new_items:
            for ao in adjacent_offsets:
                new_position = [ni[0] + ao[0], ni[1] + ao[1], ni[2] + ao[2]]
                outside = False

                for i in range(3):
                    if new_position[i] < min_coord[i] or new_position[i] > max_coord[i]:
                        outside = True
                        break

                if (
                    outside
                    or new_position in cubes
                    or new_position in flood_fill
                    or new_position in newest_items
                ):
                    continue

                newest_items.append(new_position)

        # The logic here shouldn't be needed, but it makes the code
        # work.  Should come back to this and try to solve it.
        for i in [i for i in new_items if i not in flood_fill]:
            flood_fill.append(i)

        new_items = newest_items.copy()
        newest_items.clear()

    flood_adjacent = 0

    for cube in cubes:
        for ao in adjacent_offsets:
            delta_cube = [cube[0] + ao[0], cube[1] + ao[1], cube[2] + ao[2]]

            if delta_cube in flood_fill:
                flood_adjacent += 1

    print(f"{input_type:>6} Part 2: {flood_adjacent}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
