from pathlib import PurePath


def ground_height(ground):
    return max([g[0] for g in ground]) if ground else 0


# Trim off the lower levels to keep it fast.
def trim_ground(ground, margin):
    max_height = ground_height(ground)

    for g in [g for g in ground if g[0] < max_height - margin]:
        ground.remove(g)

    return max_height - margin


def drop_rock(ground, directions, rock, direction, level):
    max_row = ground_height(ground) if ground else -1
    start_row = max_row + 4 - rock[1]

    rock_coords = []

    for c in rock[0]:
        rock_coords.append([c[0] + start_row, c[1] + 2])

    while True:
        # Left-right movement first
        column_offset = 1 if directions[direction] == ">" else -1
        direction = (direction + 1) % len(directions)

        new_coords = []
        for rc in rock_coords:
            new_coords.append([rc[0], rc[1] + column_offset])

        clashes = False

        for nc in new_coords:
            if nc in ground or nc[1] < 0 or nc[1] > 6:
                clashes = True
                break

        if not clashes:
            rock_coords = new_coords

        # Then falling...
        new_coords = []

        for rc in rock_coords:
            new_coords.append([rc[0] - 1, rc[1]])

        clashes = False

        for nc in new_coords:
            if nc[0] < 0 or nc in ground:
                clashes = True
                break

            # Check that we've not trimmed too much
            assert nc[0] > level

        if clashes:
            for rc in rock_coords:
                ground.append(rc)
            break
        else:
            rock_coords = new_coords

    return direction


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    # Array of offsets from the leftmost, the lowest row second item.
    rocks = [
        [[[0, 0], [0, 1], [0, 2], [0, 3]], 0],
        [[[0, 0], [-1, 1], [0, 1], [1, 1], [0, 2]], -1],
        [[[0, 0], [0, 1], [0, 2], [1, 2], [2, 2]], 0],
        [[[0, 0], [1, 0], [2, 0], [3, 0]], 0],
        [[[0, 0], [0, 1], [1, 0], [1, 1]], 0],
    ]
    directions = []
    ground = []
    total_rocks = len(rocks)

    for line in lines:
        line = line.rstrip("\n")
        directions = line

    zero_point = 0
    level = -1
    rock_count = 0
    direction = 0
    height_offset = 0
    rock_limit_start = max(2022, total_rocks * len(directions))
    rock_limit_part2 = 1000000000000

    while rock_count <= rock_limit_part2:
        direction = drop_rock(
            ground, directions, rocks[rock_count % total_rocks], direction, level
        )
        rock_count += 1

        # After a decent number of rocks make a note of where we are on the "first" rock,
        # then wait for that timing to happen again
        if rock_count > rock_limit_start and rock_count % total_rocks == 0:
            if zero_point == 0:
                # First time, make a note
                saved_height = ground_height(ground)
                saved_rock_count = rock_count
                saved_direction = direction
                zero_point += 1
            elif zero_point == 1 and direction == saved_direction:
                # Second time, work out how much to add onto final total
                height_delta = ground_height(ground) - saved_height
                rock_count_delta = rock_count - saved_rock_count

                deltas = int((rock_limit_part2 - rock_count) / rock_count_delta)
                height_offset = deltas * height_delta
                rock_count += deltas * rock_count_delta
                zero_point += 1

        if rock_count % 10000 == 0:
            print(f"Progress: {rock_count:>4}")

        if rock_count == 2022:
            print(f"{input_type:>6} Part 1: {ground_height(ground) + 1}")

        if rock_count % 100 == 0:
            level = trim_ground(ground, 50)

    print(f"{input_type:>6} Part 2: {ground_height(ground) + height_offset}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
