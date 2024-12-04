from pathlib import PurePath
from typing import List


def stone_delta(stone: List[List[int]], delta: float) -> List[float]:
    return [stone[0][i] + stone[1][i] * delta for i in range(3)]


def stone_distance_xy(
    stone0: List[float],
    stone1: List[float],
) -> float:
    return (abs(stone0[0] - stone1[0]) ** 2 + abs(stone0[1] - stone1[1]) ** 2) ** 0.5


def collision(
    stone0: List[List[int]],
    stone1: List[List[int]],
    target: List[int],
) -> bool:
    xy_distance = stone_distance_xy(stone0[0], stone1[0])

    delta = 0.1
    stone0_d = stone_delta(stone0, delta)
    stone1_d = stone_delta(stone1, delta)

    xy_distance_delta = stone_distance_xy(stone0_d, stone1_d)

    if xy_distance_delta > xy_distance:
        print("Increasing", xy_distance_delta, xy_distance)
        return False

    delta *= xy_distance / (xy_distance - xy_distance_delta)
    print(stone0, stone1)
    print(xy_distance, xy_distance_delta, delta)
    stone0_d = stone_delta(stone0, delta)
    stone1_d = stone_delta(stone1, delta)

    result = (
        target[0] <= stone0_d[0] <= target[1] and target[0] <= stone0_d[1] <= target[1]
    )

    print(stone0_d, stone1_d)

    return result


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    stones = []

    for line in lines:
        line = line.strip("\n")

        parts = line.split("@")
        positions = [int(p) for p in parts[0].strip().split(",")]
        velocities = [int(p) for p in parts[1].strip().split(",")]

        stones.append([positions, velocities])

    print(stones)

    total = 0
    target = [7, 27] if input_type == "Test" else [200000000000000, 400000000000000]

    for i in range(len(stones)):
        for j in range(i + 1, len(stones)):
            if i == 2 and j == 3:
                print("cross outside the test area (at x=-2, y=3)")
                for delta in [r * 1 for r in range(30)]:
                    stone0_d = stone_delta(stones[i], delta)
                    stone1_d = stone_delta(stones[j], delta)
                    print(stone0_d, stone1_d, delta)
                if collision(stones[i], stones[j], target):
                    print(i, j)
                    total += 1

        #     break
        # break

    print(f"{input_type:>6} Part 1: {total}")
    print(f"{input_type:>6} Part 2: ")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    # main(day, input_path, "Puzzle")
