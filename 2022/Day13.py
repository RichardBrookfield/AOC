import ast
from pathlib import PurePath
from typing import Any, List


# Tried this using sorted(... key=functools.cmp_to_key(compare))
# But is caused some sort of recursion issue.
# Simple selection sort.
def custom_sort(lines: List[Any]):
    for lowest in range(len(lines) - 1):
        lowest_offset = lowest

        for other in range(lowest + 1, len(lines)):
            if compare(lines[other], lines[lowest_offset]) < 0:
                lowest_offset = other

        if lowest_offset != lowest:
            lines[lowest], lines[lowest_offset] = lines[lowest_offset], lines[lowest]


def compare2(list1: List[Any] | int, list2: List[Any] | int) -> int:
    if type(list1) == int and type(list2) == int:
        if list1 < list2:
            print(1, "\n", list1, "\n", list2)
            return -1
        elif list1 > list2:
            print(2, "\n", list1, "\n", list2)
            return 1

    list1_as_list = list1 if type(list1) == list else [list1]
    list2_as_list = list2 if type(list2) == list else [list2]

    for offset in range(min(len(list1_as_list), len(list2_as_list))):
        item1: List[Any] | int = list1_as_list[offset]
        item2: List[Any] | int = list2_as_list[offset]

        if type(item1) == int and type(item2) == int:
            if item1 < item2:
                print(3, "\n", list1, "\n", list2)
                return -1
            elif item1 > item2:
                print(4, "\n", list1, "\n", list2)
                return 1
        else:
            item1_as_list = []
            item2_as_list = []

            if type(item1) == int and type(item2) == list:
                item1_as_list = [item1]
                item2_as_list: List[Any] = item2
            elif type(item1) == list and type(item2) == int:
                item1_as_list: List[Any] = item1
                item2_as_list = [item2]

            result = compare(item1_as_list, item2_as_list)

            if result != 0:
                print(5, "\n", list1, "\n", list2)
                return result

    if len(list1_as_list) < len(list2_as_list):
        print(6, "\n", list1, "\n", list2)
        return -1
    elif len(list1_as_list) > len(list2_as_list):
        print(7, "\n", list1, "\n", list2)
        return 1

    # print(8, "\n", list1, "\n", list2)
    return 0


def compare(list1: List[Any], list2: List[Any]) -> int:
    offset = 0

    for offset in range(min(len(list1), len(list2))):
        item1: List[Any] | int = list1[offset]
        item2: List[Any] | int = list2[offset]

        if type(item1) == int and type(item2) == int:
            if list1[offset] < list2[offset]:
                return -1
            elif list1[offset] > list2[offset]:
                return 1
        else:
            if type(item1) == int and type(item2) == list:
                item1 = [item1]
            elif type(item1) == list and type(item2) == int:
                item2 = [item2]

            # result = compare(item1, item2)
            result = compare(
                item1 if type(item1) == list else [item1],
                item2 if type(item2) == list else [item2],
            )

            if result != 0:
                return result

    if len(list1) < len(list2):
        return -1
    elif len(list1) > len(list2):
        return 1

    return 0


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    pair_index = 1
    index_total = 0
    list1_filled = False
    list1: List[Any] = []
    list2: List[Any] = []
    filled_lines: List[Any] = []

    for line in lines:
        line = line.rstrip("\n")

        if not line:
            if compare(list1, list2) == -1:
                index_total += pair_index

            list1_filled = False
            pair_index += 1
            continue

        line_value = ast.literal_eval(line)

        if not list1_filled:
            list1 = line_value
            list1_filled = True
        else:
            list2 = line_value

        filled_lines.append(line_value)

    print(f"{input_type:>6} Part 1: {index_total}")

    dividers = [[[2]], [[6]]]

    filled_lines.append(dividers[0])
    filled_lines.append(dividers[1])

    custom_sort(filled_lines)

    markers = [filled_lines.index(dividers[0]) + 1, filled_lines.index(dividers[1]) + 1]

    print(f"{input_type:>6} Part 2: {markers[0] * markers[1]}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
