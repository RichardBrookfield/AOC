import os


def main(day: int, input_type: str):
    with open(f"input/{input_type}/Day{str(day).zfill(2)}.txt", "r") as f:
        lines = f.readlines()

    elves = []
    row = 0

    for line in lines:
        line = line.rstrip("\n")

        for column in [column for column in range(len(line)) if line[column] == "#"]:
            elves.append([row, column])

        row += 1

    neighbours = [
        [-1, -1],
        [-1, 0],
        [-1, 1],
        [0, -1],
        [0, 0],
        [0, 1],
        [1, -1],
        [1, 0],
        [1, 1],
    ]
    neighbours_in_round = [[0, 1, 2], [6, 7, 8], [0, 3, 6], [2, 5, 8]]
    movements_in_round = [[-1, 0], [1, 0], [0, -1], [0, 1]]
    round = 0

    while True:
        new_positions = []

        for e in range(len(elves)):
            new_position = None
            any_neighbours = False

            for r in range(4):
                mod_round = (round + r) % 4
                neighbour_set = neighbours_in_round[mod_round]
                neighbours_found = False

                for ns in range(len(neighbour_set)):
                    neighbour_position = [
                        elves[e][0] + neighbours[neighbour_set[ns]][0],
                        elves[e][1] + neighbours[neighbour_set[ns]][1],
                    ]
                    if neighbour_position in elves:
                        neighbours_found = True
                        any_neighbours = True
                        break

                if not neighbours_found and new_position is None:
                    new_position = [
                        elves[e][0] + movements_in_round[mod_round][0],
                        elves[e][1] + movements_in_round[mod_round][1],
                    ]

            if not any_neighbours or new_position is None:
                new_position = elves[e]

            new_positions.append(new_position)

        for e in range(len(elves)):
            if new_positions.count(new_positions[e]) > 1:
                for previous in [
                    previous
                    for previous in range(len(elves))
                    if new_positions[previous] == new_positions[e]
                ]:
                    new_positions[previous] = elves[previous]

        if elves == new_positions:
            break

        if round >= 50 and round % 10 == 0:
            different = len(
                [e for e in range(len(elves)) if new_positions[e] != elves[e]]
            )
            print(f"Progress: {round:>3} {different:>4}/{len(elves):>4}")

        elves = new_positions
        round += 1

        if round == 10:
            min_coords = elves[0].copy()
            max_coords = elves[0].copy()

            for e in elves:
                for c in range(2):
                    min_coords[c] = min(min_coords[c], e[c])
                    max_coords[c] = max(max_coords[c], e[c])

            bounded = (max_coords[0] - min_coords[0] + 1) * (
                max_coords[1] - min_coords[1] + 1
            ) - len(elves)

            print(f"{input_type:>6} Part 1: {bounded}")

    print(f"{input_type:>6} Part 2: {round + 1}")


if __name__ == "__main__":
    day = int(os.path.basename(__file__)[3:5])

    # Not the best - takes 10-15 mins to solve the puzzle.
    # Also not sure where the slowness is, or just poor strategy.
    main(day, "Test")
    main(day, "Puzzle")
