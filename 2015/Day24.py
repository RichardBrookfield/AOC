from pathlib import PurePath


def find_any_split(
    weights: set[int],
    target_weight: int,
    groups: int,
    selected: list[int] = [],
) -> bool:
    if sum(selected) > target_weight:
        return False

    if sum(selected) == target_weight:
        if groups == 2:
            return True
        elif find_any_split(
            weights=weights.copy(),
            target_weight=target_weight,
            groups=groups - 1,
        ):
            return True

    for weight in sorted(
        [w for w in weights if w <= min(selected or [float("inf")])], reverse=True
    ):
        new_weights = weights.copy()
        new_weights.remove(weight)
        new_selected = selected.copy()
        new_selected.append(weight)

        if find_any_split(
            weights=new_weights,
            target_weight=target_weight,
            groups=groups,
            selected=new_selected,
        ):
            return True

    return False


def select_items(
    weights: set[int],
    target_weight: int,
    groups: int,
    selected: list[int] = [],
) -> list[list[int]]:
    selected_weight = sum(selected)
    selected_number = len(selected)

    if selected_number > len(weights) / groups or selected_weight > target_weight:
        return []

    if selected_weight == target_weight:
        if find_any_split(
            weights=weights.copy(),
            target_weight=target_weight,
            groups=groups - 1,
        ):
            return [selected]

        return []

    solutions: list[list[int]] = []

    for weight in sorted(
        [w for w in weights if w <= min(selected or [float("inf")])], reverse=True
    ):
        new_weights = weights.copy()
        new_weights.remove(weight)
        new_selected = selected.copy()
        new_selected.append(weight)

        solution = select_items(
            weights=new_weights,
            target_weight=target_weight,
            groups=groups,
            selected=new_selected,
        )

        if solution:
            solutions.extend(solution)

    return solutions


def quantum_entanglement(weights: list[int]) -> int:
    qe = 1

    for weight in weights:
        qe *= weight

    return qe


def find_best_group(weights: set[int], groups: int) -> int:
    total_weight = sum(weights)
    group_weight = int(total_weight / groups)

    group1_solutions = select_items(
        weights=weights, groups=groups, target_weight=group_weight
    )

    smallest_group1 = min([len(solution) for solution in group1_solutions])

    return min(
        [
            quantum_entanglement(weights=solution)
            for solution in group1_solutions
            if len(solution) == smallest_group1
        ]
    )


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    weights: set[int] = set()

    for line in [line.rstrip("\n") for line in lines]:
        weights.add(int(line))

    lowest_qe = find_best_group(weights=weights, groups=3)
    print(f"{input_type:>6} Part 1: {lowest_qe}")

    lowest_qe = find_best_group(weights=weights, groups=4)
    print(f"{input_type:>6} Part 2: {lowest_qe}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day=day, input_path=input_path, input_type="Test")
    main(day=day, input_path=input_path, input_type="Puzzle")
