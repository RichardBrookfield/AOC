from pathlib import PurePath
from typing import List


def numbers_from_spaced_list(numbers: str) -> List[int]:
    return [n for n in numbers.strip().split(" ") if n]


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    total_score = 0
    winners_per_card = []

    for line in lines:
        line = line.strip("\n")

        numbers = line.split(":")[1].split("|")
        winning_numbers = numbers_from_spaced_list(numbers[0])
        our_numbers = numbers_from_spaced_list(numbers[1])

        score = 0
        winners = 0

        for our_number in our_numbers:
            if our_number in winning_numbers:
                score = 1 if score == 0 else score * 2
                winners += 1

        winners_per_card.append(winners)
        total_score += score

    number_of_cards = len(winners_per_card)
    cards = [1] * number_of_cards

    for card in range(number_of_cards):
        winners = winners_per_card[card]

        for adjustment in range(winners):
            offset = card + adjustment + 1
            if offset < number_of_cards:
                cards[offset] += cards[card]

    total_cards = sum(cards)

    print(f"{input_type:>6} Part 1: {total_score}")
    print(f"{input_type:>6} Part 2: {total_cards}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
