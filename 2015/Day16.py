from pathlib import PurePath


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    gift_properties: dict[str, int] = {
        "children": 3,
        "cats": 7,
        "samoyeds": 2,
        "pomeranians": 3,
        "akitas": 0,
        "vizslas": 0,
        "goldfish": 5,
        "trees": 3,
        "cars": 2,
        "perfumes": 1,
    }

    for line in [line.rstrip("\n") for line in lines]:
        parts = line.split(" ")
        aunt_number = int(parts[1][:-1])

        properties: dict[str, int] = {}

        for i in range(2, len(parts), 2):
            properties[parts[i][:-1]] = int(parts[i + 1].rstrip(","))

        match = True

        # Part 1 matching
        for p in [
            p
            for p in properties
            if p in gift_properties and properties[p] != gift_properties[p]
        ]:
            match = False

        if match:
            print(f"{input_type:>6} Part 1: {aunt_number}")

        match = True

        # Part 2 matching
        for p in [p for p in properties if p in gift_properties]:
            if p in ["cats", "trees"]:
                if properties[p] <= gift_properties[p]:
                    match = False
            elif p in ["pomeranians", "goldfish"]:
                if properties[p] >= gift_properties[p]:
                    match = False
            else:
                if properties[p] != gift_properties[p]:
                    match = False

        if match:
            print(f"{input_type:>6} Part 2: {aunt_number}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    # main(day=day, input_path=input_path, input_type="Test")
    main(day=day, input_path=input_path, input_type="Puzzle")
