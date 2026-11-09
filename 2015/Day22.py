import copy
import enum
from dataclasses import dataclass, field
from pathlib import PurePath


@dataclass
class Attack:
    name: str
    cost: int
    damage: int
    heal: int


@dataclass
class Effect:
    name: str
    cost: int
    damage: int
    armour: int
    mana: int
    duration: int


@dataclass
class Player:
    hitpoints: int
    damage: int
    mana: int
    armour: int
    effects: list[Effect] = field(default_factory=list[Effect])


@dataclass
class Best:
    mana_for_win: int = 0


best = Best()


class Outcome(enum.Enum):
    NO_OUTCOME = enum.auto()
    BOSS_DIES = enum.auto()
    PLAYER_DIES = enum.auto()
    HIT_NOT_APPLIED = enum.auto()


ATTACKS = [
    Attack(name="Magic Missile", cost=53, damage=4, heal=0),
    Attack(name="Drain", cost=73, damage=2, heal=2),
]

EFFECTS = [
    Effect(name="Shield", cost=113, damage=0, armour=7, mana=0, duration=6),
    Effect(name="Poison", cost=173, damage=3, armour=0, mana=0, duration=6),
    Effect(name="Recharge", cost=229, damage=0, armour=0, mana=101, duration=5),
]


def attack_boss(player: Player, boss: Player, attack: Attack) -> bool:
    if player.mana < attack.cost:
        return False

    player.mana -= attack.cost
    boss.hitpoints -= attack.damage
    player.hitpoints += attack.heal

    return True


def find_attack_by_name(attack_name: str) -> Attack:
    attack = [a for a in ATTACKS if a.name == attack_name]
    assert len(attack) == 1, f"Attack {attack_name} not found"
    return attack[0]


def boss_attack_kills(player: Player, boss: Player) -> bool:
    if (damage := max(boss.damage - player.armour, 1)) >= player.hitpoints:
        return True

    player.hitpoints -= damage
    return False


def start_effect(player: Player, boss: Player, effect: Effect) -> bool:
    if player.mana < effect.cost or any(e.name == effect.name for e in player.effects):
        return False

    player.mana -= effect.cost

    if effect.name == "Shield":
        player.armour = effect.armour

    player.effects.append(copy.deepcopy(effect))

    return True


def find_effect_by_name(effect_name: str) -> Effect:
    effect = [e for e in EFFECTS if e.name == effect_name]
    assert len(effect) == 1, f"Effect {effect_name} not found"
    return effect[0]


def apply_effects_kills_boss(player: Player, boss: Player):
    for effect in player.effects:
        boss.hitpoints -= effect.damage
        player.mana += effect.mana

        if boss.hitpoints <= 0:
            return True

    for effect in player.effects:
        effect.duration -= 1

    finished_effects = [effect for effect in player.effects if effect.duration <= 0]

    for effect in finished_effects:
        if effect.name == "Shield":
            player.armour = 0
        player.effects.remove(effect)

    return False


def hit_boss_and_boss_attack(
    player: Player,
    boss: Player,
    attack: Attack | None = None,
    effect: Effect | None = None,
) -> Outcome:
    assert (attack is None) ^ (effect is None)

    if apply_effects_kills_boss(player, boss):
        return Outcome.BOSS_DIES

    if (
        attack
        and not attack_boss(player=player, boss=boss, attack=attack)
        or effect
        and not start_effect(player=player, boss=boss, effect=effect)
    ):
        return Outcome.HIT_NOT_APPLIED

    if apply_effects_kills_boss(player=player, boss=boss):
        return Outcome.BOSS_DIES

    if boss_attack_kills(player=player, boss=boss):
        return Outcome.PLAYER_DIES

    return Outcome.NO_OUTCOME


