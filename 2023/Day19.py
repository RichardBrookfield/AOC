from pathlib import PurePath
from typing import Dict, List


def process_part(part: Dict[str, int], rule: str, rules: Dict[str, List[str]]) -> str:
    instructions = rules[rule]
    # x = part["x"]
    # m = part["m"]
    # a = part["a"]
    # s = part["s"]

    for instruction in instructions:
        if ":" in instruction:
            parts = instruction.split(":")
            if eval(parts[0]):
                return parts[1]
        else:
            return instruction

    return ""


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    rules: Dict[str, List[str]] = {}
    parts: List[Dict[str, int]] = []
    xmas = "xmas"

    for line in lines:
        line = line.strip("\n")

        if not line:
            continue

        if line.startswith("{"):
            values = line[1:-1].split(",")
            part: Dict[str, int] = {}
            for i in range(4):
                part[xmas[i]] = int(values[i].split("=")[1])
            parts.append(part)
        else:
            position = line.find("{")
            rule_name = line[:position]
            instructions = line[position + 1 : -1].split(",")
            rules[rule_name] = instructions.copy()

    total = 0

    for part in parts:
        rule = "in"

        while True:
            rule = process_part(part, rule, rules)
            if rule == "A":
                total += part["x"] + part["m"] + part["a"] + part["s"]
            if rule in "AR":
                break

    print(f"{input_type:>6} Part 1: {total}")
    print(f"{input_type:>6} Part 2: ")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
