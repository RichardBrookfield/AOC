from pathlib import PurePath


def find_value(target_row: int, target_column: int) -> int:
    row = 1
    column = 1
    n = 20151125

    while row != target_row or column != target_column:
        n = (n * 252533) % 33554393

        if row == 1:
            row = column + 1
            column = 1
        else:
            row -= 1
            column += 1

    return n


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    target_row = 0
    target_column = 0

    for line in [line.rstrip("\n") for line in lines]:
        target_row = int(line[line.find("at row") + 7 : line.find(", column")])
        target_column = int(line[line.find("column") + 7 : line.rfind(".")])
        break

    n = find_value(target_row=target_row, target_column=target_column)

    if input_type == "Test":
        assert 10600672 == n
        assert 33511524 == find_value(target_row=1, target_column=6)
        assert 15514188 == find_value(target_row=2, target_column=5)
        assert 1601130 == find_value(target_row=3, target_column=3)

    print(f"{input_type:>6} Part 1: {n}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day=day, input_path=input_path, input_type="Test")
    main(day=day, input_path=input_path, input_type="Puzzle")
