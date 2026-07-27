from pathlib import PurePath
from typing import Set


def valid_password(password: str) -> bool:
    # Check for forbidden characters
    if any(c in password for c in "iol"):
        return False

    # Check for at least two different pairs of repeated characters
    pairs: Set[str] = set()
    i = 0
    while i < len(password) - 1:
        if password[i] == password[i + 1]:
            pairs.add(password[i])
            i += 2  # Skip the next character as it's part of the pair
        else:
            i += 1

    if len(pairs) < 2:
        return False

    # Check for increasing straight of at least three characters
    for i in range(len(password) - 2):
        if ord(password[i]) == ord(password[i + 1]) - 1 == ord(password[i + 2]) - 2:
            return True

    return False


def increment_password(password: str) -> str:
    password_list = list(password)
    i = len(password_list) - 1

    while i >= 0:
        if password_list[i] == "z":
            password_list[i] = "a"
            i -= 1
        else:
            password_list[i] = chr(ord(password_list[i]) + 1)
            break

    return "".join(password_list)


def find_next_valid_password(password: str) -> str:
    password = increment_password(password=password)

    while not valid_password(password=password):
        password = increment_password(password=password)

    return password


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    password = ""

    for line in [line.rstrip("\n") for line in lines]:
        password = find_next_valid_password(password=line)
        print(f"{input_type:>6} Part 1: {password}")

    if input_type == "Test":
        return

    password = find_next_valid_password(password=password)
    print(f"{input_type:>6} Part 2: {password}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day=day, input_path=input_path, input_type="Test")
    main(day=day, input_path=input_path, input_type="Puzzle")
