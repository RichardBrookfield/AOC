from pathlib import PurePath


def mix(numbers, number):
    value = int(number.rstrip("x"))
    new_index = numbers.index(number) + value

    numbers.remove(number)
    new_index %= len(numbers)

    return numbers[:new_index] + [number] + numbers[new_index:]


def get_digit(numbers, offset):
    zero_index = numbers.index("0")
    return int(numbers[(zero_index + offset) % (len(numbers))].rstrip("x"))


def get_digits(numbers):
    return (
        get_digit(numbers, 1000) + get_digit(numbers, 2000) + get_digit(numbers, 3000)
    )


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    numbers_part1 = []
    numbers_part2 = []

    for line in lines:
        line_part1 = line.rstrip("\n")
        line_part2 = str(int(line_part1) * 811589153)

        # Some numbers appear more than once in the input...
        while line_part1 in numbers_part1:
            line_part1 += "x"
        numbers_part1.append(line_part1)

        while line_part2 in numbers_part2:
            line_part2 += "x"
        numbers_part2.append(line_part2)

    mixed_part1 = numbers_part1.copy()
    mixed_part2 = numbers_part2.copy()

    for n in range(len(numbers_part1)):
        mixed_part1 = mix(mixed_part1, numbers_part1[n])

    for _ in range(10):
        for n in range(len(numbers_part1)):
            mixed_part2 = mix(mixed_part2, numbers_part2[n])

    digit_sum_part1 = get_digits(mixed_part1)
    digit_sum_part2 = get_digits(mixed_part2)

    print(f"{input_type:>6} Part 1: {digit_sum_part1}")
    print(f"{input_type:>6} Part 2: {digit_sum_part2}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
