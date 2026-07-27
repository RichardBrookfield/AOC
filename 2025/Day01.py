from pathlib import PurePath


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    dial = 50
    zero_hits = 0
    zero_passed = 0

    for line in [line.rstrip("\n") for line in lines]:
        sign = 1 if line[0] == "R" else -1
        amount = int(line[1:])

        if amount >= 100:
            zero_passed += amount // 100
            amount %= 100

        new_dial = dial + sign * amount

        if new_dial >= 100:
            new_dial -= 100
            zero_passed += 1
        elif new_dial < 0:
            new_dial += 100
            if dial != 0:
                zero_passed += 1
        elif new_dial == 0 and sign == -1:
            zero_passed += 1

        if (dial := new_dial) == 0:
            zero_hits += 1

    print(f"{input_type:>6} Part 1: {zero_hits}")
    print(f"{input_type:>6} Part 2: {zero_passed}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
