from pathlib import PurePath
from typing import List


def best_single_seed(seeds: List[int], lines: List[str]) -> int:
    new_seeds = []

    for line in lines[1:]:
        line = line.strip("\n")

        if ":" in line:
            pass
        elif not line:
            seeds.extend(new_seeds)
            new_seeds.clear()
        else:
            mapping = [int(n) for n in line.split(" ")]

            new_base = mapping[0]
            base = mapping[1]
            top = base + mapping[2]
            to_be_removed = []

            for seed in seeds:
                if base <= seed < top:
                    new_seeds.append(new_base + seed - base)
                    to_be_removed.append(seed)

            for tbr in to_be_removed:
                seeds.remove(tbr)

    seeds.extend(new_seeds)

    return min(seeds)


def best_range_seed(seeds: List[List[int]], lines: List[str]) -> int:
    new_seeds = []
    print("Start:", seeds, "/ Total:", sum([s[1] - s[0] + 1 for s in seeds]))

    for line in lines[1:]:
        line = line.strip("\n")

        if ":" in line:
            pass
        elif not line:
            seeds.extend(new_seeds)
            new_seeds.clear()
        else:
            mapping = [int(n) for n in line.split(" ")]

            new_base = mapping[0]
            base = mapping[1]
            top = base + mapping[2] - 1
            work_done = True

            while work_done:
                work_done = False
                to_be_removed = None
                to_be_added = []

                for seed in seeds:
                    # All below or all above
                    if seed[1] < base or top < seed[0]:
                        pass
                    # Below and in
                    elif seed[0] < base and base <= seed[1] <= top:
                        to_be_removed = seed
                        to_be_added.append([seed[0], base - 1])
                        new_seeds.append([new_base, new_base + seed[1] - base])
                        work_done = True
                        break
                    # In and above
                    elif base <= seed[0] <= top and top < seed[1]:
                        to_be_removed = seed
                        to_be_added.append([top + 1, seed[1]])
                        new_seeds.append(
                            [new_base + seed[0] - base, new_base + top - base]
                        )
                        work_done = True
                        break
                    # Entirely in
                    elif base <= seed[0] and seed[1] <= top:
                        to_be_removed = seed
                        new_seeds.append(
                            [new_base + seed[0] - base, new_base + seed[1] - base]
                        )
                        work_done = True
                        break
                    # From below to above
                    elif seed[0] < base and top < seed[1]:
                        to_be_removed = seed
                        to_be_added.append([seed[0], base - 1])
                        to_be_added.append([top + 1, seed[1]])
                        new_seeds.append([new_base, new_base + top - base])
                        work_done = True
                        break
                    else:
                        print("Conditions not met")

                if to_be_removed:
                    seeds.remove(to_be_removed)

                seeds.extend(to_be_added)

    seeds.extend(new_seeds)

    return min([s[0] for s in seeds])


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    seeds = [int(seed) for seed in lines[0][6:].strip().split(" ")]
    seeds1 = seeds.copy()

    print(f"{input_type:>6} Part 1: {best_single_seed(seeds1, lines)}")

    seeds2 = []

    for i in range(0, len(seeds), 2):
        seeds2.append([seeds[i], seeds[i] + seeds[i + 1] - 1])

    print(f"{input_type:>6} Part 2: {best_range_seed(seeds2, lines)}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
