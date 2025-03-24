from copy import deepcopy
from pathlib import PurePath
from typing import Dict, List, Set, Tuple

OPERAND1 = 0
OPERATOR = 1
OPERAND2 = 2
OUTPUT = 3


def read_binary(wires: Dict[str, int], initial_letter: str) -> str:
    binary = ""

    for k, v in sorted(wires.items(), reverse=True):
        if k.startswith(initial_letter):
            binary += str(v)

    return binary


def read_binary_as_int(wires: Dict[str, int], initial_letter: str) -> int:
    return int(read_binary(wires, initial_letter), 2)


def process_rules(
    rules_input: List[List[str]],
    wires_input: Dict[str, int],
    not_list: List[str] = [],
    swap_list: Dict[str, str] = {},
) -> Dict[str, int]:
    rules = deepcopy(rules_input)
    wires = deepcopy(wires_input)

    offset = 0

    while len(rules) > 0:
        rule = rules[offset]

        if rule[OPERAND1] in wires and rule[OPERAND2] in wires:
            operator = rule[OPERATOR]
            operand1 = wires[rule[OPERAND1]]
            operand2 = wires[rule[OPERAND2]]
            result = 0

            if operator == "XOR":
                result = operand1 ^ operand2
            elif operator == "AND":
                result = operand1 & operand2
            elif operator == "OR":
                result = operand1 | operand2
            else:
                print("UNKNONW OP", operator)

            output_wire = rule[OUTPUT]

            if output_wire in swap_list:
                output_wire = swap_list[output_wire]
            elif output_wire in not_list:
                result = not result

            wires[output_wire] = result

            del rules[offset]
        else:
            offset += 1

        if offset > len(rules) - 1:
            offset = 0

    return wires


def remove_query(identities: Dict[str, str], key: str) -> None:
    if identities[key][-1] == "?":
        identities[key] = identities[key][:3]


def indentify_input_nodes(
    rules: List[List[str]],
    identities: Dict[str, str],
    nodes: Set[str],
    bad_nodes: Set[str],
) -> None:
    for rule in [
        rule
        for rule in rules
        if rule[OPERAND1][0] == "x"
        and rule[OPERAND2][0] == "y"
        and rule[OPERATOR] in ("XOR", "AND")
    ]:
        digit = int(rule[OPERAND1][1:])
        id = f"d{digit:>02} {rule[OPERATOR]} INPUT"

        if digit > 0 and rule[OUTPUT][0] == "z":
            identities[id] = ""
            bad_nodes.add((rule[OUTPUT]))
        else:
            identities[id] = rule[OUTPUT] + (
                "" if digit == 0 and rule[OPERATOR] == "XOR" else "?"
            )
            nodes.discard(rule[OUTPUT])


def indentify_xor_output_nodes(
    rules: List[List[str]],
    identities: Dict[str, str],
    nodes: Set[str],
    bad_nodes: Set[str],
) -> None:
    for rule in [
        rule
        for rule in rules
        if rule[OPERAND1][0] != "x"
        and rule[OPERAND2][0] != "y"
        and rule[OPERATOR] == "XOR"
    ]:
        if rule[OUTPUT][0] != "z":
            bad_nodes.add(rule[OUTPUT])
            continue

        digit = int(rule[OUTPUT][1:])
        operands = [rule[OPERAND1], rule[OPERAND2]]
        id = f"d{digit:>02} XOR INPUT"

        if id not in identities or identities[id][:3] not in operands:
            continue

        if identities[id][-1] == "?":
            identities[id] = identities[id][:3]

        operands.remove(identities[id])

        new_id = f"d{digit-1:>02} OR" if digit > 1 else f"d{digit-1:>02} AND INPUT"

        if new_id in identities and identities[new_id][-1] == "?":
            identities[new_id] = identities[new_id][:3]
        else:
            identities[new_id] = operands[0] + "?"

        nodes.discard(operands[0])


