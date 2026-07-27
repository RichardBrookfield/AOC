import operator
from functools import reduce
from pathlib import PurePath
from typing import Dict, Iterable, List, Tuple

Point = Tuple[int, int, int]
Points = List[Point]
Circuits = Dict[int, Points]
Distances = List[Tuple[int, Point, Point]]


def product(numbers: Iterable[int]) -> int:
    return reduce(operator.mul, numbers, 1)


def square_distance(p0: Point, p1: Point) -> int:
    return sum([abs(p0[axis] - p1[axis]) ** 2 for axis in range(3)])


def find_connection(circuits: Circuits, p0: Point, p1: Point) -> int:
    for k, v in circuits.items():
        if p0 in v and p1 in v:
            return k

    return -1


def find_circuits(circuits: Circuits, p0: Point, p1: Point) -> List[int]:
    circuit_keys: List[int] = []

    for k in [k for k, v in circuits.items() if p0 in v or p1 in v]:
        circuit_keys.append(k)

    return circuit_keys


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    points: Points = []

    for line in [line.rstrip("\n") for line in lines]:
        numbers = [int(x) for x in line.split(",")]
        points.append((numbers[0], numbers[1], numbers[2]))

    circuits: Circuits = {}
    connections = 0
    connection_limit = 10 if input_type == "Test" else 1000

    distances: Distances = []

    for p0, p1 in [(p0, p1) for p0 in points for p1 in points if p0 < p1]:
        distances.append((square_distance(p0, p1), p0, p1))

    distances.sort(key=lambda x: x[0])

    for distance in distances:
        selected = [distance[1], distance[2]]

        existing_circuits = find_circuits(circuits, selected[0], selected[1])

        if len(existing_circuits) == 0:
            circuits[len(circuits)] = selected.copy()
        elif len(existing_circuits) == 1:
            for i in [
                i for i in range(2) if selected[i] not in circuits[existing_circuits[0]]
            ]:
                circuits[existing_circuits[0]].append(selected[i])
        elif len(existing_circuits) == 2:
            circuits[existing_circuits[0]] = list(
                set(
                    circuits[existing_circuits[0]]
                    + circuits[existing_circuits[1]]
                    + selected
                )
            )
            circuits[existing_circuits[1]] = circuits[len(circuits) - 1]
            del circuits[len(circuits) - 1]
        else:
            assert False

        connections += 1

        if connections == connection_limit:
            answer = product(
                sorted([len(c) for c in circuits.values()], reverse=True)[:3]
            )
            print(f"{input_type:>6} Part 1: {answer}")

        if len(circuits) == 1 and len(circuits[0]) == len(points):
            print(f"{input_type:>6} Part 2: {selected[0][0] * selected[1][0]}")
            break


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
