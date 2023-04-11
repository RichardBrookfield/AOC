from pathlib import PurePath


def update_crt(crt, cycle, x):
    crt_characters = len(crt[0])

    crt_row_position = int(cycle / crt_characters)
    crt_character_position = cycle % crt_characters

    if abs(crt_character_position - x) <= 1:
        crt[crt_row_position][crt_character_position] = "#"


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    x, cycle, total = 1, 1, 0
    cycle_to_note, cycle_note_offset = 20, 40
    crt_rows, crt_characters = 6, 40

    crt = []

    for _ in range(crt_rows):
        crt.append(list("." * crt_characters))

    for line in lines:
        line = line.rstrip("\n")

        update_crt(crt, cycle - 1, x)

        # If it's this one or the next (noop or half an addx)
        if cycle <= cycle_to_note <= cycle + 1:
            total += cycle_to_note * x
            cycle_to_note += cycle_note_offset

        if line.startswith("noop"):
            cycle += 1
        else:
            update_crt(crt, cycle, x)
            cycle += 2
            x += int(line[5:])

    print(f"{input_type:>6} Part 1: {total}")

    for row in range(crt_rows):
        print(f'{input_type:>6} Part 2: {"".join(crt[row])}')


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
