from pathlib import PurePath


def decode(line: str) -> int:
    processed_line = line[1:-1]

    processed_line = processed_line.replace("\\\\", "D")
    processed_line = processed_line.replace('\\"', "Q")

    while "\\x" in processed_line:
        pos = processed_line.find("\\x")
        processed_line = processed_line[:pos] + "H" + processed_line[pos + 4 :]

    # print(f"{len(line):>3} {len(processed_line):>3} [{line}] [{processed_line}]")
    return len(processed_line)


def recode(line: str) -> int:
    processed_line = line
    processed_line = "q" + processed_line.replace('"', "qq") + "q"
    processed_line = processed_line.replace("\\", "qq")

    return len(processed_line)


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    total_code_length = 0
    total_decoded_length = 0
    total_recoded_length = 0

    for line in [line.rstrip("\n") for line in lines]:
        total_code_length += len(line)
        total_decoded_length += decode(line=line)
        total_recoded_length += recode(line=line)

    print(f"{input_type:>6} Part 1: {total_code_length - total_decoded_length}")
    print(f"{input_type:>6} Part 2: {total_recoded_length - total_code_length}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day=day, input_path=input_path, input_type="Test")
    main(day=day, input_path=input_path, input_type="Puzzle")
