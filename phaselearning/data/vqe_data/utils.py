import numpy as np
import json

def load_orginazed_data(path, phase_keyword="exact_phase"):
    with open(path, "r") as f:
        data = json.load(f)

    h_list = []
    state_vector_list = []
    phase_list = []
    for value_dict in data.values():
        h = value_dict["h"]
        h_list.append(h)
        state_vector = np.array(value_dict["state_vector"]["real"]) + 1j * np.array(value_dict["state_vector"]["imag"])
        state_vector_list.append(state_vector)
        phase = value_dict[phase_keyword]
        phase_list.append(phase)
    h_array = np.array(h_list)  # (N,)
    state_vector_array = np.array(state_vector_list) # (N,d)
    phase_array = np.array(phase_list) #(N)
    return h_array, state_vector_array, phase_array



def h2phase(src_path, dst_path, phase_keyword="exact_phase"):
    h_array, state_vector_array, phase_array = load_orginazed_data(src_path, phase_keyword)
    h2phase_dict = {}
    for h, phase in zip(h_array, phase_array):
        h2phase_dict[h.item()] = phase.item()
    
    with open(dst_path, "w") as f:
        json.dump(h2phase_dict, f, indent=4)