def indentify_and_nodes(
    rules: List[List[str]],
    identities: Dict[str, str],
    nodes: Set[str],
    bad_nodes: Set[str],
) -> None:
    for rule in [
        rule
        for rule in rules
        if rule[OPERAND1][0] != "x"
        and rule[OPERAND2][0] != "y"
        and rule[OPERATOR] == "AND"
    ]:
        # For these we don't know the digit offset, so must search.
        operands = set((rule[OPERAND1], rule[OPERAND2]))

        xor_parent_keys = [
            k
            for k, v in identities.items()
            if (not v or v[:3] in operands) and k[4:7] == "XOR"
        ]
        xor_digit = int(xor_parent_keys[0][1:3]) if len(xor_parent_keys) > 0 else -10

        or_parent_keys = [
            k
            for k, v in identities.items()
            if (not v or v[:3] in operands)
            and (k[-2:] == "OR" or xor_digit == 1 and k == "d00 AND INPUT")
        ]
        or_digit = int(or_parent_keys[0][1:3]) if len(or_parent_keys) > 0 else -20

        if xor_digit == or_digit + 1:
            identities[f"d{xor_digit:>02} AND OUTPUT"] = rule[OUTPUT] + "?"

            remove_query(identities, xor_parent_keys[0])
            remove_query(identities, or_parent_keys[0])

            if not identities[xor_parent_keys[0]]:
                identities[xor_parent_keys[0]] = next(
                    iter(operands - set(identities[or_parent_keys[0]]))
                )
            if not identities[or_parent_keys[0]]:
                identities[or_parent_keys[0]] = next(
                    iter(operands - set(identities[xor_parent_keys[0]]))
                )

            nodes.discard(rule[OUTPUT])
        elif xor_digit > 0 and or_digit < 0:
            # If the or_parent_keys is empty, we can deduce from the xor_parent_keys
            or_parent_key = f"d{xor_digit-1:>02} OR OUTPUT"
            identities[or_parent_key] = (
                next(iter(operands - set(identities[xor_parent_keys[0]]))) + "?"
            )

            if rule[OUTPUT][0] != "z":
                identities[f"d{xor_digit:>02} AND OUTPUT"] = rule[OUTPUT] + "?"
            else:
                bad_nodes.add(rule[OUTPUT])

            remove_query(identities, xor_parent_keys[0])
            nodes.discard(rule[OUTPUT])


def indentify_or_nodes(
    rules: List[List[str]],
    identities: Dict[str, str],
    nodes: Set[str],
    bad_nodes: Set[str],
) -> None:
    for rule in [rule for rule in rules if rule[OPERATOR] == "OR"]:
        operands = set((rule[OPERAND1], rule[OPERAND2]))

        # For these we don't know the digit offset, so must search.
        and_parent_keys = [
            k for k, v in identities.items() if v[:3] in operands and k[4:7] == "AND"
        ]
        and_digits = [int(k[1:3]) for k in and_parent_keys]

        if len(and_parent_keys) == 2:
            if and_digits[0] == and_digits[1] or sorted(and_digits) == [44, 45]:
                for i in range(2):
                    remove_query(identities, and_parent_keys[i])

                nodes.discard(rule[OUTPUT])
        elif len(and_parent_keys) == 1:
            # We can deduce one from the other since they vary only by INPUT/OUTPUT.
            remove_query(identities, and_parent_keys[0])

            if "INPUT" in and_parent_keys[0]:
                identities[and_parent_keys[0].replace("INPUT", "OUTPUT")] = (
                    next(iter(operands - set(identities[and_parent_keys[0]]))) + "?"
                )
            else:
                identities[and_parent_keys[0].replace("OUTPUT", "INPUT")] = (
                    next(iter(operands - set(identities[and_parent_keys[0]]))) + "?"
                )

            nodes.discard(rule[OUTPUT])

        # This is ok for the MSB
        if rule[OUTPUT][0] == "z" and and_digits[0] < 44:
            bad_nodes.add(rule[OUTPUT])


