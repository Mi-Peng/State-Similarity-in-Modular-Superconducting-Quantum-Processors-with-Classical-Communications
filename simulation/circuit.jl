module Circuit

# Add noise into the circuit.
function add_noise(circuit, noise, noise_qubit)
    if noise !== nothing
        circuit = vcat(circuit, [(noise[1], noise_qubit, noise[2])])
    end
    return circuit
end

# first part of GHZ state(built-in function)
function _first_part_ghz(
    n_qubits_list,
    noise
)
    single_qbit_gate_noise, two_qbit_gate_noise, cutted_noise, measurement_noise = noise
    n_qubits = n_qubits_list[1]

    circuits_dict = Dict(1 => [])
    for (index_out, (key_string_out, z_out, clifford_out)) in enumerate([
            ("z0u1", 0, [1 0; 0 1]), 
            ("z0u2", 0, [0.5+0.5*im 0.5-0.5*im; 0.5-0.5*im 0.5+0.5*im]), 
            ("z0u3", 0, [0.5+0.5*im -0.5-0.5*im; 0.5+0.5*im 0.5+0.5*im]), 
            ("z1", 1, nothing)
        ])
        tmp_circuit = [("H", 1)]
        tmp_circuit = add_noise(tmp_circuit, single_qbit_gate_noise, 1)
        for i_qubit in 1:n_qubits-1
            tmp_circuit = vcat(
                tmp_circuit,
                [("CX", (i_qubit, i_qubit+1))]
            )
            tmp_circuit = add_noise(tmp_circuit, two_qbit_gate_noise, (i_qubit, i_qubit+1))
        end
        if z_out == 0
            tmp_circuit = vcat(tmp_circuit, [(Matrix(clifford_out'), n_qubits)])
            tmp_circuit = add_noise(tmp_circuit, single_qbit_gate_noise, n_qubits)
        end
        tmp_circuit = add_noise(tmp_circuit, cutted_noise, n_qubits)
        
        # save circuit into dict
        circuits_dict[1] = vcat(
            circuits_dict[1],
            Dict(
                "n_qubits" => n_qubits,
                "zc_in" => nothing,
                "y_in" => nothing,
                "zc_out" => key_string_out,
                "circuit" => tmp_circuit,
            )
        )
    end
    return circuits_dict
end

# all middle parts of GHZ state(built-in function)
function _middle_part_ghz(
    n_qubits_list,
    noise
)
    single_qbit_gate_noise, two_qbit_gate_noise, cutted_noise, measurement_noise = noise
    n_parts = length(n_qubits_list)

    circuits_dict = Dict(i => [] for i in 2:n_parts-1)
    for ith_part in 2:n_parts-1
        for (index_in, (key_string_in, z_in, clifford_in)) in enumerate([
                ("z0u1", 0, [1 0; 0 1]), 
                ("z0u2", 0, [0.5+0.5*im 0.5-0.5*im; 0.5-0.5*im 0.5+0.5*im]), 
                ("z0u3", 0, [0.5+0.5*im -0.5-0.5*im; 0.5+0.5*im 0.5+0.5*im]), 
                ("z1", 1, nothing)
            ])
            for (index_out, (key_string_out, z_out, clifford_out)) in enumerate([
                    ("z0u1", 0, [1 0; 0 1]), 
                    ("z0u2", 0, [0.5+0.5*im 0.5-0.5*im; 0.5-0.5*im 0.5+0.5*im]), 
                    ("z0u3", 0, [0.5+0.5*im -0.5-0.5*im; 0.5+0.5*im 0.5+0.5*im]), 
                    ("z1", 1, nothing)
                ])
                for y_in in [0, 1]
                    n_qubits = n_qubits_list[ith_part]
                    tmp_circuit = y_in == 1 ? [("X", 1)] : []

                    if z_in == 0
                        tmp_circuit = vcat(tmp_circuit, [(Matrix(clifford_in), 1)])
                        tmp_circuit = add_noise(tmp_circuit, single_qbit_gate_noise, 1)
                    end
                    for i_qubit in 1:n_qubits-1
                        tmp_circuit = vcat(
                            tmp_circuit,
                            [("CX", (i_qubit, i_qubit+1))]
                        )
                        tmp_circuit = add_noise(tmp_circuit, two_qbit_gate_noise, (i_qubit, i_qubit+1))
                    end
                    if z_out == 0
                        tmp_circuit = vcat(tmp_circuit, [(Matrix(clifford_out'), n_qubits)])
                        tmp_circuit = add_noise(tmp_circuit, single_qbit_gate_noise, n_qubits)
                    end
                    tmp_circuit = add_noise(tmp_circuit, cutted_noise, n_qubits)

                    # save circuit into dict
                    circuits_dict[ith_part] = vcat(
                        circuits_dict[ith_part], 
                        Dict(
                            "n_qubits" => n_qubits,
                            "zc_in" => key_string_in,
                            "y_in" => y_in,
                            "zc_out" => key_string_out,
                            "circuit" => tmp_circuit
                        )
                    )
                end
            end
        end
    end
    return circuits_dict
end

# last part of GHZ state(built-in function)
function _last_part_ghz(
    n_qubits_list,
    noise
)
    single_qbit_gate_noise, two_qbit_gate_noise, cutted_noise, measurement_noise = noise
    n_qubits = n_qubits_list[end]

    circuits_dict = Dict(length(n_qubits_list) => [])
    for (index_in, (key_string_in, z_in, clifford_in)) in enumerate([
            ("z0u1", 0, [1 0; 0 1]), 
            ("z0u2", 0, [0.5+0.5*im 0.5-0.5*im; 0.5-0.5*im 0.5+0.5*im]), 
            ("z0u3", 0, [0.5+0.5*im -0.5-0.5*im; 0.5+0.5*im 0.5+0.5*im]), 
            ("z1", 1, nothing)
        ])
        for y_in in [0, 1]
            tmp_circuit = y_in == 1 ? [("X", 1)] : []

            if z_in == 0
                tmp_circuit = vcat(tmp_circuit, [(Matrix(clifford_in), 1)])
                tmp_circuit = add_noise(tmp_circuit, single_qbit_gate_noise, 1)
            end
            for i_qubit in 1:n_qubits-1
                tmp_circuit = vcat(
                    tmp_circuit,
                    [("CX", (i_qubit, i_qubit+1))]
                )
                tmp_circuit = add_noise(tmp_circuit, two_qbit_gate_noise, (i_qubit, i_qubit+1))
            end

            # save circuit into dict
            circuits_dict[length(n_qubits_list)] = vcat(
                circuits_dict[length(n_qubits_list)],
                Dict(
                    "n_qubits" => n_qubits,
                    "zc_in" => key_string_in,
                    "y_in" => y_in,
                    "zc_out" => nothing,
                    "circuit" => tmp_circuit,
                )
            )
        end
    end
    return circuits_dict
end


function n_part_ghz(
    n_qubits_list,
    noise
)
    return merge(
        _first_part_ghz(n_qubits_list,noise),
        _middle_part_ghz(n_qubits_list,noise),
        _last_part_ghz(n_qubits_list,noise)
    )
end

end