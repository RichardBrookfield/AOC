from pathlib import PurePath
from typing import Dict, List


# Two's complement for numbers from 0 to 65535 (16 bits)
def bitwise_not(value: int) -> int:
    return ~value & 0xFFFF


def process_instruction(line: str, registers: Dict[str, int]) -> bool:
    try:
        instruction, register = line.split(" -> ")
        instructions = instruction.split(" ")

        if len(instructions) == 1:
            if instructions[0].isnumeric():
                registers[register] = int(instructions[0])
            else:
                registers[register] = registers[instructions[0]]
        elif len(instructions) == 2:
            if instructions[0].isnumeric():
                registers[register] = bitwise_not(int(instructions[1]))
            else:
                registers[register] = bitwise_not(registers[instructions[1]])
        elif len(instructions) == 3:
            if instructions[0].isnumeric():
                operand1 = int(instructions[0])
            else:
                operand1 = registers[instructions[0]]

            if instructions[2].isnumeric():
                operand2 = int(instructions[2])
            else:
                operand2 = registers[instructions[2]]

            if instructions[1] == "AND":
                registers[register] = operand1 & operand2
            elif instructions[1] == "OR":
                registers[register] = operand1 | operand2
            elif instructions[1] == "LSHIFT":
                registers[register] = operand1 * pow(2, operand2)
            elif instructions[1] == "RSHIFT":
                registers[register] = operand1 // pow(2, operand2)
    except KeyError:
        return False

    return True


def process_instructions(
    lines: List[str], registers: Dict[str, int], output_register: str
) -> int:
    unprocessed_lines: List[str] = []

    lines_to_process = lines.copy()

    while lines_to_process:
        for line in [line.rstrip("\n") for line in lines_to_process]:
            if not process_instruction(line, registers):
                unprocessed_lines.append(line)

        lines_to_process = unprocessed_lines
        unprocessed_lines = []

    return registers[output_register]


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    registers: Dict[str, int] = {}

    output_register = "a" if input_type == "Puzzle" else "i"
    output_value = process_instructions(
        lines=lines, registers=registers, output_register=output_register
    )

    print(f"{input_type:>6} Part 1: {output_value}")

    if input_type == "Test":
        return

    registers.clear()
    registers["b"] = output_value
    lines = [line for line in lines if not line.endswith(" -> b\n")]
    output_value = process_instructions(
        lines=lines, registers=registers, output_register=output_register
    )

    print(f"{input_type:>6} Part 2: {output_value}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day=day, input_path=input_path, input_type="Test")
    main(day=day, input_path=input_path, input_type="Puzzle")
