
# README

This is the source code of [State Similarity in Modular Superconducting Quantum Processors with Classical Communications](https://arxiv.org/abs/2506.01657) containing simulation for sampling, calculation of fidelity, etc.

## Instruction for sampling
### 1. Clone this repo
```bash
git clone git@github.com:Mi-Peng/State-Similarity-in-Modular-Superconducting-Quantum-Processors-with-Classical-Communications.git

cd State-Similarity-in-Modular-Superconducting-Quantum-Processors-with-Classical-Communications
```
### 2. Install Julia and related packages

Download and install Julia from the [official installation instructions.](https://julialang.org/downloads/)

Download the following related packages
- [ArgParse](https://github.com/carlobaldassi/ArgParse.jl)
- [PastaQ](https://github.com/GTorlai/PastaQ.jl)
- [FileIO](https://juliaio.github.io/FileIO.jl/stable/)
- [JSON](https://github.com/JuliaIO/JSON.jl)

### 3. Run the main.jl(some e.g.) to sampling the circuits

Take the 7-bit GHZ state divided into 3 parts as an example:
```
     ┌───┐
q_0: ┤ H ├──■──────────────────────────────────────
     └───┘┌─┴─┐
q_1: ─────┤ X ├──■─────────────────────────────────
          └───┘┌─┴─┐
q_2: ──────────┤ X ├─ ✂ ──■───────────────────────
               └───┘     ┌─┴─┐
q_3: ────────────────────┤ X ├──■──────────────────
                         └───┘┌─┴─┐
q_4: ─────────────────────────┤ X ├─ ✂ ─■─────────
                              └───┘    ┌─┴─┐
q_5: ──────────────────────────────────┤ X ├──■────
                                       └───┘┌─┴─┐
q_6: ───────────────────────────────────────┤ X ├──
                                            └───┘
```

- sampling GHZ state for three parts with 10 unitary and 1000 shots for each part.(noiseless)
```bash
julia simulation/main.jl --file_folder outputs/wirescut_ghz_3+3+3 --n_qubits_list 3 3 3 --n_unitary_seq 10 10 10 --n_shots 1000 --n_repeat 10
```

- sampling GHZ state for three parts with 10 unitary and 1000 shots for each part.(noisy)
```bash
julia simulation/main.jl --file_folder outputs/wirescut_ghz_3+3+3 --n_qubits_list 3 3 3 --n_unitary_seq 10 10 10 --n_shots 1000 --n_repeat 10 --single_qbit_gate_noise depolarizing --single_qbit_gate_noise_prob 0.001 --two_qbit_gate_noise depolarizing --two_qbit_gate_noise_prob 0.01 --cutted_noise bit_flip --cutted_noise_prob 0.01 --measurement_noise bit_flip --measurement_noise_prob 0.005
```

You will get the output file in the following structure.
```
-- outputs
     |-- wirescut_ghz_3+3+3
          |-- 1
               |-- device0
                    |-- part0
                         |-- 0-th_unitary.json
                         |-- 1-th_unitary.json
                         |-- 2-th_unitary.json
                         |-- 3-th_unitary.json
                         |-- 4-th_unitary.json
                         |-- 5-th_unitary.json
                         |-- 6-th_unitary.json
                         |-- 7-th_unitary.json
                         |-- 8-th_unitary.json
                         |-- 9-th_unitary.json
                    |-- part1
                         |- ...
                    |-- part2
                         |- ...
               |-- device1
                    |-- ...
          |-- 2
          ...
          |-- 10
               |-- ...
          |-- output.txt
```

## Instruction for calculating fidelity
### 1. Clone this repo
```bash
git clone git@github.com:Mi-Peng/State-Similarity-in-Modular-Superconducting-Quantum-Processors-with-Classical-Communications.git

cd State-Similarity-in-Modular-Superconducting-Quantum-Processors-with-Classical-Communications
```

### 2.Run the main.py to calculate
Make sure the structure of the data files are the same as above.

```bash
python calculate_trx/main.py --n_qubits 7 --n_parts 3 --n_unitary 10 --n_experiments 10 --root outputs/wirescut_ghz_3+3+3
```

This program will generate the "fidelity.json" file in the root path containing fidelity for each simulation. 


## Instruction for origanizing superconducting quantum computer data

TBD

## Instruction for Phase Learning

TBD

## Instruction for Error Mitigation

TBD