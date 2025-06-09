import numpy as np

def counting(array):
    # array: (nqubit, N)
    unique_bitstring, counts = np.unique(array, axis=1, return_counts=True)
    unique_bitstring = unique_bitstring.astype(int)

    bitstring2count_dict = {}
    for i in range(counts.shape[0]):
        bitstring = "".join(map(str, unique_bitstring[:, i]))
        count = int(counts[i])
        bitstring2count_dict[bitstring] = count
    return bitstring2count_dict
def count2prob(adict, nshot):
    bitstring2probs_dict = {}
    for k, v in adict.items():
        bitstring2probs_dict[k] = adict[k] / float(nshot)
    return bitstring2probs_dict