def identify_nodes(rules: List[List[str]]) -> Tuple[Dict[str, str], Set[str]]:
    # Given that there are only 4 errors, by mapping out the first few binary digits you can deduce the whole pattern.
    #
    # First the input bits are XOR-ed and AND-ed, to help derive the output digit and carry respectively, let's call these
    # the INPUT XOR and INPUT AND.
    #
    # There are a corresponding pair or XOR and AND on output. The OUTPUT XOR combines with the CARRY (see later) from the
    # previous bit with the INPUT XOR to produce the output bit. The OUTPUT AND combines the same elements to produce a
    # HALF CARRY.
    #
    # The final part is that the INPUT AND and HALF CARRY are OR-ed to produce the CARRY.
    #
    # Finally there are a few simplifications, e.g. the least significant digit has no incoming CARRY and the output for
    # the most significant digit is almost entirely composed of CARRY.
    nodes: Set[str] = set()
    bad_nodes: Set[str] = set()
    identities: Dict[str, str] = {}

    for rule in rules:
        for operand in (OPERAND1, OPERAND2):
            if rule[operand][0] not in "xyz":
                nodes.add(rule[operand])

    # Add a '?' until each assignment is confirmed... and see what's wrong/left over.
    indentify_input_nodes(rules, identities, nodes, bad_nodes)
    indentify_xor_output_nodes(rules, identities, nodes, bad_nodes)
    indentify_and_nodes(rules, identities, nodes, bad_nodes)
    indentify_or_nodes(rules, identities, nodes, bad_nodes)

    return identities, bad_nodes


def find_swapped_nodes(rules: List[List[str]]) -> str:
    identities, bad_nodes = identify_nodes(rules)

    swaps: Dict[str, str] = {}

    # From the bad nodes, pair them up with another around the same digit.
    for bn1 in [bn for bn in bad_nodes if bn[0] == "z"]:
        z_digit = int(bn1[1:3])

        for bn2 in [bn for bn in bad_nodes if bn[0] != "z"]:
            rule = [k for k, v in identities.items() if v[:3] == bn2]
            if len(rule) == 0:
                continue

            other_digit = int(rule[0][1:3])

            if z_digit == other_digit:
                swaps[bn1] = bn2
                swaps[bn2] = bn1

    # Or the final two which did not get paired.
    not_in_swaps = [bn for bn in bad_nodes if bn not in swaps]

    if len(not_in_swaps) == 2:
        bn1 = not_in_swaps[0]
        bn2 = not_in_swaps[1]
        swaps[bn1] = bn2
        swaps[bn2] = bn1

    # Recalculate the rules and reprocess.
    new_rules: List[List[str]] = []

    for rule in rules:
        if rule[OUTPUT] in swaps:
            new_rule = rule.copy()
            new_rule[OUTPUT] = swaps[new_rule[OUTPUT]]
            new_rules.append(new_rule)
        else:
            new_rules.append(rule)

    identities, bad_nodes = identify_nodes(new_rules)

    # And the final pair are the ones still with question marks on the end.
    for node in [v[:3] for v in identities.values() if len(v) > 3]:
        swaps[node] = ""

    return ",".join(sorted(swaps.keys()))


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    lines = [line.strip("\n") for line in lines if len(line) > 1]
    rules: List[List[str]] = []
    wires: Dict[str, int] = {}

    for line in lines:
        if ":" in line:
            parts = line.split(":")
            wires[parts[0].strip()] = int(parts[1].strip())
        else:
            parts = line.split(" ")

            # Remove the "->"
            del parts[3]

            # Enusre consistent sorting
            if parts[OPERAND1] > parts[OPERAND2]:
                parts[OPERAND1], parts[OPERAND2] = parts[OPERAND2], parts[OPERAND1]

            rule = [parts[OPERAND1], parts[OPERATOR], parts[OPERAND2], parts[OUTPUT]]
            rules.append(rule)

    output_wires = process_rules(rules, wires)

    print(f"{input_type:>6} Part 1: {read_binary_as_int(output_wires, 'z')}")

    if input_type == "Puzzle":
        print(f"{input_type:>6} Part 2: {find_swapped_nodes(rules)}")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
