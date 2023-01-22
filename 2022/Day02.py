import os


def get_score(them: int, you: int):
    # 0 Rock
    # 1 Paper
    # 2 Scissors
    win = 6
    draw = 3
    loss = 0
    base_score = you + 1

    return (
        base_score + draw
        if them == you
        else base_score + win
        if (them + 1) % 3 == you
        else base_score + loss
    )


def select_move(them: int, you: int):
    # X/0 Lose
    # Y/1 Draw
    # Z/2 Win
    return them if you == 1 else (them + 2) % 3 if you == 0 else (them + 1) % 3


def main(day: int, input_type: str):
    with open(f"input/{input_type}/Day{str(day).zfill(2)}.txt", "r") as f:
        lines = f.readlines()

    part1_score = 0
    part2_score = 0

    for line in lines:
        line = line.rstrip("\n")
        them, you = line.split(" ")

        them_score = ord(them[:1]) - ord("A")
        you_score = ord(you) - ord("X")

        you_score_part2 = select_move(them_score, you_score)

        part1_score += get_score(them_score, you_score)
        part2_score += get_score(them_score, you_score_part2)

    print(f"{input_type:>6} Part 1: {part1_score}")
    print(f"{input_type:>6} Part 2: {part2_score}")


if __name__ == "__main__":
    day = int(os.path.basename(__file__)[3:5])

    main(day, "Test")
    main(day, "Puzzle")
