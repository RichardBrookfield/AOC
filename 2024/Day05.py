from pathlib import PurePath
from typing import List


def check_update(update: List[int], rules: List[List[int]]) -> bool:
    for rule in rules:
        index0 = update.index(rule[0]) if rule[0] in update else None
        index1 = update.index(rule[1]) if rule[1] in update else None

        if index0 is not None and index1 is not None and index0 > index1:
            return False

    return True


def correct_update(original_update: List[int], rules: List[List[int]]) -> List[int]:
    problems = True
    update = original_update.copy()

    while problems:
        problems = False

        for rule in rules:
            index0 = update.index(rule[0]) if rule[0] in update else None
            index1 = update.index(rule[1]) if rule[1] in update else None

            if index0 is not None and index1 is not None and index0 > index1:
                update[index0], update[index1] = update[index1], update[index0]
                problems = True

    return update


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    rules: List[List[int]] = []
    updates: List[List[int]] = []
    collecting_rules = True

    for line in lines:
        line = line.strip("\n")

        if len(line) == 0:
            collecting_rules = False
            continue

        if collecting_rules:
            numbers = [int(number) for number in line.split("|")]
            rules.append(numbers)
        else:
            pages = [int(page) for page in line.split(",")]
            updates.append(pages)

    total = [0, 0]

    for update in updates:
        if check_update(update, rules):
            total[0] += update[int((len(update) - 1) / 2)]
        else:
            new_update = correct_update(update, rules)
            total[1] += new_update[int((len(new_update) - 1) / 2)]

    print(f"{input_type:>6} Part 1: {total[0]}")
    print(f"{input_type:>6} Part 2: {total[1]}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
