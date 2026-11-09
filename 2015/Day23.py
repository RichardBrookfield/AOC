from dataclasses import dataclass
from pathlib import PurePath


@dataclass
class Instruction:
    name: str
    register: str
    offset: int


Instructions = list[Instruction]
Registers = dict[str, int]


def process_instruction(instruction: Instruction, registers: Registers) -> int:
    offset = 1

    if instruction.name == "hlf":
        registers[instruction.register] //= 2
    elif instruction.name == "tpl":
        registers[instruction.register] *= 3
    elif instruction.name == "inc":
        registers[instruction.register] += 1
    elif (
        instruction.name == "jmp"
        or instruction.name == "jie"
        and registers[instruction.register] % 2 == 0
        or instruction.name == "jio"
        and registers[instruction.register] == 1
    ):
        offset = instruction.offset

    return offset


def process_instructions(instructions: Instructions, registers: Registers) -> None:
    offset = 0

    while 0 <= offset < len(instructions):
        offset += process_instruction(
            instruction=instructions[offset], registers=registers
        )


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    instructions: Instructions = []

    for line in [line.rstrip("\n") for line in lines]:
        parts = line.split()

        instruction = Instruction(name=parts[0], register="", offset=0)

        if instruction.name == "jmp":
            instruction.offset = int(parts[1])
        elif instruction.name.startswith("j"):
            instruction.register = parts[1].strip(",")
            instruction.offset = int(parts[2])
        else:
            instruction.register = parts[1]

        instructions.append(instruction)

    registers: Registers = {"a": 0, "b": 0}
    process_instructions(instructions=instructions, registers=registers)

    print(f"{input_type:>6} Part 1: {registers['b']}")

    registers = {"a": 1, "b": 0}
    process_instructions(instructions=instructions, registers=registers)

    print(f"{input_type:>6} Part 2: {registers['b']}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day=day, input_path=input_path, input_type="Test")
    main(day=day, input_path=input_path, input_type="Puzzle")
