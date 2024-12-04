from pathlib import PurePath


def hash(message: str) -> int:
    result = 0

    for c in message:
        result += ord(c)
        result *= 17
        result %= 256

    return result


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    instructions = lines[0].strip("\n").split(",")

    total = sum([hash(instruction) for instruction in instructions])

    print(f"{input_type:>6} Part 1: {total}")

    boxes = {}

    for instruction in instructions:
        label = ""

        while instruction[0].isalpha():
            label += instruction[0]
            instruction = instruction[1:]

        symbol = instruction[0]
        focal_length = int(instruction[1:]) if symbol == "=" else None
        hash_value = hash(label)

        current_lenses = boxes[hash_value] if hash_value in boxes else []

        if symbol == "-":
            for i in range(len(current_lenses)):
                if current_lenses[i][0] == label:
                    current_lenses = current_lenses[:i] + current_lenses[i + 1 :]
                    break
        else:
            added = False

            for i in range(len(current_lenses)):
                if current_lenses[i][0] == label:
                    current_lenses[i][1] = focal_length
                    added = True
                    break

            if not added:
                current_lenses.append([label, focal_length])

        boxes[hash_value] = current_lenses

    power = 0

    for i in range(256):
        if i in boxes:
            box = boxes[i]

            for slot in range(len(box)):
                power += (i + 1) * (slot + 1) * box[slot][1]

    print(f"{input_type:>6} Part 2: {power}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
