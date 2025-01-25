from pathlib import PurePath
from typing import List, Set, Tuple


def find_groups_of_3(computers: List[str], links: Set[Tuple[str, str]]) -> int:
    total = 0

    for i in range(len(computers)):
        for j in [
            j
            for j in range(i + 1, len(computers))
            if (computers[i], computers[j]) in links
        ]:
            for k in [
                k
                for k in range(j + 1, len(computers))
                if (computers[i], computers[k]) in links
                and (computers[j], computers[k]) in links
            ]:
                if (
                    computers[i].startswith("t")
                    or computers[j].startswith("t")
                    or computers[k].startswith("t")
                ):
                    total += 1

    return total


def find_largest_group(computers: List[str], links: Set[Tuple[str, str]]) -> str:
    largest = 0
    party = ""

    for first in computers:
        for second in [
            second
            for second in computers
            if first != second and (first, second) in links
        ]:
            included: Set[str] = set()
            included.update([first, second])

            for other in [other for other in computers if other not in [first, second]]:
                all_linked = True

                for i in included:
                    if (other, i) not in links:
                        all_linked = False

                if all_linked:
                    included.add(other)

            if len(included) > largest:
                largest = len(included)
                party = str(",".join(sorted(included)))

    return party


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    lines = [line.strip("\n") for line in lines if len(line) > 1]

    computers: List[str] = []
    links: Set[Tuple[str, str]] = set()

    for line in lines:
        parts = line.split("-")

        for i in range(2):
            if parts[i] not in computers:
                computers.append(parts[i])

        links.add((parts[0], parts[1]))
        links.add((parts[1], parts[0]))

    print(f"{input_type:>6} Part 1: {find_groups_of_3(computers, links)}")
    print(f"{input_type:>6} Part 2: {find_largest_group(computers, links)}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