def run_tests():
    # Example one
    player = Player(hitpoints=10, damage=0, mana=250, armour=0)
    boss = Player(hitpoints=13, damage=8, mana=0, armour=0)

    assert (
        hit_boss_and_boss_attack(
            player=player,
            boss=boss,
            effect=find_effect_by_name("Poison"),
        )
        == Outcome.NO_OUTCOME
    )

    assert player.hitpoints == 2
    assert boss.hitpoints == 10

    assert (
        hit_boss_and_boss_attack(
            player=player,
            boss=boss,
            attack=find_attack_by_name("Magic Missile"),
        )
        == Outcome.BOSS_DIES
    )

    # Example two
    player = Player(hitpoints=10, damage=0, mana=250, armour=0)
    boss = Player(hitpoints=14, damage=8, mana=0, armour=0)

    assert (
        hit_boss_and_boss_attack(
            player=player,
            boss=boss,
            effect=find_effect_by_name("Recharge"),
        )
        == Outcome.NO_OUTCOME
    )

    assert player.hitpoints == 2
    assert boss.hitpoints == 14

    assert (
        hit_boss_and_boss_attack(
            player=player,
            boss=boss,
            effect=find_effect_by_name("Shield"),
        )
        == Outcome.NO_OUTCOME
    )

    assert player.hitpoints == 1
    assert boss.hitpoints == 14
    assert len([e for e in player.effects if e.name == "Recharge"]) > 0

    assert (
        hit_boss_and_boss_attack(
            player=player,
            boss=boss,
            attack=find_attack_by_name("Drain"),
        )
        == Outcome.NO_OUTCOME
    )

    # Recharge wears off here
    assert player.hitpoints == 2
    assert boss.hitpoints == 12
    assert len([e for e in player.effects if e.name == "Recharge"]) == 0

    assert (
        hit_boss_and_boss_attack(
            player=player,
            boss=boss,
            effect=find_effect_by_name("Poison"),
        )
        == Outcome.NO_OUTCOME
    )

    assert player.hitpoints == 1
    assert boss.hitpoints == 9
    assert player.armour == 7

    assert (
        hit_boss_and_boss_attack(
            player=player,
            boss=boss,
            attack=find_attack_by_name("Magic Missile"),
        )
        == Outcome.BOSS_DIES
    )

    # Shield wears off here
    assert player.armour == 0


def hard_mode_kills_player(hard_mode: bool, player: Player) -> bool:
    if hard_mode:
        player.hitpoints -= 1

        if player.hitpoints <= 0:
            return True

    return False


def battle_recursive(
    player: Player,
    boss: Player,
    mana_spent: int,
    hard_mode: bool,
) -> None:
    if mana_spent >= best.mana_for_win:
        return

    for action in (*EFFECTS, *ATTACKS):
        player_copy = copy.deepcopy(player)
        boss_copy = copy.deepcopy(boss)

        if hard_mode_kills_player(hard_mode=hard_mode, player=player_copy):
            continue

        if isinstance(action, Effect):
            outcome = hit_boss_and_boss_attack(
                player=player_copy,
                boss=boss_copy,
                effect=action,
            )
        else:
            outcome = hit_boss_and_boss_attack(
                player=player_copy,
                boss=boss_copy,
                attack=action,
            )

        if outcome == Outcome.NO_OUTCOME:
            battle_recursive(
                player=player_copy,
                boss=boss_copy,
                mana_spent=mana_spent + action.cost,
                hard_mode=hard_mode,
            )
        elif outcome == Outcome.BOSS_DIES:
            best.mana_for_win = min(best.mana_for_win, mana_spent + action.cost)


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    if input_type == "Test":
        run_tests()
        return

    lines = [line.rstrip("\n") for line in lines]
    boss = Player(
        hitpoints=int(lines[0].split(": ")[1]),
        damage=int(lines[1].split(": ")[1]),
        mana=0,
        armour=0,
    )
    player = Player(
        hitpoints=50,
        damage=0,
        mana=500,
        armour=0,
    )

    best.mana_for_win = 999999
    battle_recursive(player=player, boss=boss, mana_spent=0, hard_mode=False)
    print(f"{input_type:>6} Part 1: {best.mana_for_win}")

    best.mana_for_win = 999999
    battle_recursive(player=player, boss=boss, mana_spent=0, hard_mode=True)
    print(f"{input_type:>6} Part 2: {best.mana_for_win}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day=day, input_path=input_path, input_type="Test")
    main(day=day, input_path=input_path, input_type="Puzzle")
