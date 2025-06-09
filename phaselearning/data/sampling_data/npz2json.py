import os
import shutil
import json
import numpy as np
from collections import Counter

from utils import counting, count2prob

def first_part_npz2json(src_path, dst_path, n_shots, n_unitary):
    for ui in range(n_unitary):
        data_dict = {}
        for z in ["z0u1", "z0u2", "z0u3", "z1"]:
            name = z + "_" + f"{ui}th-unitary.npz"
            data = np.load(os.path.join(src_path, name))["arr_0"][:, :n_shots]  #shape:(n_qubits, n_shots)

            state_data, cutted_data = data[:-1, :], data[-1, :]
            y0_indice = np.where(cutted_data==0)[0]
            y1_indice = np.where(cutted_data==1)[0]

            state_data_y0 = state_data[:, y0_indice]
            state_data_y1 = state_data[:, y1_indice]

            state_data_bitstring2probs_y0 = count2prob(counting(state_data_y0), n_shots)
            state_data_bitstring2probs_y1 = count2prob(counting(state_data_y1), n_shots)

            data_dict[z+"y0"] = state_data_bitstring2probs_y0
            data_dict[z+"y1"] = state_data_bitstring2probs_y1
        with open(os.path.join(dst_path, f"{ui}-th_unitary.json"), "w") as f:
            json.dump(data_dict, f, indent=4)

def last_part_npz2json(src_path, dst_path, n_shots, n_unitary):
    for ui in range(n_unitary):
        data_dict = {}
        for z in ["z0u1", "z0u2", "z0u3", "z1"]:
            # z_in == 1:
            if z == "z1":
                name_y0 = z+ "y0" + "_" + f"{ui}th-unitary.npz"
                data_y0 = np.load(os.path.join(src_path, name_y0))["arr_0"][:, :n_shots]  #shape:(n_qubits, n_shots)
                state_data_bitstring2count_y0 = counting(data_y0)

                name_y1 = z+ "y1" + "_" + f"{ui}th-unitary.npz"
                data_y1 = np.load(os.path.join(src_path, name_y1))["arr_0"][:, :n_shots]  #shape:(n_qubits, n_shots)
                state_data_bitstring2count_y1 = counting(data_y1)

                state_data_bitstring2count = Counter(state_data_bitstring2count_y0) + Counter(state_data_bitstring2count_y1)
                state_data_bitstring2probs = count2prob(state_data_bitstring2count, 2* n_shots)
                data_dict["z1y0"] = state_data_bitstring2probs
                data_dict["z1y1"] = state_data_bitstring2probs
            # z_in == 0
            else:
                for y in ["0", "1"]:
                    name = z + f"y{y}" + "_" + f"{ui}th-unitary.npz"
                    data = np.load(os.path.join(src_path, name))["arr_0"][:, :n_shots]  #shape:(n_qubits, n_shots)

                    state_data_bitstring2probs = count2prob(counting(data), n_shots)
                    data_dict[z+f"y{y}"] = state_data_bitstring2probs
        with open(os.path.join(dst_path, f"{ui}-th_unitary.json"), "w") as f:
            json.dump(data_dict, f, indent=4)

def copy_em_param(src_path, dst_path):
    # copy calibration.json
    shutil.copy(
        os.path.join(src_path, "calibration.json"),
        os.path.join(dst_path, "calibration.json"),
    )

    # copy readout.json
    for part_dir in os.listdir(src_path):
        if os.path.isdir(os.path.join(src_path, part_dir)):
            shutil.copy(
                os.path.join(src_path, part_dir, "readout.json"),
                os.path.join(dst_path, part_dir, "readout.json")
            )



### main for test ###
if __name__ == "__main__":
    src_root = r"C:\Users\SusiwrrTT\Desktop\code\phaselearning\data\sampling_data\npz_file"
    dst_root = r"C:\Users\SusiwrrTT\Desktop\code\phaselearning\data\sampling_data\json_file_1000shots"
    n_shots = 1000

    for h_value in os.listdir(src_root):
        os.makedirs(os.path.join(dst_root, h_value, "part0"), exist_ok=True)
        os.makedirs(os.path.join(dst_root, h_value, "part1"), exist_ok=True)
        
        first_part_npz2json(
            os.path.join(src_root, h_value, "part0"), 
            os.path.join(dst_root, h_value, "part0"), 
            n_shots, n_unitary=9
        )
        last_part_npz2json(
            os.path.join(src_root, h_value, "part1"), 
            os.path.join(dst_root, h_value, "part1"), 
            n_shots, n_unitary=27
        )
        copy_em_param(
            os.path.join(src_root, h_value),
            os.path.join(dst_root, h_value)
        )