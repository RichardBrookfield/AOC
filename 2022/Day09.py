import os


def adjust_tail(rope, positions, offset):
    if offset >= len(rope):
        return

    delta_x = rope[offset - 1]['x'] - rope[offset]['x']
    delta_y = rope[offset - 1]['y'] - rope[offset]['y']
    one_x = 0 if delta_x == 0 else int(delta_x / abs(delta_x))
    one_y = 0 if delta_y == 0 else int(delta_y / abs(delta_y))

    # Diagonal move
    if abs(delta_x) > 0 and abs(delta_y) > 0 and \
            abs(delta_x) + abs(delta_y) > 2:
        rope[offset].update(
            x=rope[offset]['x'] + one_x,
            y=rope[offset]['y'] + one_y)
    # Diagonal distance = 1, no move
    elif abs(delta_x) == 1 and abs(delta_y) == 1:
        return
    # X direction only
    elif abs(delta_x) > 1:
        rope[offset].update(x=rope[offset]['x'] + one_x)
    # Y direction only
    elif abs(delta_y) > 1:
        rope[offset].update(y=rope[offset]['y'] + one_y)
    # No significant gap, no move
    else:
        return

    # If there was a move, continue down to the next part
    adjust_tail(rope, positions, offset + 1)

    # Make a note of position
    positions[offset].add(f"{rope[offset]['x']},{rope[offset]['y']}")


def main(day: int, input_type: str, snake_size: int, suffix: str = ''):
    filename = f'input/{input_type}/Day{str(day).zfill(2)}{suffix}.txt'

    with open(filename, 'r') as f:
        lines = f.readlines()

    coordinate = {'x': 0, 'y': 0}
    rope = []
    positions = []

    for i in range(snake_size):
        rope.append(coordinate.copy())
        positions.append(set())
        positions[i].add('0,0')

    for line in lines:
        line = line.rstrip('\n')

        direction = line[0:1]
        distance = int(line[2:])

        while distance > 0:
            # Move head by 1
            if direction == 'U':
                rope[0].update(y=rope[0]['y'] + 1)
            elif direction == 'D':
                rope[0].update(y=rope[0]['y'] - 1)
            elif direction == 'R':
                rope[0].update(x=rope[0]['x'] + 1)
            else:
                rope[0].update(x=rope[0]['x'] - 1)

            adjust_tail(rope, positions, 1)

            distance -= 1

    print(f'{input_type:>6}{suffix:>2} Part 1: {len(positions[1])}')

    if snake_size > 2:
        print(f'{input_type:>6}{suffix:>2} Part 2: {len(positions[9])}')


if __name__ == '__main__':
    day = int(os.path.basename(__file__)[3:5])

    main(day, 'Test', 2, '-1')
    main(day, 'Test', 10, '-2')
    main(day, 'Puzzle', 10)
