from pathlib import PurePath


def to_snafu(value: int):
    base = 5
    result = ""
    snafu_digits = "012=-"

    while value > 0:
        # Process the digits from right to left.
        digit = value % base

        if str(digit) in snafu_digits:
            # 0, 1, 2 are fine as is...
            new_digit = str(digit)
        else:
            # 3, 4 get wrapped around to -2, -1 so add the "carry"
            new_digit = snafu_digits[digit]
            value += base

        result = new_digit + result
        value = int(value / base)

    return result


def to_decimal(snafu: str) -> int:
    result = 0
    column = 1

    while snafu:
        result += column * (-2 + "=-012".index(snafu[-1:]))
        column *= 5
        snafu = snafu[:-1]

    return result


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    total = 0

    for line in lines:
        total += to_decimal(line.rstrip("\n"))

    print(f"{input_type:>6} Part 1: {to_snafu(total)}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
