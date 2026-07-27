from pathlib import PurePath


def at_least_3_vowels(s: str) -> bool:
    return sum(1 for c in s if c in "aeiou") >= 3


def has_double_letter(s: str) -> bool:
    return any(s[i] == s[i + 1] for i in range(len(s) - 1))


def has_no_bad_substrings(s: str) -> bool:
    return not any(sub in s for sub in ["ab", "cd", "pq", "xy"])


def has_repeated_pair(s: str) -> bool:
    return any(s[i : i + 2] in s[i + 2 :] for i in range(len(s) - 3))


def has_repeated_letter_with_one_gap(s: str) -> bool:
    return any(s[i] == s[i + 2] for i in range(len(s) - 2))


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    nice = [0, 0]

    for line in [line.rstrip("\n") for line in lines]:
        if (
            at_least_3_vowels(s=line)
            and has_double_letter(s=line)
            and has_no_bad_substrings(s=line)
        ):
            nice[0] += 1

        if has_repeated_pair(s=line) and has_repeated_letter_with_one_gap(s=line):
            nice[1] += 1

    print(f"{input_type:>6} Part 1: {nice[0]}")
    print(f"{input_type:>6} Part 2: {nice[1]}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day=day, input_path=input_path, input_type="Test")
    main(day=day, input_path=input_path, input_type="Puzzle")
