from pathlib import PurePath
from typing import List


def concatenate(n0: int, n1: int) -> int:
    return int(str(n0) + str(n1))


def test_target(target: int, sources: List[int], third_operator: bool = False) -> bool:
    results = [sources[0]]

    for source in sources[1:]:
        new_results: List[int] = []

        for result in [result for result in results if result <= target]:
            new_results.extend([result * source, result + source])

            if third_operator:
                new_results.append(concatenate(result, source))

        results = new_results

    return target in results


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    lines = [line.strip("\n") for line in lines if len(line) > 1]
    targets: List[int] = []
    sources: List[List[int]] = []

    for line in lines:
        parts = line.split(":")
        targets.append(int(parts[0]))
        sources.append([int(n) for n in parts[1].split(" ") if len(n) > 0])

    items = len(lines)
    totals = [0, 0]

    for i in range(items):
        if test_target(targets[i], sources[i]):
            totals[0] += targets[i]
        if test_target(targets[i], sources[i], True):
            totals[1] += targets[i]

    print(f"{input_type:>6} Part 1: {totals[0]}")
    print(f"{input_type:>6} Part 2: {totals[1]}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
