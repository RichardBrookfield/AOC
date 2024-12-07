import copy
from pathlib import PurePath
from typing import List


def add_crates(stacks: List[List[str]], line: str):
    current_stack = 0

    while len(line) >= 3:
        if line[0] == "[":
            stacks[current_stack].insert(0, line[1])
        line = line[4:]
        current_stack += 1

    return stacks


def move_crates(stacks: List[List[str]], line: str, singles: bool) -> List[List[str]]:
    # Parse the line, our stacks are zero-based
    moves = line.split(" ")
    crates = int(moves[1])
    from_stack, to_stack = int(moves[3]) - 1, int(moves[5]) - 1

    # Grab what needs to be copied, remove, re-add
    if singles:
        for _ in range(crates):
            stacks[to_stack] += stacks[from_stack].pop()
    else:
        stacks[to_stack] += stacks[from_stack][-crates:]
        stacks[from_stack] = stacks[from_stack][0:-crates]

    return stacks


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    stacks_part1: List[List[str]] = []
    stacks_part2: List[List[str]] = []

    for _ in range(int((len(lines[0]) + 1) / 4)):
        stacks_part1.append([])

    for line in lines:
        line = line.rstrip("\n")

        if line.startswith(" 1 "):
            pass
        elif not line:
            # At the crossover point copy to second set
            stacks_part2 = copy.deepcopy(stacks_part1)
        elif line.startswith("move"):
            stacks_part1 = move_crates(stacks_part1, line, singles=True)
            stacks_part2 = move_crates(stacks_part2, line, singles=False)
        else:
            # Build the stacks just on first set
            stacks_part1 = add_crates(stacks_part1, line)

    top_of_stacks1 = "".join([stack[-1] for stack in stacks_part1])
    top_of_stacks2 = "".join([stack[-1] for stack in stacks_part2])

    print(f"{input_type:>6} Part 1: {top_of_stacks1}")
    print(f"{input_type:>6} Part 2: {top_of_stacks2}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
