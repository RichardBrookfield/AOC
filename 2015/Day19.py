from pathlib import PurePath

Transformations = list[tuple[str, str]]
TargetMolecules = set[str]
SourceMolecules = dict[str, int]


def find_target_molecules(
    molecule: str, transformations: Transformations
) -> TargetMolecules:
    target_molecules: TargetMolecules = set()

    for left, right in transformations:
        if left in molecule:
            parts = molecule.split(left)

            for i in range(len(parts) - 1):
                target_molecules.add(
                    left.join(parts[0 : i + 1]) + right + left.join(parts[i + 1 :])
                )

    return target_molecules


def find_source_molecules(
    source_molecules: SourceMolecules,
    molecule: str,
    current: int,
    transformations: Transformations,
) -> None:
    for left, right in sorted(
        transformations, key=lambda transformation: len(transformation[1]), reverse=True
    ):
        source_molecule = molecule
        transformation_count = 0

        while right in source_molecule:
            transformation_count += source_molecule.count(right)
            source_molecule = source_molecule.replace(right, left)

        if transformation_count:
            new_count = transformation_count + current
            source_molecules[source_molecule] = min(
                source_molecules.get(source_molecule, new_count),
                new_count,
            )


def main(day: int, input_path: str, input_type: str):
    with open(f"{input_path}/{input_type}/Day{day:02}.txt", "r") as f:
        lines = f.readlines()

    transformations: Transformations = []
    starting_molecule = ""

    for line in [line.rstrip("\n") for line in lines]:
        if " => " in line:
            left, right = line.split(" => ")
            transformations.append((left, right))
        else:
            starting_molecule = line

    target_molecules = find_target_molecules(
        molecule=starting_molecule,
        transformations=transformations,
    )

    print(f"{input_type:>6} Part 1: {len(target_molecules)}")

    target_molecule = starting_molecule
    starting_molecule = "e"

    if input_type == "Test":
        target_molecule = "HOHOHO"

    source_molecules: SourceMolecules = {}
    sorting_limit = 1000

    find_source_molecules(
        source_molecules=source_molecules,
        molecule=target_molecule,
        current=0,
        transformations=transformations,
    )

    while "e" not in source_molecules:
        new_source_molecules: SourceMolecules = {}

        for molecule in source_molecules.keys():
            find_source_molecules(
                source_molecules=new_source_molecules,
                molecule=molecule,
                current=source_molecules[molecule],
                transformations=transformations,
            )

        source_molecules = new_source_molecules

        if len(source_molecules) > sorting_limit:
            source_molecules = dict(
                sorted(
                    source_molecules.items(), key=lambda item: item[1] / len(item[0])
                )[:sorting_limit]
            )

        if len(source_molecules) == 0:
            break

    print(
        f"{input_type:>6} Part 2: {min([v for k,v in source_molecules.items() if k == 'e']) if source_molecules else -1}"
    )


if __name__ == "__main__":
    here = PurePath(__file__)
    day = int(here.name[3:5])
    input_path = f"../../AOCdata/{here.parent.name}"

    main(day=day, input_path=input_path, input_type="Test")
    main(day=day, input_path=input_path, input_type="Puzzle")
