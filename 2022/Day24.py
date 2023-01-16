import os


def main(day: int, input_type: str):
    with open(f'input/{input_type}/Day{str(day).zfill(2)}.txt', 'r') as f:
        lines = f.readlines()

    max_row = len(lines)
    max_column = len(lines[0]) - 1
    route = []
    blizzards = []
    directions = []
    row = 0

    for line in lines:
        line = line.rstrip('\n')

        for column in range(len(line)):
            pos = [row, column]
            char = line[column]

            if row == 0:
                if char == '.':
                    route.append(pos)
            elif row == len(lines) - 1:
                if char == '.':
                    route.append(pos)
            elif char == '#':
                pass
            elif char != '.':
                blizzards.append(pos)

                if char == '<':
                    directions.append([0, -1])
                elif char == '>':
                    directions.append([0, 1])
                elif char == '^':
                    directions.append([-1, 0])
                else:
                    directions.append([1, 0])

        row += 1

    round = 0
    explorer_positions = set()
    movements = [[-1, 0], [0, -1], [0, 0], [1, 0], [0, 1]]

    # 0=->end1, 1=end1, 2=start<-, 3=start, 4=->end2, 5=end2
    route_phase = 0
    explorer_positions.add(tuple(route[0]))

    while route_phase < 5:
        for b in range(len(blizzards)):
            new_position = [
                blizzards[b][0] + directions[b][0],
                blizzards[b][1] + directions[b][1],
            ]

            # Basically a modulus on a range from 1 to (n-1)...
            new_position[0] = ((new_position[0] - 1) % (max_row - 2)) + 1
            new_position[1] = ((new_position[1] - 1) % (max_column - 2)) + 1

            blizzards[b] = new_position

        round += 1
        new_positions = set()

        for ep in explorer_positions:
            for m in movements:
                new_position = [ep[0] + m[0], ep[1] + m[1]]

                if new_position == route[1]:
                    if route_phase == 0:
                        print(f'{input_type:>6} Part 1: {round}')
                        route_phase += 1
                    elif route_phase == 4:
                        print(f'{input_type:>6} Part 2: {round}')
                        route_phase += 1

                if new_position == route[0]:
                    if route_phase == 2:
                        route_phase += 1

                if 1 <= new_position[0] < max_row - 1 and \
                        1 <= new_position[1] < max_column - 1 and \
                        new_position not in blizzards or \
                        new_position in route:
                    new_positions.add(tuple(new_position))

        if route_phase == 1:
            explorer_positions.clear()
            explorer_positions.add(tuple(route[1]))
            route_phase += 1
        elif route_phase == 3:
            explorer_positions.clear()
            explorer_positions.add(tuple(route[0]))
            route_phase += 1
        else:
            explorer_positions = new_positions

        if round >= 50 and round % 20 == 0:
            positions = len(explorer_positions)
            print(f'Progress: {round:>4} {route_phase} {positions}')


if __name__ == '__main__':
    day = int(os.path.basename(__file__)[3:5])

    main(day, 'Test')
    main(day, 'Puzzle')
