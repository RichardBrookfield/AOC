import os
import copy


def isnumber(s: str):
    if s is None:
        return False
    elif s.isnumeric():
        return True

    try:
        _ = float(s)
        return True
    except ValueError:
        return False


def process_forwards(monkeys):
    processed_something = True

    while processed_something:
        processed_something = False

        for k, v in monkeys.items():
            if v['Result'] is not None or v['Value1'] is None:
                continue

            if not isnumber(v['Value1']):
                value1 = monkeys[v['Value1']]
                if value1['Result'] is not None:
                    monkeys[k]['Value1'] = value1['Result']
                    processed_something = True

            if not isnumber(v['Value2']):
                value2 = monkeys[v['Value2']]
                if value2['Result'] is not None:
                    monkeys[k]['Value2'] = value2['Result']
                    processed_something = True

            if isnumber(v['Value1']) and \
                    isnumber(v['Value2']) and \
                    v['Result'] is None:
                monkeys[k]['Result'] = str(eval(
                    f"{v['Value1']}{v['Operator']}{v['Value2']}"
                ))
                processed_something = True


def process_backwards(monkeys, human):
    while human['Required'] is None:
        for k, v in monkeys.items():
            if v['Result'] is not None:
                continue

            if isnumber(v['Value1']) and \
                    not isnumber(v['Value2']) and \
                    isnumber(v['Required']):
                result = 0

                if v['Operator'] == '+':
                    result = eval(f"{v['Required']}-{v['Value1']}")
                elif v['Operator'] == '-':
                    result = eval(f"{v['Value1']}-{v['Required']}")
                elif v['Operator'] == '*':
                    result = eval(f"{v['Required']}/{v['Value1']}")
                elif v['Operator'] == '/':
                    result = eval(f"{v['Value1']}/{v['Required']}")

                monkeys[v['Value2']]['Required'] = str(result)
                v['Result'] = str(result)

            if not isnumber(v['Value1']) and \
                    isnumber(v['Value2']) and \
                    isnumber(v['Required']):
                result = 0

                if v['Operator'] == '+':
                    result = eval(f"{v['Required']}-{v['Value2']}")
                elif v['Operator'] == '-':
                    result = eval(f"{v['Required']}+{v['Value2']}")
                elif v['Operator'] == '*':
                    result = eval(f"{v['Required']}/{v['Value2']}")
                elif v['Operator'] == '/':
                    result = eval(f"{v['Required']}*{v['Value2']}")

                monkeys[v['Value1']]['Required'] = str(result)
                v['Result'] = str(result)


def main(day: int, input_type: str):
    with open(f'input/{input_type}/Day{str(day).zfill(2)}.txt', 'r') as f:
        lines = f.readlines()

    monkeys1 = {}

    for line in lines:
        line = line.rstrip('\n')
        parts = line.split(' ')
        name = parts[0].rstrip(':')

        if len(parts) > 2:
            result = None
            value1 = parts[1]
            operator = parts[2]
            value2 = parts[3]
        else:
            result = parts[1]
            value1 = None
            operator = None
            value2 = None

        monkeys1[name] = {
            'Result': result,
            'Value1': value1,
            'Operator': operator,
            'Value2': value2
        }

    monkeys2 = copy.deepcopy(monkeys1)
    root = monkeys1['root']

    process_forwards(monkeys1)

    print(f"{input_type:>6} Part 1: {int(float(root['Result']))}")

    for v in monkeys2.values():
        v['Required'] = None

    root = monkeys2['root']
    human = monkeys2['humn']

    root['Operator'] = '='
    human['Result'] = None

    # Work out the "forward" results (again) as far as possible.
    process_forwards(monkeys2)

    # Then the lone equality
    for v in [v for v in monkeys2.values() if v['Operator'] == '=']:
        if not isnumber(v['Value1']) and isnumber(v['Value2']):
            monkeys2[v['Value1']]['Required'] = v['Value2']
            v['Value1'] = v['Value2']
        elif isnumber(v['Value1']) and not isnumber(v['Value2']):
            monkeys2[v['Value2']]['Required'] = v['Value1']
            v['Value2'] = v['Value1']
        v['Required'] = 'Satisfied'

    # Now work backwards from known results
    process_backwards(monkeys2, human)

    print(f"{input_type:>6} Part 2: {int(float(human['Required']))}")


if __name__ == '__main__':
    day = int(os.path.basename(__file__)[3:5])

    main(day, 'Test')
    main(day, 'Puzzle')
