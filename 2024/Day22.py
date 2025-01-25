from pathlib import PurePath
from typing import Dict, List, Set, Tuple


def next_secret(secret: int) -> int:
    new_secret = (secret ^ (secret * 64)) % 16777216
    new_secret = (new_secret ^ int(new_secret / 32)) % 16777216
    new_secret = (new_secret ^ (new_secret * 2048)) % 16777216

    return new_secret


def find_total_secrets(lines: List[str]) -> int:
    total = 0

    for line in lines:
        secret = int(line)

        for _ in range(2000):
            secret = next_secret(secret)

        total += secret

    return total


def diff(secret0: int, secret1: int) -> int:
    return (secret1 % 10) - (secret0 % 10)


def find_best_sequence(lines: List[str]) -> int:
    all_secrets: List[List[int]] = []

    for line in lines:
        secrets: List[int] = []

        secret = int(line)
        secrets.append(secret)

        for _ in range(2000):
            secret = next_secret(secret)
            secrets.append(secret)

        all_secrets.append(secrets)

    all_price_sequences: List[Dict[Tuple[int, int, int, int], int]] = []

    for seller in range(len(all_secrets)):
        secrets = all_secrets[seller]
        sequences: Dict[Tuple[int, int, int, int], int] = {}

        for secret in range(4, len(secrets)):
            sequence = (
                diff(secrets[secret - 4], secrets[secret - 3]),
                diff(secrets[secret - 3], secrets[secret - 2]),
                diff(secrets[secret - 2], secrets[secret - 1]),
                diff(secrets[secret - 1], secrets[secret]),
            )
            if sequence not in sequences:
                sequences[sequence] = secrets[secret] % 10

        all_price_sequences.append(sequences)

    all_sequences: Set[Tuple[int, int, int, int]] = set()

    for aps in all_price_sequences:
        all_sequences |= set(aps.keys())

    best_total = 0

    for sequence in all_sequences:
        total = 0

        for price_sequence in all_price_sequences:
            if sequence in price_sequence:
                total += price_sequence[sequence]

        best_total = max(best_total, total)

    return best_total


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    lines = [line.strip("\n") for line in lines if len(line) > 1]

    print(f"{input_type:>6} Part 1: {find_total_secrets(lines)}")

    if input_type == "Test":
        lines = ["1", "2", "3", "2024"]

    print(f"{input_type:>6} Part 2: {find_best_sequence(lines)}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
