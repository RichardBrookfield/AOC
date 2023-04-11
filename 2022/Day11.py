from pathlib import PurePath
import copy
from math import floor


def process(monkeys, worry_reduced: bool, rounds: int):
    total_divisble = 1

    for m in monkeys:
        total_divisble *= m["Test"]

    for round in range(rounds):
        for monkey in monkeys:
            items = monkey["Items"]

            for item in items:
                monkey["Inspect"] += 1
                operand = item if monkey["Operand"] == 0 else monkey["Operand"]

                worry = item + operand if monkey["Operator"] == "+" else item * operand

                worry = floor(worry / 3) if worry_reduced else worry % total_divisble

                target = (
                    monkey["TrueTarget"]
                    if worry % monkey["Test"] == 0
                    else monkey["FalseTarget"]
                )

                monkeys[target]["Items"].append(worry)

            items.clear()


def product_highest_two(monkeys):
    descending = sorted([m["Inspect"] for m in monkeys])[-2:]
    return descending[0] * descending[1]


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    monkeys = []

    for line in lines:
        line = line.rstrip("\n")
        stripped = line.strip()

        if line.startswith("Monkey"):
            pass
        elif stripped.startswith("Starting items"):
            starting_strings = stripped.replace(",", "").split(" ")[2:]
            starting_items = [int(i) for i in starting_strings]
        elif stripped.startswith("Operation"):
            operator = stripped[21:22]
            operand_raw = stripped[23:]
            operand = 0 if operand_raw == "old" else int(operand_raw)
        elif stripped.startswith("Test"):
            divisible = int(stripped[19:])
        elif stripped.startswith("If true"):
            true_target = int(stripped[-1:])
        elif stripped.startswith("If false"):
            false_target = int(stripped[-1:])
            monkeys.append(
                {
                    "Items": starting_items,
                    "Operator": operator,
                    "Operand": operand,
                    "Test": divisible,
                    "TrueTarget": true_target,
                    "FalseTarget": false_target,
                    "Inspect": 0,
                }
            )

    monkeys_part1 = copy.deepcopy(monkeys)
    monkeys_part2 = copy.deepcopy(monkeys)

    process(monkeys=monkeys_part1, worry_reduced=True, rounds=20)
    process(monkeys=monkeys_part2, worry_reduced=False, rounds=10000)

    print(f"{input_type:>6} Part 1: {product_highest_two(monkeys_part1)}")
    print(f"{input_type:>6} Part 2: {product_highest_two(monkeys_part2)}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
