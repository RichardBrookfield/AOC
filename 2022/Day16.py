import os


def measure_route(start_valve, rates, routes, route, time_limit):
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


def get_all_routes(routes, valves):
    all_routes = dict()

    for r in routes:
        all_routes[f"{r[0]}-{r[1]}"] = 1

    for distance in range(1, len(valves)):
        new_routes = dict()

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


def get_useful_routes(all_routes, valves, rates):
    useful_routes = dict()

    for k, v in all_routes.items():
        start = int(k.split("-")[0])
        destination = int(k.split("-")[1])

        if (valves[start] == "AA" or rates[start] != 0) and rates[destination] != 0:
            useful_routes[k] = v

    return useful_routes


def main(day: int, input_type: str):
    with open(f"input/{input_type}/Day{str(day).zfill(2)}.txt", "r") as f:
        lines = f.readlines()

    valves = []
    routes = []
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
    routes = [[[], 0]]
    best_total = 0
    part1_minutes = 30
    max_routes = 40000

    while routes:
        next_routes = []

        for r in routes:
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

                next_routes.append([new_route, new_flow])

        routes.clear()

        if next_routes:
            if len(next_routes) > max_routes:
                sorted_nr = sorted(next_routes, key=lambda x: x[1], reverse=True)
                routes = sorted_nr[:max_routes]
            else:
                routes = next_routes

    print(f"{input_type:>6} Part 1: {best_total}")

    # Same again but we can select two routes, two totals
    routes = [[[], [], 0, 0]]
    best_total = 0
    part2_minutes = 26

    while routes:
        next_routes = []

        for r in routes:
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

                    next_routes.append([new_route, r[1], new_flow, r[3]])

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

                    next_routes.append([r[0], new_route, r[2], new_flow])

        routes.clear()

        if next_routes:
            # If there's more than a "reasonable" number, keep the best ones.
            if len(next_routes) > max_routes:
                sorted_nr = sorted(next_routes, key=lambda x: x[2] + x[3], reverse=True)
                routes = sorted_nr[:max_routes]
            else:
                routes = next_routes

    print(f"{input_type:>6} Part 2: {best_total}")


if __name__ == "__main__":
    day = int(os.path.basename(__file__)[3:5])

    main(day, "Test")
    main(day, "Puzzle")
