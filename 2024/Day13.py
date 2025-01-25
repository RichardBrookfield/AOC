from pathlib import PurePath
from typing import Dict, List, Tuple

BUTTON_A = 0
BUTTON_B = 1
PRIZE = 2


def get_offsets(line: str) -> Tuple[int, int]:
    second_part = line.split(":")[1].strip()

    offsets = [int(p.strip()[2:]) for p in second_part.split(",")]

    return (offsets[0], offsets[1])


def find_machine_cost1(machine: List[Tuple[int, int]]) -> int:
    button_a = machine[BUTTON_A]
    button_b = machine[BUTTON_B]
    target = machine[PRIZE]

    a_presses = 0

    while True:
        a_x_offset = a_presses * button_a[0]
        a_y_offset = a_presses * button_a[1]

        if a_x_offset > target[0] or a_y_offset > target[1]:
            break

        b_presses = int((target[0] - a_x_offset) / button_b[0])

        if (
            a_x_offset + b_presses * button_b[0] == target[0]
            and a_y_offset + b_presses * button_b[1] == target[1]
        ):
            return 3 * a_presses + b_presses

        a_presses += 1

    return 0


def find_machine_cost2(machine: List[Tuple[int, int]]) -> int:
    """
    Assuming the generic simultaneous linear equations:
        ax + by = m
        cx + dy = n

    Where:
        x   number of button A presses
        y   number of button B presses
        a   button A offset for X
        b   button B offset for X
        m   target offset for X
        c   button A offset for Y
        d   button B offset for Y
        n   target offset for Y

    We can solve for y and get the following:

        y = (mc - na) / (bc - ad)

    Given y, we can rearrange the first equation to:

        x = (m - by) / a

    We just need to guard against the divisor being zero.
    """
    ADD_ON = 10000000000000

    button_a = machine[BUTTON_A]
    button_b = machine[BUTTON_B]
    target = (machine[PRIZE][0] + ADD_ON, machine[PRIZE][1] + ADD_ON)

    a = button_a[0]
    b = button_b[0]
    m = target[0]
    c = button_a[1]
    d = button_b[1]
    n = target[1]

    if b * c - a * d != 0:
        y = int((m * c - n * a) / (b * c - a * d))
        x = int((m - b * y) / a)

        # Confirm the original equations
        if a * x + b * y == m and c * x + d * y == n:
            return 3 * x + y

    return 0


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    lines = [line.strip("\n") for line in lines if len(line) > 1]

    machines: Dict[int, List[Tuple[int, int]]] = {}
    machine_count = int(len(lines) / 3)

    for m in range(machine_count):
        machines[m] = [
            get_offsets(lines[3 * m]),
            get_offsets(lines[3 * m + 1]),
            get_offsets(lines[3 * m + 2]),
        ]

    costs = [0, 0]

    for machine in machines.values():
        costs[0] += find_machine_cost1(machine)
        costs[1] += find_machine_cost2(machine)

    print(f"{input_type:>6} Part 1: {costs[0]}")
    print(f"{input_type:>6} Part 2: {costs[1]}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
