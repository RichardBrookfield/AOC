from pathlib import PurePath
from typing import List


def count_networks(
    total_nodes: int,
    input_connections: List[List[int]],
    ignored_connections: [List[List[int]]] = [],
) -> int:
    connections = input_connections.copy()
    nodes = [connections[0][0]]

    nodes_added = True

    while nodes_added:
        # print("Conn len:", len(connections))
        nodes_added = False
        to_delete = []

        for connection in [
            connection
            for connection in connections
            if connection not in ignored_connections
        ]:
            if connection[0] in nodes and connection[1] not in nodes:
                nodes.append(connection[1])
                nodes_added = True
                to_delete.append(connection)

            if connection[1] in nodes and connection[0] not in nodes:
                nodes.append(connection[0])
                nodes_added = True
                to_delete.append(connection)

        for td in to_delete:
            connections.remove(td)

    return 1 if len(nodes) == total_nodes else len(nodes) * (total_nodes - len(nodes))


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    nodes = []
    connections = []

    for line in lines:
        line = line.strip("\n")

        source = line.split(":")[0]
        targets = line.split(":")[1].strip().split(" ")

        [nodes.append(node) for node in [source] + targets if node not in nodes]

        source_index = nodes.index(source)

        for target in targets:
            connections.append([source_index, nodes.index(target)])

    print("Nodes", len(nodes))
    print("Conns", len(connections))
    # print(nodes)
    # print(connections)

    fixed_connections = [[6, 8], [9, 12], [0, 3]]

    # print(count_networks(len(nodes), connections))
    # print(count_networks(len(nodes), connections, fixed_connections))

    tested = 0

    for i in range(len(connections)):
        for j in [j for j in range(len(connections)) if j > i]:
            for k in [k for k in range(len(connections)) if k > j]:
                ignored_connections = [connections[i], connections[j], connections[k]]
                networks = count_networks(len(nodes), connections, ignored_connections)

                if networks != 1:
                    print("Found:", networks)
                    break

                tested += 1
                if tested % 10 == 0:
                    print("Tested:", tested)

    # for ignored_connections in [
    #     [connections[i], connections[j], connections[k]]
    #     for i in range(len(connections))
    #     for j in [j for j in range(len(connections)) if j > i]
    #     for k in [k for k in range(len(connections)) if k > j]
    # ]:
    #     networks = count_networks(len(nodes), connections, ignored_connections)
    #     if networks != 1:
    #         print("Found:", networks)
    #         break

    #     tested += 1
    #     if tested % 10 == 0:
    #         print("Tested:", tested)

    print(f"{input_type:>6} Part 1: ")
    print(f"{input_type:>6} Part 2: ")


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day, input_path, "Test")
    main(day, input_path, "Puzzle")
