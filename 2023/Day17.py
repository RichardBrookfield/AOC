from pathlib import PurePath
from typing import List


def new_position(x: int, y: int, history: str, loss: int) -> dict:
    return {"x": x, "y": y, "h": history, "l": loss}


def lowest_loss(
    grid: List[List[int]], rows: int, columns: int, depth: int, starting_loss: int
) -> int:
    previous_positions = {}
    positions = [new_position(0, 0, "---", 0)]
    end_key = f"{columns-1:>3}{rows-1:>3}"
    end_loss = starting_loss
    rounds = 0

    while positions:
        new_positions = []

        for position in positions:
            x = position["x"]
            y = position["y"]
            history = position["h"]
            loss = position["l"]

            next_positions = []

            # Attempt to go in each direction
            if history[-1] != "L" and history != "RRR" and x + 1 < columns:
                next_position = new_position(
                    x + 1, y, history[1:] + "R", loss + grid[y][x + 1]
                )
                next_positions.append(next_position)
            if history[-1] != "R" and history != "LLL" and x - 1 >= 0:
                next_position = new_position(
                    x - 1, y, history[1:] + "L", loss + grid[y][x - 1]
                )
                next_positions.append(next_position)
            if history[-1] != "D" and history != "UUU" and y > 0:
                next_position = new_position(
                    x, y - 1, history[1:] + "U", loss + grid[y - 1][x]
                )
                next_positions.append(next_position)
            if history[-1] != "U" and history != "DDD" and y + 1 < rows:
                next_position = new_position(
                    x, y + 1, history[1:] + "D", loss + grid[y + 1][x]
                )
                next_positions.append(next_position)

            # Check whether we've reached this point before (but in a better scenario)
            for np in next_positions:
                key = f"{np['x']:>3}{np['y']:>3}{np['h'][3-depth:][::-1]}"
                value = np["l"]

                if (
                    key in previous_positions
                    and previous_positions[key] <= value
                    or value > end_loss
                ):
                    continue

                if key[:6] == end_key and value < end_loss:
                    end_loss = value

                previous_positions[key] = value
                new_positions.extend([np.copy()])

        positions = new_positions.copy()
        rounds += 1

        if rounds % 40 == 0:
            print(
                f"Depth: {depth} Rounds: {rounds:>6} Pos: {len(positions):>6} Prev: {len(previous_positions):>6} Best: {end_loss:>6}"
            )

    return min([v for k, v in previous_positions.items() if k[:6] == end_key])


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    grid = []

    for line in lines:
        line = line.strip("\n")

        grid.append([int(c) for c in line])

    rows = len(grid)
    columns = len(grid[0])
    lowest = 5 * (rows + columns)

    for depth in range(4):
        lowest = lowest_loss(grid, rows, columns, depth, lowest)

    print(f"{input_type:>6} Part 1: {lowest}")
    print(f"{input_type:>6} Part 2: ")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
