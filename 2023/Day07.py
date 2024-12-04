from pathlib import PurePath
from typing import List


def card_strength(card: str, part: int) -> int:
    return "AKQJT98765432".find(card) if part == 1 else "AKQT98765432J".find(card)


def hand_strength(hand: str, part: int) -> int:
    hand_copy = hand

    repeats = []

    if part == 2:
        starting_length = len(hand_copy)
        hand_copy = hand_copy.replace("J", "")
        jokers = starting_length - len(hand_copy)

    while hand_copy:
        starting_length = len(hand_copy)
        hand_copy = hand_copy.replace(hand_copy[0], "")
        repeats.append(starting_length - len(hand_copy))

    repeats = sorted(repeats, reverse=True)

    if part == 2:
        if repeats:
            repeats[0] += jokers
        else:
            repeats.append(jokers)

    if repeats == [5]:
        type_rank = 1
    elif repeats == [4, 1]:
        type_rank = 2
    elif repeats == [3, 2]:
        type_rank = 3
    elif repeats == [3, 1, 1]:
        type_rank = 4
    elif repeats == [2, 2, 1]:
        type_rank = 5
    elif repeats == [2, 1, 1, 1]:
        type_rank = 6
    else:
        type_rank = 7

    return str(type_rank) + "".join(
        [str(card_strength(hand[c], part)).zfill(2) for c in range(5)]
    )


def evaluate_hands(lines: List[str], part: int) -> int:
    hands = []

    for line in lines:
        line = line.strip("\n")

        parts = line.split(" ")
        hands.append([parts[0], int(parts[1]), hand_strength(parts[0], part)])

    strengths = sorted([h[2] for h in hands], reverse=True)

    for h in hands:
        h.append(strengths.index(h[2]) + 1)

    return sum([h[1] * h[3] for h in hands])


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    total = evaluate_hands(lines, 1)
    print(f"{input_type:>6} Part 1: {total}")

    total = evaluate_hands(lines, 2)
    print(f"{input_type:>6} Part 2: {total}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
