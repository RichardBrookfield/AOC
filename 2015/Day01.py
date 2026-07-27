from pathlib import PurePath


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    level = 0
    first_basement_step = 0

    for line in [line.rstrip("\n") for line in lines]:
        level = 0
        first_basement_step = 0

        for i in range(len(line)):
            if line[i] == "(":
                level += 1
            elif line[i] == ")":
                level -= 1
            else:
                assert False, f"Unexpected character: {line[i]}"

            if level < 0 and first_basement_step == 0:
                first_basement_step = i + 1

        # print(f"Final level: {level:>3}  First basement step: {first_basement_step}")

    print(f"{input_type:>6} Part 1: {level}")
    print(f"{input_type:>6} Part 2: {first_basement_step}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day=day, input_path=input_path, input_type="Test")
    main(day=day, input_path=input_path, input_type="Puzzle")
