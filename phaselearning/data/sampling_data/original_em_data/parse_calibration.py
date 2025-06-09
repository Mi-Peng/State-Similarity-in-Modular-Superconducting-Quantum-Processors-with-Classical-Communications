import os
import json
from scipy.linalg import sqrtm
import numpy as np

# cutting process:
I = np.array(
    [[1, 0], 
    [0, 1]]
)
X = np.array(
    [[0, 1], 
    [1, 0]]
)
Y = np.array(
    [[0, -1j], 
    [1j, 0]]
)
CLIFFORDS = [I, sqrtm(X), sqrtm(Y)]

def calculate_f(data, h):
    m = 0
    for i in range(3):
        npdata = np.array(data[h][i], dtype=np.int8)
        count0 = np.count_nonzero(npdata == 0)
        count1 = np.count_nonzero(npdata == 1)
        p0 = count0 / (count0 + count1)
        for clifford in CLIFFORDS:
            temp = p0 * np.abs(clifford[0, 0]) ** 2 + (1-p0) * np.abs(clifford[1, 0]) ** 2
            m += 2 * temp - 1
    return m / 3

if __name__ == "__main__":
    path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "calibration_20250227.json")
    with open(path, "r") as f:
        data = json.load(f)

    h2f = {
        "-1.45":[], "-1.35":[], "-1.20":[],"-1.05":[], "-0.90":[], "-0.75":[], "-0.60":[] ,"-0.45":[] ,"-0.30":[] ,"-0.15":[],
        "0.00":[], "0.15":[], "0.30":[], "0.45":[], "0.60":[], "0.75":[], "0.90":[], "1.05":[], "1.20":[], "1.35":[], "1.45":[],
    }
    for h in data.keys():
        h2f["{:.2f}".format(eval(h))].append(calculate_f(data, h).item())
    
    with open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "calibration_f_20250227.json"), "w") as f:
        json.dump(h2f, f, indent=4)

