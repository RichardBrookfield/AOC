import copy
from pathlib import PurePath
from typing import Any, Dict, List, Optional

# Offsets into the materials tuple.
M_RESOURCES = 0
M_ROBOTS = 1
M_REQUESTED = 2
M_TIME = 3
M_HISTORY = 4


def get_materials() -> Dict[int, Any]:
    return {
        M_RESOURCES: [0, 0, 0, 0],
        M_ROBOTS: [1, 0, 0, 0],
        M_REQUESTED: [0, 0, 0, 0],
        M_TIME: 0,
        M_HISTORY: "",
    }


def resource_list() -> List[str]:
    return ["ore", "clay", "obsidian", "geode"]


def load_blueprints(lines: List[str]) -> List[List[List[List[int]]]]:
    blueprints: List[List[List[List[int]]]] = []

    for line in lines:
        line = line.rstrip("\n")

        colons = line.split(":")

        sentences = [r.strip(" ") for r in colons[1].split(".") if r]
        recipes: List[List[List[int]]] = []

        for s in sentences:
            parts = s.split(" ")
            costs = parts[4:]

            ingredients: List[List[int]] = []
            while costs:
                ingredients.append([resource_list().index(costs[1]), int(costs[0])])
                if len(costs) > 3:
                    costs = costs[3:]
                else:
                    costs = None

            recipes.append(ingredients)

        blueprints.append(recipes)

    return blueprints


def make_robot(
    materials: Dict[int, Any],
    blueprint: List[List[List[int]]],
    most: List[int],
    time_limit: int,
    robot_type: int,
) -> bool:
    recipe = blueprint[robot_type]

    # You only have one "factory"
    for resource in recipe:
        if materials[M_RESOURCES][resource[0]] < resource[1]:
            return False

    time_left = time_limit - materials[M_TIME]

    # Don't create another ore/clay robot if you can't use what you have/will have.
    for r in range(2):
        if (
            robot_type == r
            and materials[M_RESOURCES][r] + time_left * materials[M_ROBOTS][r]
            > most[r] * time_left
        ):
            return False

    materials[M_REQUESTED][robot_type] += 1

    for resource in recipe:
        materials[M_RESOURCES][resource[0]] -= resource[1]

    return True


def advance_state(
    blueprint: List[List[List[int]]],
    materials: Dict[int, Any],
    most: list[int],
    time_limit: int,
    desired_robot: Optional[str],
):
    # Get resources from existing robots
    for r in range(len(resource_list())):
        materials[M_RESOURCES][r] += materials[M_ROBOTS][r]

    # Collect robots made in the previous round
    for r in range(len(resource_list())):
        materials[M_ROBOTS][r] += materials[M_REQUESTED][r]
        materials[M_REQUESTED][r] = 0

    materials[M_TIME] += 1

    # No point in making a robot in the last round (allowing time for it to be made)
    if materials[M_TIME] == time_limit - 1:
        return desired_robot

    # No point in making a non-geode robot in the penultimate round
    if desired_robot and materials[M_TIME] == time_limit - 2 and int(desired_robot) < 3:
        return desired_robot

    # Make robot based on resources
    if desired_robot and make_robot(
        materials, blueprint, most, time_limit, int(desired_robot)
    ):
        materials[M_HISTORY] += desired_robot
        desired_robot = ""

    return desired_robot


def advance_blueprint(
    blueprint: List[List[List[int]]],
    materials: Dict[int, Any],
    most: list[int],
    time_limit: int,
    desired_robot: Optional[str],
    to_end: bool = False,
):
    while desired_robot or to_end:
        desired_robot = advance_state(
            blueprint, materials, most, time_limit, desired_robot
        )

        if materials[M_TIME] >= time_limit:
            return True if to_end else False

    return True


def show_best(
    blueprint_offset: int,
    best_geode: int,
    copy_materials: Dict[int, Any],
):
    print(f"BP {blueprint_offset+1:>2}  Best {best_geode:>2}  Debug {copy_materials}")


def test_blueprint(
    blueprints: List[List[List[List[int]]]],
    blueprint_offset: int,
    time_limit: int,
) -> int:
    robots = ["0", "1", "2", "3"]
    best_geode = 0
    working: List[Dict[int, Any]] = []
    working.append(get_materials())
    blueprint = blueprints[blueprint_offset]

    # What's the most expensive non-ore recipe requiring ore?  Ditto for clay.
    most: List[int] = []
    most.append(
        max(max([i[1] for i in r if i[0] == 0], default=0) for r in blueprint[1:])
    )
    most.append(
        max(max([i[1] for i in r if i[0] == 1], default=0) for r in blueprint[2:])
    )

    # To help with the "remaining time" calculation, assume you create geode robots
    # for all round, which would get you 1, 3, 6, 10, etc. i.e. triangular numbers.
    triangles = [sum(range(i)) for i in range(1, time_limit)]

    array_split_point = 70000

    while True:
        next_working: List[Dict[int, Any]] = []

        # If the list gets too big, only process the bottom part to keep it under control
        # and pass through the top part through "as is". The bottom solutions are longer and
        # will "complete" quicker and thus overall tend to reduce the list.
        if len(working) < array_split_point:
            to_be_processed = working
        else:
            next_working += working[1:-array_split_point]
            to_be_processed = working[-array_split_point:]

        for w in to_be_processed:
            # Is it worth continuing, if we got the maximum geodes in the remaining time?
            # Add together: geodes, geode robots * time, best case future (triangular numbers).
            # For future you can take one off the time, as we need to wait for robots to be made.
            time_left = time_limit - w[M_TIME]

            if (
                time_left < 10
                and w[M_RESOURCES][3]
                + time_left * w[M_ROBOTS][3]
                + triangles[time_left - 1]
                < best_geode
            ):
                continue

            for r in robots:
                copy_materials = copy.deepcopy(w)
                if (
                    advance_blueprint(blueprint, copy_materials, most, time_limit, r)
                    and copy_materials[M_TIME] < time_limit
                ):
                    next_working.append(copy_materials)
                if (
                    copy_materials[M_RESOURCES][3] > best_geode
                    and copy_materials[M_TIME] == time_limit
                ):
                    best_geode = copy_materials[M_RESOURCES][3]
                    show_best(blueprint_offset, best_geode, copy_materials)

            # After adding to the manufacturing list, try extending all the way to end.
            # But only if there's at least one geode robot.
            if w[M_ROBOTS][3] > 0:
                copy_materials = copy.deepcopy(w)

                # Full advance all the way to the end
                if (
                    advance_blueprint(
                        blueprint, copy_materials, most, time_limit, None, True
                    )
                    and copy_materials[M_RESOURCES][3] > best_geode
                ):
                    best_geode = copy_materials[M_RESOURCES][3]
                    show_best(blueprint_offset, best_geode, copy_materials)

        if not next_working:
            break

        working = next_working

    return best_geode


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    blueprints = load_blueprints(lines)

    for part in [1, 2]:
        score = 0
        total_score = 0 if part == 1 else 1
        time_limit = 24 if part == 1 else 32

        max_blueprints = len(blueprints) if part == 1 or input_type == "Test" else 3

        for b in range(max_blueprints):
            score = test_blueprint(blueprints, b, time_limit)

            if part == 1:
                total_score += score * (b + 1)
            else:
                total_score *= score

        print(f"{input_type:>6} Part {part}: {total_score}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
