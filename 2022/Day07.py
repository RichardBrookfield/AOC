import os


def read_filestore(lines):
    filestore = {}
    current_path = '/'
    folder_listing = False

    for line in lines:
        line = line.rstrip('\n')

        if folder_listing:
            if line.startswith('$'):
                folder_listing = False
            elif line.startswith('dir'):
                filestore[current_path + line[4:]] = 0
            else:
                filesize, filename = line.split(' ')
                filestore[current_path + filename] = int(filesize)

        if line == '$ cd /':
            current_path = '/'
        elif line == '$ cd ..':
            current_path = current_path[0:-1]
            last_slash = current_path.rfind('/')
            current_path = current_path[0:last_slash+1]
        elif line.startswith('$ cd '):
            current_path += line[5:] + '/'
        elif line == '$ ls':
            folder_listing = True

    return filestore


def calculate_folder_sizes(filestore):
    folder_sizes = {'/': 0}

    for folder in [k for k, v in filestore.items() if v == 0]:
        folder_sizes[folder + '/'] = 0

    for k, v in filestore.items():
        if v != 0:
            last_slash = k.rfind('/')
            folder = k[0:last_slash+1]
            folder_sizes[folder] += v

    return folder_sizes


def calculate_total_sizes(folder_sizes):
    total_sizes = {'/': 0}

    for k in folder_sizes.keys():
        total_sizes[k] = 0

    for total in total_sizes.keys():
        total_sizes[total] = sum(
            v for k, v in folder_sizes.items() if total == k[0:len(total)])

    return total_sizes


def main(day: int, input_type: str):
    with open(f'input/{input_type}/Day{str(day).zfill(2)}.txt', 'r') as f:
        lines = f.readlines()

    filestore = read_filestore(lines)
    folder_sizes = calculate_folder_sizes(filestore)
    total_sizes = calculate_total_sizes(folder_sizes)

    small_folders = sum(v for k, v in total_sizes.items() if v < 100000)

    print(f'{input_type:>6} Part 1: {small_folders}')

    free_space = 70000000 - total_sizes['/']
    required_space = 30000000 - free_space
    selected_size = min(
        [v for v in total_sizes.values() if v >= required_space])

    print(f'{input_type:>6} Part 2: {selected_size}')


if __name__ == '__main_':
    day = int(os.path.basename(__file__)[3:5])

    main(day, 'Test')
    main(day, 'Puzzle')
