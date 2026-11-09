from pathlib import PurePath


def sum_of_factors(n: int, multiplier: int, limit: int | None = None) -> int:
    factors: set[int] = set([1, n])
    factor = 2

    while factor * factor <= n and (limit is None or factor <= limit):
        if n % factor == 0:
            if limit is None or factor <= limit:
                factors.add(factor)
            if limit is None or factor <= limit:
                factors.add(n // factor)

        factor += 1

    return multiplier * sum(factors)


def find_best_score(target: int, multiplier: int, limit: int | None = None) -> int:
    base = 2

    while True:
        if sum_of_factors(n=base, multiplier=multiplier, limit=limit) >= target:
            return base

        base += 1


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    target = 0

    for line in [line.rstrip("\n") for line in lines]:
        target = int(line)

    print(f"{input_type:>6} Part 1: {find_best_score(target=target, multiplier=10)}")
    print(
        f"{input_type:>6} Part 2: {find_best_score(target=target, multiplier=11, limit=50)}"
    )


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day=day, input_path=input_path, input_type="Test")
    main(day=day, input_path=input_path, input_type="Puzzle")
