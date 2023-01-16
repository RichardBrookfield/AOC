import os
import ast


# Tried this using sorted(... key=functools.cmp_to_key(compare))
# But is caused some sort of recursion issue.
# Simple selection sort.
def custom_sort(lines):
    for lowest in range(len(lines) - 1):
        lowest_offset = lowest

        for other in range(lowest + 1, len(lines)):
            if compare(lines[other], lines[lowest_offset]) < 0:
                lowest_offset = other

        if lowest_offset != lowest:
            lines[lowest], lines[lowest_offset] = \
                lines[lowest_offset], lines[lowest]


def compare(list1, list2):
    offset = 0

    for offset in range(min(len(list1), len(list2))):
        item1 = list1[offset]
        item2 = list2[offset]

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

            result = compare(item1, item2)

            if result != 0:
                return result

    if len(list1) < len(list2):
        return -1
    elif len(list1) > len(list2):
        return 1

    return 0


def main(day: int, input_type: str):
    with open(f'input/{input_type}/Day{str(day).zfill(2)}.txt', 'r') as f:
        lines = f.readlines()

    pair_index = 1
    index_total = 0
    list1_filled = False
    list1, list2, filled_lines = [], [], []

    for line in lines:
        line = line.rstrip('\n')

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

    print(f'{input_type:>6} Part 1: {index_total}')

    dividers = [[[2]], [[6]]]

    filled_lines.append(dividers[0])
    filled_lines.append(dividers[1])

    custom_sort(filled_lines)

    markers = [filled_lines.index(dividers[0]) + 1,
               filled_lines.index(dividers[1]) + 1]

    print(f'{input_type:>6} Part 2: {markers[0] * markers[1]}')


if __name__ == '__main__':
    day = int(os.path.basename(__file__)[3:5])

    main(day, 'Test')
    main(day, 'Puzzle')
