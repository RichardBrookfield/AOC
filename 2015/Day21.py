import copy
from dataclasses import dataclass
from pathlib import PurePath


@dataclass
class Player:
    hitpoints: int
    damage: int
    armour: int


class Accessory:
    def __init__(self, name: str, cost: int, damage: int, armour: int):
        self.name = name
        self.cost = cost
        self.damage = damage
        self.armour = armour


WEAPONS = [
    Accessory("Dagger", 8, 4, 0),
    Accessory("Shortsword", 10, 5, 0),
    Accessory("War Pick", 25, 6, 0),
    Accessory("Longsword", 40, 7, 0),
    Accessory("Greataxe", 74, 8, 0),
]

ARMOUR = [
    Accessory("Leather", 13, 0, 1),
    Accessory("Chainmail", 31, 0, 2),
    Accessory("Splintmail", 53, 0, 3),
    Accessory("Bandedmail", 75, 0, 4),
    Accessory("Platemail", 102, 0, 5),
]

RINGS = [
    Accessory("Damage +1", 25, 1, 0),
    Accessory("Damage +2", 50, 2, 0),
    Accessory("Damage +3", 100, 3, 0),
    Accessory("Defense +1", 20, 0, 1),
    Accessory("Defense +2", 40, 0, 2),
    Accessory("Defense +3", 80, 0, 3),
]


def attack(attacker: Player, defender: Player):
    damage = max(attacker.damage - defender.armour, 1)
    defender.hitpoints -= damage


def battle(player: Player, boss: Player) -> bool:
    while True:
        attack(attacker=player, defender=boss)
        if boss.hitpoints <= 0:
            return True

        attack(attacker=boss, defender=player)
        if player.hitpoints <= 0:
            return False


def find_best_cost(boss: Player, to_win: bool) -> int:
    best_cost = 1000 if to_win else 0
    cost = 0

    for weapon in WEAPONS:
        cost += weapon.cost

        for armour in ARMOUR + [None]:
            armour_cost = armour.cost if armour is not None else 0

            if to_win and cost + armour_cost > best_cost:
                continue
            else:
                cost += armour_cost

            for ring1 in RINGS + [None]:
                ring1_cost = ring1.cost if ring1 is not None else 0

                if to_win and cost + ring1_cost > best_cost:
                    continue
                else:
                    cost += ring1_cost

                for ring2 in RINGS + [None]:
                    if (
                        ring1 is not None
                        and ring2 is not None
                        and ring1.name == ring2.name
                    ):
                        continue

                    ring2_cost = ring2.cost if ring2 is not None else 0

                    if (
                        to_win
                        and cost + ring2_cost > best_cost
                        or not to_win
                        and cost + ring2_cost < best_cost
                    ):
                        continue
                    else:
                        cost += ring2_cost

                    player = Player(hitpoints=100, damage=0, armour=0)
                    boss_copy = copy.deepcopy(boss)

                    player.damage += weapon.damage
                    player.armour += weapon.armour

                    if armour is not None:
                        player.damage += armour.damage
                        player.armour += armour.armour

                    if ring1 is not None:
                        player.damage += ring1.damage
                        player.armour += ring1.armour

                    if ring2 is not None:
                        player.damage += ring2.damage
                        player.armour += ring2.armour

                    if to_win and battle(player=player, boss=boss_copy):
                        best_cost = min(best_cost, cost)
                    elif not to_win and not battle(player=player, boss=boss_copy):
                        best_cost = max(best_cost, cost)

                    cost -= ring2_cost
                cost -= ring1_cost
            cost -= armour_cost
        cost -= weapon.cost

    return best_cost


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    if input_type == "Test":
        player = Player(hitpoints=8, damage=5, armour=5)
        boss = Player(hitpoints=12, damage=7, armour=2)

        assert battle(player=player, boss=boss) is True
        assert player.hitpoints == 2
        return

    lines = [line.rstrip("\n") for line in lines]
    boss = Player(
        hitpoints=int(lines[0].split(": ")[1]),
        damage=int(lines[1].split(": ")[1]),
        armour=int(lines[2].split(": ")[1]),
    )

    best_cost = find_best_cost(boss=boss, to_win=True)
    print(f"{input_type:>6} Part 1: {best_cost}")

    best_cost = find_best_cost(boss=boss, to_win=False)
    print(f"{input_type:>6} Part 2: {best_cost}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day=day, input_path=input_path, input_type="Test")
    main(day=day, input_path=input_path, input_type="Puzzle")
