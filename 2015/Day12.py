import json
from pathlib import PurePath
from typing import Any, cast


def sum_numbers(data: Any, ignore_red: bool) -> int:
    if isinstance(data, int):
        return data
    elif isinstance(data, list):
        items = cast(list[Any], data)
        return sum(sum_numbers(data=item, ignore_red=ignore_red) for item in items)
    elif isinstance(data, dict):
        values = cast(dict[Any, Any], data)
        return (
            0
            if ignore_red and "red" in values.values()
            else sum(sum_numbers(data=value, ignore_red=ignore_red) for value in values.values())
        )
    else:
        return 0


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    data: Any = []

    for line in [line.rstrip("\n") for line in lines]:
        data = json.loads(line)
        # print(f"{sum_numbers(data)} {data}")

    print(f"{input_type:>6} Part 1: {sum_numbers(data=data, ignore_red=False)}")
    print(f"{input_type:>6} Part 2: {sum_numbers(data=data, ignore_red=True)}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day=day, input_path=input_path, input_type="Test")
    main(day=day, input_path=input_path, input_type="Puzzle")
