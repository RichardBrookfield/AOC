from pathlib import PurePath


class Solution:
    containers: list[int] = []
    combinations: list[list[int]] = []


solution = Solution()


def fill_containers(
    remaining: int, first_container: int, current_combination: list[int]
) -> None:
    if remaining == 0:
        solution.combinations.append(current_combination)
        return

    for i in range(first_container, len(solution.containers)):
        container = solution.containers[i]

        if container <= remaining:
            fill_containers(
                remaining - container, i + 1, current_combination + [container]
            )


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    total = 150 if input_type == "Puzzle" else 25

    solution.containers.clear()
    solution.combinations.clear()

    for line in [line.rstrip("\n") for line in lines]:
        solution.containers.append(int(line))

    fill_containers(remaining=total, first_container=0, current_combination=[])

    print(f"{input_type:>6} Part 1: {len(solution.combinations)}")

    shortest = min([len(c) for c in solution.combinations])

    print(
        f"{input_type:>6} Part 2: {len([c for c in solution.combinations if len(c) == shortest])}"
    )


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day=day, input_path=input_path, input_type="Test")
    main(day=day, input_path=input_path, input_type="Puzzle")
