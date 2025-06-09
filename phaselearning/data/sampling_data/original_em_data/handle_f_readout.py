import os
import json

def process_readout(
    readout_json_path=os.path.join(os.path.dirname(os.path.abspath(__file__)), "readout_20250227.json"),
    target_root=os.path.join(os.path.dirname(os.path.abspath(__file__)), "../npz_file"), 
):
    with open(readout_json_path, "r") as f:
        data = json.load(f)

    for h_value, fidelity_dict in data.items():
        save_dict = {
            "F0": [0 for _ in range(len(fidelity_dict["F0"]))], 
            "F1": [0 for _ in range(len(fidelity_dict["F1"]))]
        }
        for k, v in fidelity_dict["F0"].items():
            save_dict["F0"][eval(k)] = v
        for k, v in fidelity_dict["F1"].items():
            save_dict["F1"][eval(k)] = v    
        with open(os.path.join(target_root, h_value, "part0", "readout.json"), "w") as f:
            json.dump(save_dict, f, indent=4)
        with open(os.path.join(target_root, h_value, "part1", "readout.json"), "w") as f:
            json.dump(save_dict, f, indent=4)

def copy_calibration_f_json(
    calibration_f_json=os.path.join(os.path.dirname(os.path.abspath(__file__)), "calibration_f_20250227.json"), 
    target_root=os.path.join(os.path.dirname(os.path.abspath(__file__)), "../npz_file"), 
):
    with open(calibration_f_json, "r") as f:
        data = json.load(f)

    for h_value, calibration_f in data.items():
        with open(os.path.join(target_root, h_value,"calibration.json"), "w") as f:
            json.dump(calibration_f, f, indent=4)
        with open(os.path.join(target_root, h_value,"calibration.json"), "w") as f:
            json.dump(calibration_f, f, indent=4)

if __name__ == "__main__":
    process_readout()
    copy_calibration_f_json()