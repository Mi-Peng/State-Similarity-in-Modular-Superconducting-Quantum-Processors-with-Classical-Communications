import os
import json
import argparse

from calculate import main_calculate_fidelity

def get_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--n_qubits", type=int)
    parser.add_argument("--n_parts", type=int)
    parser.add_argument("--n_unitary", type=int, nargs="+")
    parser.add_argument("--root")
    parser.add_argument("--n_experiments", type=int)
    args = parser.parse_args()
    return args


def main(n_qubits, n_parts, n_unitary, root, n_experiments):
    data_dict = {}
    for i in range(1, n_experiments + 1):
        trAA, trBB, trAB, fidelity = main_calculate_fidelity(
            n_qubits, n_parts, n_unitary, os.path.join(root, f"{i}")
        )
        data_dict[i] = {
            "trAA": trAA,
            "trBB": trBB,
            "trAB": trAB,
            "fidelity": fidelity,
        }
    with open(os.path.join(root, "fidelity.json"), "w") as f:
        json.dump(data_dict, f, indent=4)

args = get_args()
assert len(args.n_unitary) == args.n_parts
main(args.n_qubits, args.n_parts, args.n_unitary, args.root, args.n_experiments)