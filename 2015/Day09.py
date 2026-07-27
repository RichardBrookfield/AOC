from pathlib import PurePath
from typing import Dict, Set


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    places: Set[str] = set()
    distances: Dict[str, int] = {}

    for line in [line.rstrip("\n") for line in lines]:
        route, distance = line.split(" = ")
        distance = int(distance)
        endpoints = route.split(" to ")
        places.update(endpoints)
        distances["/".join(endpoints)] = distance
        distances["/".join(reversed(endpoints))] = distance

    routes_extended = True
    routes: Dict[str, int] = {place: 0 for place in places}

    while routes_extended:
        routes_extended = False
        new_routes: Dict[str, int] = {}

        for route, distance in routes.items():
            endpoints = route.split("/")

            for place in [p for p in places if p not in endpoints]:
                new_route = "/".join(endpoints + [place])
                new_distance = distance + distances["/".join([endpoints[-1], place])]

                if new_route not in new_routes:
                    new_routes[new_route] = new_distance
                    routes_extended = True

        if routes_extended:
            routes = new_routes

    print(f"{input_type:>6} Part 1: {min(routes.values())}")
    print(f"{input_type:>6} Part 2: {max(routes.values())}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day=day, input_path=input_path, input_type="Test")
    main(day=day, input_path=input_path, input_type="Puzzle")
