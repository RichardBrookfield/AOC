from pathlib import PurePath
from typing import List

A = 0
B = 1
C = 2


def run(instructions: List[int], registers: List[int]) -> List[int]:
    pointer = 0
    output: List[int] = []

    while pointer < len(instructions):
        opcode = instructions[pointer]
        operand = instructions[pointer + 1]
        combo = operand if operand in [0, 1, 2, 3] else registers[operand - 4]

        if opcode == 0:
            registers[A] = int(registers[A] / 2**combo)
        elif opcode == 1:
            registers[B] ^= operand
        elif opcode == 2:
            registers[B] = combo % 8
        elif opcode == 3:
            if registers[A] != 0:
                pointer = operand
                continue
        elif opcode == 4:
            registers[B] ^= registers[C]
        elif opcode == 5:
            output.append(combo % 8)
        elif opcode == 6:
            registers[B] = int(registers[A] / 2**combo)
        elif opcode == 7:
            registers[C] = int(registers[A] / 2**combo)

        pointer += 2

    return output


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    lines = [line.strip("\n") for line in lines if len(line) > 1]

    instructions: List[int] = []
    registers = [0, 0, 0]

    for line in lines:
        if line.startswith("Register"):
            parts = line.split(" ")
            register = parts[1].strip(":")
            number = int(parts[2].strip())

            if register == "A":
                registers[A] = number
            elif register == "B":
                registers[B] = number
            else:
                registers[C] = number
        else:
            numbers = line.split(" ")[1]
            instructions = [int(n) for n in numbers.split(",")]

    output = run(instructions, registers)

    print(f"{input_type:>6} Part 1: {','.join([str(n) for n in output])}")

    if input_type == "Test":
        instructions = [0, 3, 5, 4, 3, 0]
        assert instructions == run(instructions, [117440, 0, 0])
    else:
        # The output is, broadly, an octal version of the input - but backwards and mapped slightly.
        # Need to construct the second part for most significant digits to least because the least
        # ones depend on the most.
        base: int = 8

        while len(run(instructions, [base, 0, 0])) < len(instructions):
            base *= 8

        answer: int = base

        offset = len(instructions) - 1

        while offset >= 0:
            # We need to remmber additions FOR EACH octal digit, in case of overflow.
            current_digit = (answer / base) % 8

            while True:
                if run(instructions, [answer, 0, 0])[offset] != instructions[offset]:
                    answer += base
                    current_digit += 1

                    if current_digit >= 8:
                        break
                else:
                    break

            # If we've carried to the "previous" digit, we need to go back and ensure
            # it's still correct, or find the next one.
            if current_digit == 8:
                offset += 1
                base *= 8
                continue

            base = int(base / 8)
            offset -= 1

        assert instructions == run(instructions, [answer, 0, 0])

        print(f"{input_type:>6} Part 2: {answer}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
