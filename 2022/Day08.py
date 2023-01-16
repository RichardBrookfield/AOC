import os


def read_layout(lines):
    tree_height = []
    tree_visible = []

    line_length = len(lines[0].rstrip('\n'))
    all_false = [False] * line_length

    for i in range(line_length):
        tree_height.append(list())
        tree_visible.append(all_false.copy())

    row = 0

    for line in lines:
        for digit in line.rstrip('\n'):
            tree_height[row].append(int(digit))

        row += 1

    return tree_height, tree_visible


def mark_tree_visible(tree_height, tree_visible, row, column, highest):
    if tree_height[row][column] > highest:
        highest = tree_height[row][column]
        tree_visible[row][column] = True
    return highest


def mark_all_visible(tree_height, tree_visible):
    maximum = len(tree_height)

    for row in range(maximum):
        highest = -1

        for column in range(maximum):
            highest = mark_tree_visible(
                tree_height, tree_visible, row, column, highest)

        highest = -1

        for column in range(maximum-1, -1, -1):
            highest = mark_tree_visible(
                tree_height, tree_visible, row, column, highest)

    for column in range(maximum):
        highest = -1

        for row in range(maximum):
            highest = mark_tree_visible(
                tree_height, tree_visible, row, column, highest)

        highest = -1

        for row in range(maximum-1, -1, -1):
            highest = mark_tree_visible(
                tree_height, tree_visible, row, column, highest)


def scan_tree_line(tree_height, row_start, row_end, row_delta,
                   column_start, column_end, column_delta):
    score = 0
    current_height = tree_height[row_start][column_start]

    if row_start == row_end or column_start == column_end:
        return score

    while True:
        score += 1
        row_start += row_delta
        column_start += column_delta

        if tree_height[row_start][column_start] >= current_height or \
                row_start == row_end or column_start == column_end:
            break

    return score


def find_tree_score(tree_height, row, column):
    maximum = len(tree_height)

    total_score = scan_tree_line(
        tree_height, row, maximum - 1, 1, column, maximum, 0)
    total_score *= scan_tree_line(
        tree_height, row, 0, -1, column, maximum, 0)
    total_score *= scan_tree_line(
        tree_height, row, maximum, 0, column, maximum - 1, 1)
    total_score *= scan_tree_line(
        tree_height, row, maximum, 0, column, 0, -1)

    return total_score


def find_all_scores(tree_height):
    maximum = len(tree_height)

    scenic_scores = []

    for row in range(maximum):
        scenic_scores.append(list())

        for column in range(maximum):
            scenic_scores[row].append(
                find_tree_score(tree_height, row, column))

    return scenic_scores


def main(day: int, input_type: str):
    with open(f'input/{input_type}/Day{str(day).zfill(2)}.txt', 'r') as f:
        lines = f.readlines()

    tree_height, tree_visible = read_layout(lines)
    mark_all_visible(tree_height, tree_visible)

    visible = 0

    for row in range(len(tree_visible)):
        visible += len([t for t in tree_visible if t[row]])

    print(f'{input_type:>6} Part 1: {visible}')

    scenic_scores = find_all_scores(tree_height)
    best_score = 0

    for row in range(len(tree_visible)):
        row_score = max(scenic_scores[row])
        best_score = max(best_score, row_score)

    print(f'{input_type:>6} Part 2: {best_score}')


if __name__ == '__main__':
    day = int(os.path.basename(__file__)[3:5])

    main(day, 'Test')
    main(day, 'Puzzle')
