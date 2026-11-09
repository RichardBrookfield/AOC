from pathlib import PurePath
from typing import NamedTuple

CALORIES = 500

Ingredient = NamedTuple(
    "Ingredient",
    [
        ("capacity", int),
        ("durability", int),
        ("flavour", int),
        ("texture", int),
        ("calories", int),
    ],
)


class Solution:
    ingredients: dict[str, "Ingredient"] = {}
    amounts: list[int] = []
    best_score: int = 0


solution = Solution()


def calculate_score(
    ingredients: dict[str, Ingredient], amounts: list[int], limit_calories: bool
) -> int:
    capacity = sum(
        ingredient.capacity * amount
        for ingredient, amount in zip(ingredients.values(), amounts)
    )
    durability = sum(
        ingredient.durability * amount
        for ingredient, amount in zip(ingredients.values(), amounts)
    )
    flavour = sum(
        ingredient.flavour * amount
        for ingredient, amount in zip(ingredients.values(), amounts)
    )
    texture = sum(
        ingredient.texture * amount
        for ingredient, amount in zip(ingredients.values(), amounts)
    )

    if limit_calories:
        if CALORIES != sum(
            ingredient.calories * amount
            for ingredient, amount in zip(ingredients.values(), amounts)
        ):
            return 0

    return max(0, capacity) * max(0, durability) * max(0, flavour) * max(0, texture)


def find_best_score(remaining: int, index: int, limit_calories: bool = False) -> None:
    if index == 0:
        solution.best_score = 0
        solution.amounts.clear()

    if index == len(solution.ingredients) - 1:
        solution.amounts.append(remaining)

        score = calculate_score(
            ingredients=solution.ingredients,
            amounts=solution.amounts,
            limit_calories=limit_calories,
        )

        if score > solution.best_score:
            solution.best_score = score

        solution.amounts.pop()
        return
    else:
        for amount in range(remaining + 1):
            solution.amounts.append(amount)

            find_best_score(
                remaining=remaining - amount,
                index=index + 1,
                limit_calories=limit_calories,
            )

            solution.amounts.pop()


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    solution.ingredients = {}

    for line in [line.rstrip("\n") for line in lines]:
        parts = line.split()
        name = parts[0].rstrip(":")
        capacity = int(parts[2].rstrip(","))
        durability = int(parts[4].rstrip(","))
        flavour = int(parts[6].rstrip(","))
        texture = int(parts[8].rstrip(","))
        calories = int(parts[10])

        solution.ingredients[name] = Ingredient(
            capacity, durability, flavour, texture, calories
        )

    find_best_score(remaining=100, index=0)
    print(f"{input_type:>6} Part 1: {solution.best_score}")

    find_best_score(remaining=100, index=0, limit_calories=True)
    print(f"{input_type:>6} Part 2: {solution.best_score}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day=day, input_path=input_path, input_type="Test")
    main(day=day, input_path=input_path, input_type="Puzzle")
