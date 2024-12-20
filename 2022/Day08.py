from pathlib import PurePath
from typing import List, Tuple


def read_layout(lines: List[str]) -> Tuple[List[List[int]], List[List[bool]]]:
    tree_height: List[List[int]] = []
    tree_visible: List[List[bool]] = []

    line_length = len(lines[0].rstrip("\n"))
    all_false = [False] * line_length

    for _ in range(line_length):
        tree_height.append([])
        tree_visible.append(all_false.copy())

    row = 0

    for line in lines:
        for digit in line.rstrip("\n"):
            tree_height[row].append(int(digit))

        row += 1

    return tree_height, tree_visible


def mark_tree_visible(
    tree_height: List[List[int]],
    tree_visible: List[List[bool]],
    row: int,
    column: int,
    highest: int,
) -> int:
    if tree_height[row][column] > highest:
        highest = tree_height[row][column]
        tree_visible[row][column] = True

    return highest


def mark_all_visible(tree_height: List[List[int]], tree_visible: List[List[bool]]):
    maximum = len(tree_height)

    for row in range(maximum):
        highest = -1

        for column in range(maximum):
            highest = mark_tree_visible(tree_height, tree_visible, row, column, highest)

        highest = -1

        for column in range(maximum - 1, -1, -1):
            highest = mark_tree_visible(tree_height, tree_visible, row, column, highest)

    for column in range(maximum):
        highest = -1

        for row in range(maximum):
            highest = mark_tree_visible(tree_height, tree_visible, row, column, highest)

        highest = -1

        for row in range(maximum - 1, -1, -1):
            highest = mark_tree_visible(tree_height, tree_visible, row, column, highest)


def scan_tree_line(
    tree_height: List[List[int]],
    row_start: int,
    row_end: int,
    row_delta: int,
    column_start: int,
    column_end: int,
    column_delta: int,
) -> int:
    score = 0
    current_height = tree_height[row_start][column_start]

    if row_start == row_end or column_start == column_end:
        return score

    while True:
        score += 1
        row_start += row_delta
        column_start += column_delta

        if (
            tree_height[row_start][column_start] >= current_height
            or row_start == row_end
            or column_start == column_end
        ):
            break

    return score


def find_tree_score(tree_height: List[List[int]], row: int, column: int) -> int:
    maximum = len(tree_height)

    total_score = scan_tree_line(tree_height, row, maximum - 1, 1, column, maximum, 0)
    total_score *= scan_tree_line(tree_height, row, 0, -1, column, maximum, 0)
    total_score *= scan_tree_line(tree_height, row, maximum, 0, column, maximum - 1, 1)
    total_score *= scan_tree_line(tree_height, row, maximum, 0, column, 0, -1)

    return total_score


def find_all_scores(tree_height: List[List[int]]):
    maximum = len(tree_height)

    scenic_scores: List[List[int]] = []

    for row in range(maximum):
        scenic_scores.append([])

        for column in range(maximum):
            scenic_scores[row].append(find_tree_score(tree_height, row, column))

    return scenic_scores


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    tree_height, tree_visible = read_layout(lines)
    mark_all_visible(tree_height, tree_visible)

    visible = 0

    for row in range(len(tree_visible)):
        visible += len([t for t in tree_visible if t[row]])

    print(f"{input_type:>6} Part 1: {visible}")

    scenic_scores = find_all_scores(tree_height)
    best_score = 0

    for row in range(len(tree_visible)):
        row_score = max(scenic_scores[row])
        best_score = max(best_score, row_score)

    print(f"{input_type:>6} Part 2: {best_score}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
