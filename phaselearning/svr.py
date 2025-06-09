import os
import sys
import json
current_dir = os.path.dirname(os.path.abspath(__file__))
calculate_trx_path = os.path.join(current_dir, '..')
sys.path.append(calculate_trx_path)
from calculate_trx.calculate import main_calculate_trx
from calculate_trx.calculate_wem import main_calculate_trx_wem

import numpy as np
from sklearn.svm import SVR

# def get_h2phase(
#     path=os.path.join(os.path.dirname(os.path.abspath(__file__)), "data", "vqe_data", "h2exact_phase.json")
# ):
#     with open(path, "r") as f:
#         h2phase = json.load(path)
#     return h2phase


def calculate_kernel_matrix(
    h_value_list,
    n_qubits, n_parts, n_unitary, json_file_path
):
    trAB_matrix = np.zeros((len(h_value_list), len(h_value_list)))
    for i, hi in enumerate(h_value_list):
        for j, hj in enumerate(h_value_list):
            # load noise_param_deviceA 
            with open(os.path.join(json_file_path, "{}".format(hi), "calibration.json"), "r") as f:
                calibration_deviceA = json.load(f)
                import ipdb; ipdb.set_trace()
            
            # load noise_param_deviceB

            trAB_ij = main_calculate_trx_wem(
                n_qubits, n_parts, n_unitary, 
                os.path.join(json_file_path, "{}".format(hi)),
                os.path.join(json_file_path, "{}".format(hj)),
                noise_param_deviceA, noise_param_deviceB
            )
            trAB_matrix[i,j] = trAB_ij
    return trAB_matrix

calculate_kernel_matrix([-0.15], 5, 2, 10, r"C:\Users\SusiwrrTT\Desktop\code\phaselearning\data\sampling_data\json_file_1000shots")

def svr():
    # train_kernel_map = 
    # train_phase = 
    # test_kernel_map = 
    # test_phase = 

    svr = SVR(kernel='precomputed')
    svr.fit(train_kernel_map, train_phase)
    pred_phase = svr.predict(test_kernel_map)

