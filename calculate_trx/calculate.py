
import os
import json
import math
import itertools

def hamming_distance(s1: str, s2: str) -> int:
    """
    Args:
        s1 (str): a bitstring, e.g. "1001"
        s2 (str): a bitstring, e.g. "1100"
    Return:
        result (int): the Hamming distance, e.g., 2
    
    Example:
        >>> hamming_distance("1010", "0001")
        >>> 3
    """
    s1 = int(s1, 2)
    s2 = int(s2, 2)
    return bin(s1 ^ s2).count("1") 

def inner_loop_on_sAsB(bitstring2probs_A, bitstring2probs_B):
    """
    bitstring2probs:
        "000": 0.2,
        "001": 0.3,
        ...
    """
    trx = 0
    for s_A, probs_A in bitstring2probs_A.items():
        for s_B, probs_B in bitstring2probs_B.items():
            coef = (-2)**(-hamming_distance(s_A, s_B))
            trx +=  coef * probs_A * probs_B
    return trx


def main_calculate_trx(
    n_qubits, n_parts, n_unitary, 
    root, deviceA_string, deviceB_string
):
    """
    Args:
        n_qubits(int): number of total qubits.
        n_parts(int): number of parts.
        n_unitary(List[int]): number of unitary for each part.
        root(str):
        deviceA_string(str): "device0" or "device1".
        deviceB_string(str): "device0" or "device1".
    """
    zc_list = ["_".join(combination) for combination in itertools.product(["z0u1", "z0u2", "z0u3", "z1"], repeat=n_parts-1)]
    cutted_y_list = [bin(n)[2:].zfill(n_parts-1) for n in range(2**(n_parts-1))]
    zcy_list = []
    for zc in zc_list:
        for y in cutted_y_list:
            _tmp_zcy = "_".join([f"{part}y{bit}" for part, bit in zip(zc.split("_"), list(y))])
            zcy_list.append(_tmp_zcy)
    # zcy_list : ["z0u1y0_z0u1y0_z0u1y0", "z0u1y0_z0u1y0_z0u1y1", ..., "z0u1y0_z0u3y1_z0u1y0", "z0u1y0_z0u3y1_z0u1y1"] (if n_parts = 4)

    trX = 0
    for zcy_device0 in zcy_list:
        for zcy_device1 in zcy_list:
            scale_device0 = 2**zcy_device0.count("z1") / 5**(n_parts-1)
            scale_device1 = 2**zcy_device1.count("z1") / 5**(n_parts-1)
            scale = (-1)**(zcy_device0.count("z1")+zcy_device1.count("z1"))

            dict_key_list_deviceA = [zcy_device0.split("_")[0]] \
                + [f"{zcy_device0.split('_')[i]}_{zcy_device0.split('_')[i+1]}"  for i in range(len(zcy_device0.split("_")) - 1)] \
                + [zcy_device0.split("_")[-1]] # ["z0u1y0", "z0u1y0_z0u3y1", "z0u3y1_z0u1y0", "z0u1y0"] (if zcy_device0 == "z0u1y0_z0u3y1_z0u1y0")
            dict_key_list_deviceB = [zcy_device1.split("_")[0]] \
                + [f"{zcy_device1.split('_')[i]}_{zcy_device1.split('_')[i+1]}"  for i in range(len(zcy_device1.split("_")) - 1)] \
                + [zcy_device1.split("_")[-1]]
            part_trx = 1
            for part_i in range(n_parts):
                part_trx_ui = 0
                for ui in range(n_unitary[part_i]):
                    # deviceA
                    path_deviceA = os.path.join(root, deviceA_string, f"part{part_i}", f"{ui}-th_unitary.json")
                    with open(path_deviceA, "r") as f:
                        data_deviceA = json.load(f)
                    # deviceB
                    path_deviceB = os.path.join(root, deviceB_string, f"part{part_i}", f"{ui}-th_unitary.json")
                    with open(path_deviceB, "r") as f:
                        data_deviceB = json.load(f)
                    
                    part_trx_ui += inner_loop_on_sAsB(
                        data_deviceA[dict_key_list_deviceA[part_i]], 
                        data_deviceB[dict_key_list_deviceB[part_i]]
                    )
                part_trx *= part_trx_ui
            trX += scale * scale_device0 * scale_device1 * part_trx
    trX *= 2**n_qubits * 25**(n_parts-1) / math.prod(n_unitary)
    return trX

def main_calculate_fidelity(
    n_qubits, n_parts, n_unitary, root
):
    trAA = main_calculate_trx(n_qubits, n_parts, n_unitary, root, "device0", "device0")
    trBB = main_calculate_trx(n_qubits, n_parts, n_unitary, root, "device1", "device1")
    trAB = main_calculate_trx(n_qubits, n_parts, n_unitary, root, "device0", "device1")
    fidelity = trAB  / (trAA * trBB) ** 0.5
    return trAA, trBB, trAB, fidelity

