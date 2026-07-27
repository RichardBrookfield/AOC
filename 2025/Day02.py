from pathlib import PurePath
from typing import List, Set, Tuple


def check_range(low: int, high: int) -> Tuple[List[int], List[int]]:
    low_length = len(str(low))

    # Split into multiple ranges of equal numbers of digits
    if low_length != len(str(high)):
        low_end = int("9" * low_length)

        low_half, low_full = check_range(low, low_end)
        high_half, high_full = check_range(low_end + 1, high)

        return low_half + high_half, low_full + high_full

    results_half: List[int] = []
    results_full: List[int] = []

    for parts in [
        parts for parts in range(2, low_length + 1) if low_length % parts == 0
    ]:
        part_length = low_length // parts

        for part_number in range(
            int(str(low)[:part_length]), int(str(high)[:part_length]) + 1
        ):
            full_number = int(str(part_number) * parts)

            if low <= full_number <= high:
                if parts == 2:
                    results_half.append(full_number)

                results_full.append(full_number)

    return results_half, results_full


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    half_answers: Set[int] = set()
    full_answers: Set[int] = set()

    for line in [line.rstrip("\n") for line in lines]:

        for number_range in line.split(","):
            low, high = [int(x) for x in number_range.split("-")]

            double_result, full_result = check_range(low, high)

            half_answers.update(double_result)
            full_answers.update(full_result)

    print(f"{input_type:>6} Part 1: {sum(half_answers)}")
    print(f"{input_type:>6} Part 2: {sum(full_answers)}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
