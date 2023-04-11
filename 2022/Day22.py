from pathlib import PurePath


def bounds_mapping(max_rows):
    # Basically, as an array (for ease), the following items to map one edge to
    # the corresponding edge elsewhere, 5 edges are adjacent in the net,
    # leaving 7 to be mapped.  If done carefully we can search it "backwards".
    #
    # x1, y1, x2, y2 - source line (x1==x2 or y1==y2, and x1<=x2 and y1<=y2)
    # source direction (since some internal corners are ambiguous)
    # x3, y3, x4, y4 - target line (x and y equal etc., but x4<=x3 possible)
    # target direction
    #
    # Directions: 0=R, 1=D, 2=L, 3=U
    if max_rows == 12:
        # Start with the top edge and work clockwise round.
        return [
            [-1, 8, -1, 11, 3, 4, 3, 4, 0, 1],
            [0, 12, 3, 12, 0, 11, 15, 11, 12, 2],
            [4, 12, 7, 12, 0, 8, 15, 8, 12, 1],
            [12, 12, 12, 15, 1, 0, 7, 0, 4, 0],
            [12, 8, 12, 11, 1, 7, 3, 7, 0, 3],
            [8, 8, 11, 8, 2, 7, 7, 7, 4, 3],
            [3, 4, 3, 7, 3, 0, 8, 3, 8, 0],
        ]
    else:
        # And the puzzle mapping is completely different, not even scaled...
        return [
            [-1, 50, -1, 99, 3, 150, 0, 199, 0, 0],
            [-1, 100, -1, 149, 3, 199, 0, 199, 49, 3],
            [0, 150, 49, 150, 0, 149, 99, 100, 99, 2],
            [50, 100, 50, 149, 1, 50, 99, 99, 99, 2],
            [150, 50, 150, 99, 1, 150, 49, 199, 49, 2],
            [100, -1, 149, -1, 2, 49, 50, 0, 50, 0],
            [99, 0, 99, 49, 3, 50, 50, 99, 50, 0],
        ]


def in_range(value, start, end):
    return start <= value <= end if start <= end else end <= value <= start


def opposite(direction):
    return (direction + 2) % 4


def get_mapped_position(position, direction, max_row):
    mapping = bounds_mapping(max_row)

    for m in mapping:
        if (
            m[0] <= position[0] <= m[2]
            and m[1] <= position[1] <= m[3]
            and direction == m[4]
        ):
            offset = position[0] - m[0] if m[1] == m[3] else position[1] - m[1]

            # Does the varying range run backwards?
            if m[7] < m[5] or m[8] < m[6]:
                offset = -offset

            if m[5] == m[7]:
                position[0] = m[5]
                position[1] = m[6] + offset
            else:
                position[0] = m[5] + offset
                position[1] = m[6]

            direction = m[9]
            return position, direction

        # More care with mapping the other way...
        # Work out the "slightly outside" location.
        if m[5] == m[7]:
            drow = 1 if m[9] == 1 else -1
            dcol = 0
        else:
            drow = 0
            dcol = 1 if m[9] == 0 else -1

        if (
            in_range(position[0] + drow, m[5], m[7] + drow)
            and in_range(position[1] + dcol, m[6], m[8] + dcol)
            and direction == opposite(m[9])
        ):
            # Ensure the offset is positive, despite the range
            offset = (
                abs(m[5] - position[0]) if m[6] == m[8] else abs(m[6] - position[1])
            )

            # The start positions are already "off-board"
            if m[0] == m[2]:
                position[0] = m[0] + (1 if m[4] == 3 else -1)
                position[1] = m[1] + offset
            else:
                position[0] = m[0] + offset
                position[1] = m[1] + (1 if m[4] == 2 else -1)

            direction = opposite(m[4])
            return position, direction

    # If we got here, it's not good...
    assert False


def follow_path(board, max_row, max_column, path, start_column, iscube):
    moves = [[0, 1], [1, 0], [0, -1], [-1, 0]]

    position = [0, start_column]
    direction = 0
    turning = False

    while path:
        item = path[0]

        if turning:
            direction += 1 if item == "R" else -1
            direction %= 4
        else:
            while item:
                new = [
                    position[0] + moves[direction][0],
                    position[1] + moves[direction][1],
                ]
                next_direction = direction

                if iscube:
                    off_board = False

                    if (
                        0 <= new[0] < max_row
                        and 0 <= new[1] < max_column
                        and board[new[0]][new[1]] == 0
                    ):
                        off_board = True

                    if not 0 <= new[0] < max_row or not 0 <= new[1] < max_column:
                        off_board = True

                    if off_board:
                        new, next_direction = get_mapped_position(
                            new, direction, max_row
                        )
                else:
                    new[0] %= max_row
                    new[1] %= max_column

                    while board[new[0]][new[1]] == 0:
                        new[0] = (new[0] + moves[direction][0]) % max_row
                        new[1] = (new[1] + moves[direction][1]) % max_column

                if board[new[0]][new[1]] == 2:
                    break
                else:
                    item -= 1

                position = new
                direction = next_direction

        path = path[1:]
        turning = not turning

    return 1000 * (position[0] + 1) + 4 * (position[1] + 1) + direction


def print_board(board, position1=None, position2=None):
    print(f"Pos 1: {position1}   Pos 2: {position2}")

    for row in range(len(board)):
        line = ""

        for column in range(len(board[row])):
            value = board[row][column]

            if position1 and position1[0] == row and position1[1] == column:
                line += "1"
            elif position2 and position2[0] == row and position2[1] == column:
                line += "2"
            elif value == 1:
                line += "."
            elif value == 2:
                line += "#"
            else:
                line += " "

        print(f"{row:>2}: {line}")


def read_path(path: str):
    instructions = []

    length = 0

    while path:
        char = path[0]

        if char.isnumeric():
            length *= 10
            length += int(char)
        elif char in ("RL"):
            if length != 0:
                instructions.append(length)
                length = 0
            instructions.append(char)

        path = path[1:]

    if length != 0:
        instructions.append(length)

    return instructions


def read_board(lines, board, max_column):
    max_row = 0
    empty_row = [0] * max_column
    start_column = None

    for line in lines:
        line = line.rstrip("\n")

        if not line:
            continue

        if line[0] not in (" .#"):
            path = read_path(line)
            break

        board.append(empty_row.copy())

        for column in range(len(line)):
            char = line[column]

            if char == ".":
                if start_column is None and max_row == 0:
                    start_column = column

                board[max_row][column] = 1
            elif char == "#":
                board[max_row][column] = 2

        max_row += 1

    return path, max_row, start_column


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    board = []
    max_column = max([len(line) for line in lines])

    path, max_row, start_column = read_board(lines, board, max_column)

    result = follow_path(board, max_row, max_column, path, start_column, False)
    print(f"{input_type:>6} Part 1: {result}")

    result = follow_path(board, max_row, max_column, path, start_column, True)
    print(f"{input_type:>6} Part 2: {result}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
