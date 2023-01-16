import os


def manhattan_distance(point0, point1) -> int:
    return abs(point0[0] - point1[0]) + abs(point0[1] - point1[1])


def distinct_intervals(interval):
    distinct = []
    next_item = interval[0]
    interval = interval[1:]

    while interval:
        item = interval[0]

        if next_item[1] + 1 < item[0]:
            distinct.append(next_item)
            next_item = item
        elif item[1] > next_item[1]:
            next_item[1] = item[1]

        interval = interval[1:]

    if next_item:
        distinct.append(next_item)

    return distinct


def combine_intervals(interval1, interval2):
    combined = []

    while interval1 or interval2:
        if not interval1:
            [combined.append(r) for r in interval2]
            break
        elif not interval2:
            [combined.append(r) for r in interval1]
            break

        item1 = interval1[0]
        item2 = interval2[0]

        if item1[1] < item2[0]:
            combined.append(item1)
            interval1 = interval1[1:]
        elif item2[1] < item1[0]:
            combined.append(item2)
            interval2 = interval2[1:]
        else:
            combined.append([
                min(item1[0], item2[0]),
                max(item1[1], item2[1])
                ])
            interval1 = interval1[1:]
            interval2 = interval2[1:]

    # By this point we might have adjoining intervals, so process that.
    return distinct_intervals(combined)


def remove_from_interval(interval, value):
    new_interval = []

    while interval:
        item = interval[0]

        if item[0] == value == item[1]:
            pass
        elif item[0] == value:
            new_interval.append([item[0] + 1, item[1]])
        elif item[1] == value:
            new_interval.append([item[0] + 1, item[1]])
        else:
            new_interval.append([item[0], value - 1])
            new_interval.append([value + 1, item[1]])

        interval = interval[1:]

    return new_interval


def items_in_interval(interval) -> int:
    items = 0

    for r in interval:
        items += r[1] - r[0] + 1

    return items


def items_in_subinterval(interval, start: int, end: int) -> int:
    items = 0

    for r in interval:
        items += min(r[1], end) - max(start, r[0]) + 1

    return items


def missing_value_in_interval(interval, start: int, end: int) -> int:
    item = interval[0]

    for r in interval[1:]:
        if start <= item[1] + 1 <= end:
            return item[1] + 1

        item = r

    return -1


def excluded_on_row(row, sensors, distances) -> set:
    all_excluded = []

    for s in range(len(sensors)):
        test_x = sensors[s][0]
        base_distance = abs(row - sensors[s][1])
        remainder = distances[s] - base_distance

        if remainder > 0:
            excluded = [[test_x - remainder, test_x + remainder]]
            all_excluded = combine_intervals(all_excluded, excluded)

    return all_excluded


def main(day: int, input_type: str):
    with open(f'input/{input_type}/Day{str(day).zfill(2)}.txt', 'r') as f:
        lines = f.readlines()

    sensors, beacons, nearest, distances = [], [], [], []

    for line in lines:
        line = line.rstrip('\n')
        parts = line.split(' ')
        sensors.append([int(parts[2][2:-1]), int(parts[3][2:-1])])

        x, y = int(parts[-2][2:-1]), int(parts[-1][2:])

        if [x, y] not in beacons:
            beacons.append([x, y])

        nearest.append(beacons.index([x, y]))
        distance = manhattan_distance(sensors[-1], beacons[nearest[-1]])
        distances.append(distance)

    if input_type == 'Test':
        test_row = 10
        extent = 20
    else:
        test_row = 2000000
        extent = 4000000

    excluded = excluded_on_row(test_row, sensors, distances)

    # There might be a beacon on that row
    for b in [b for b in beacons if b[1] == test_row]:
        excluded = remove_from_interval(excluded, b[0])

    print(f'{input_type:>6} Part 1: {items_in_interval(excluded)}')

    tuning_frequency = -1

    for x in range(extent):
        excluded = excluded_on_row(x, sensors, distances)

        if items_in_subinterval(excluded, 0, extent) < extent + 1:
            y = missing_value_in_interval(excluded, 0, extent)
            tuning_frequency = 4000000 * y + x
            break

        if x % 100000 == 0:
            print(f'Progress {x:>8}')

    print(f'{input_type:>6} Part 2: {tuning_frequency}')


if __name__ == '__main__':
    day = int(os.path.basename(__file__)[3:5])

    # Takes a few minutes but gets there eventually.
    main(day, 'Test')
    main(day, 'Puzzle')
