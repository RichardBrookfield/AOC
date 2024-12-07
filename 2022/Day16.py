from pathlib import PurePath
from typing import Dict, List, Tuple


def measure_route(
    start_valve: int,
    rates: List[int],
    routes: Dict[str, int],
    route: List[int],
    time_limit: int,
) -> Tuple[bool, int]:
    time = 0
    flow = 0
    valve = start_valve

    while route:
        next_valve = route[0]
        time += routes[f"{valve}-{next_valve}"] + 1

        if time > time_limit:
            return False, flow

        flow += rates[next_valve] * (time_limit - time)
        route = route[1:]
        valve = next_valve

    return True, flow


def get_all_routes(routes: List[List[int]], valves: List[str]) -> Dict[str, int]:
    all_routes: Dict[str, int] = {}

    for r in routes:
        all_routes[f"{r[0]}-{r[1]}"] = 1

    for distance in range(1, len(valves)):
        new_routes: Dict[str, int] = {}

        for k, v in all_routes.items():
            start = int(k.split("-")[0])
            destination = int(k.split("-")[1])

            if v == distance:
                for r in routes:
                    if r[0] == destination and r[1] != start:
                        new_route = f"{start}-{r[1]}"

                        if new_route not in all_routes.keys():
                            new_routes[new_route] = distance + 1

        if not new_routes:
            break

        all_routes.update(new_routes)

    return all_routes


def get_useful_routes(
    all_routes: Dict[str, int], valves: List[str], rates: List[int]
) -> Dict[str, int]:
    useful_routes: Dict[str, int] = {}

    for k, v in all_routes.items():
        start = int(k.split("-")[0])
        destination = int(k.split("-")[1])

        if (valves[start] == "AA" or rates[start] != 0) and rates[destination] != 0:
            useful_routes[k] = v

    return useful_routes


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    valves: List[str] = []
    routes: List[List[int]] = []
    rates = [0] * len(lines)

    for line in lines:
        line = line.rstrip("\n")

        splits = line.split(" ")
        name = splits[1]
        rate = int(splits[4][5:-1])
        targets = [s.strip(",") for s in splits[9:]]

        [valves.append(v) for v in [name] + targets if v not in valves]

        start = valves.index(name)
        rates[start] = rate

        for t in targets:
            end = valves.index(t)
            routes.append([start, end])

    all_routes = get_all_routes(routes, valves)
    useful_routes = get_useful_routes(all_routes, valves, rates)

    useful_valves = [v for v in range(len(rates)) if rates[v] != 0]
    start_valve = valves.index("AA")

    # Make a list of routes and totals.
    routes_and_totals: List[Tuple[List[int], int]] = [([], 0)]
    best_total = 0
    part1_minutes = 30
    max_routes = 40000

    while routes_and_totals:
        next_route_and_total: List[Tuple[List[int], int]] = []

        for r in routes_and_totals:
            for v in useful_valves:
                if v in r[0]:
                    continue

                new_route = [v] if not r[0] else r[0] + [v]
                completed, new_flow = measure_route(
                    start_valve, rates, useful_routes, new_route, part1_minutes
                )

                if not completed:
                    continue

                if new_flow > best_total:
                    best_total = new_flow

                next_route_and_total.append((new_route, new_flow))

        routes_and_totals.clear()

        if next_route_and_total:
            if len(next_route_and_total) > max_routes:
                sorted_nr = sorted(
                    next_route_and_total, key=lambda x: x[1], reverse=True
                )
                routes_and_totals = sorted_nr[:max_routes]
            else:
                routes_and_totals = next_route_and_total

    print(f"{input_type:>6} Part 1: {best_total}")

    # Same again but we can select two routes, two totals
    two_routes_two_totals: List[Tuple[List[int], List[int], int, int]] = [
        ([], [], 0, 0)
    ]
    best_total = 0
    part2_minutes = 26

    while two_routes_two_totals:
        next_routes_and_totals: List[Tuple[List[int], List[int], int, int]] = []

        for r in two_routes_two_totals:
            for v in useful_valves:
                if v in r[0] or v in r[1]:
                    continue

                new_route = [v] if not r[0] else r[0] + [v]

                completed, new_flow = measure_route(
                    start_valve, rates, useful_routes, new_route, part2_minutes
                )

                if completed:
                    if new_flow + r[3] > best_total:
                        best_total = new_flow + r[3]

                    next_routes_and_totals.append((new_route, r[1], new_flow, r[3]))

                new_route = [v] if not r[1] else r[1] + [v]

                completed, new_flow = measure_route(
                    start_valve, rates, useful_routes, new_route, part2_minutes
                )

                if completed:
                    # Divide the search space in half by avoiding duplication
                    if r[0] and new_route and new_route[0] < r[0][0]:
                        continue

                    if new_flow + r[2] > best_total:
                        best_total = new_flow + r[2]

                    next_routes_and_totals.append((r[0], new_route, r[2], new_flow))

        two_routes_two_totals.clear()

        if next_routes_and_totals:
            # If there's more than a "reasonable" number, keep the best ones.
            if len(next_routes_and_totals) > max_routes:
                sorted_nr = sorted(
                    next_routes_and_totals, key=lambda x: x[2] + x[3], reverse=True
                )
                two_routes_two_totals = sorted_nr[:max_routes]
            else:
                two_routes_two_totals = next_routes_and_totals

    print(f"{input_type:>6} Part 2: {best_total}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
