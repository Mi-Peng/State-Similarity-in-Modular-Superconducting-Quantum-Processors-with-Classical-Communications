using JSON
using FileIO
include("circuit.jl")
include("utils.jl")
include("randomized_unitary.jl")
include("parser.jl")


function _forward_for_first_part(
    circuit_list, unitary, noise, n_shots
)
    single_qbit_gate_noise, two_qbit_gate_noise, cutted_noise, measurement_noise = noise
    result_dict = Dict()
    for _circuit_setting in circuit_list
        output = RandomUnitary.random_unitary_measurement(
            _circuit_setting["circuit"],
            unitary,
            measurement_noise,
            _circuit_setting["n_qubits"],
            n_shots
        )
        measure_output, cutted_output = output[:, 1:end-1], output[:, end]
        indices_y0 = findall(x -> x == 0, cutted_output)
        indices_y1 = findall(x -> x == 1, cutted_output)
        measure_bitstring2count_y0 = measure_output[indices_y0, :]  # (n1, n_qubits-1)
        measure_bitstring2count_y1 = measure_output[indices_y1, :]  # (n2, n_qubits-1)
        measure_bitstring2prob_y0 = Utils.counting_bitstring(measure_bitstring2count_y0, true, n_shots)
        measure_bitstring2prob_y1 = Utils.counting_bitstring(measure_bitstring2count_y1, true, n_shots)

        result_dict[_circuit_setting["zc_out"] * "y0"] = measure_bitstring2prob_y0
        result_dict[_circuit_setting["zc_out"] * "y1"] = measure_bitstring2prob_y1
    end
    return result_dict
end

function _forward_for_middle_part(
    circuit_list, unitary, noise, n_shots
)
    single_qbit_gate_noise, two_qbit_gate_noise, cutted_noise, measurement_noise = noise

    # find cirecuits whose z_in == 1
    z1_y0_circuit_setting_dict = Dict()
    z1_y1_circuit_setting_dict = Dict()
    for _circuit_setting in circuit_list
        for zc_out in ["z0u1", "z0u2", "z0u3", "z1"]
            if _circuit_setting["zc_in"][2] == '1' && _circuit_setting["y_in"] == 0 && _circuit_setting["zc_out"] == zc_out
                z1_y0_circuit_setting = Dict(key => value for (key, value) in _circuit_setting)
                z1_y0_circuit_setting_dict[zc_out] = z1_y0_circuit_setting
            elseif _circuit_setting["zc_in"][2] == '1' && _circuit_setting["y_in"] == 1 && _circuit_setting["zc_out"] == zc_out
                z1_y1_circuit_setting = Dict(key => value for (key, value) in _circuit_setting)
                z1_y1_circuit_setting_dict[zc_out] = z1_y1_circuit_setting
            end
        end
    end

    result_dict = Dict()
    # sample circuits whose z_in == 0
    for _circuit_setting in circuit_list
        if _circuit_setting["zc_in"][2] == '0'
            output = RandomUnitary.random_unitary_measurement(
                _circuit_setting["circuit"], 
                unitary, 
                measurement_noise, 
                _circuit_setting["n_qubits"], 
                n_shots
            )
            measure_output, cutted_output = output[:, 1:end-1], output[:, end]
            indices_y0 = findall(x -> x == 0, cutted_output)
            indices_y1 = findall(x -> x == 1, cutted_output)
            measure_bitstring2count_y0 = measure_output[indices_y0, :]  # (n1, n_qubits-1)
            measure_bitstring2count_y1 = measure_output[indices_y1, :]  # (n2, n_qubits-1)
            measure_bitstring2prob_y0 = Utils.counting_bitstring(measure_bitstring2count_y0, true, n_shots)
            measure_bitstring2prob_y1 = Utils.counting_bitstring(measure_bitstring2count_y1, true, n_shots)

            result_dict[string(_circuit_setting["zc_in"], "y", _circuit_setting["y_in"], "_", _circuit_setting["zc_out"], "y0")] = measure_bitstring2prob_y0
            result_dict[string(_circuit_setting["zc_in"], "y", _circuit_setting["y_in"], "_", _circuit_setting["zc_out"], "y1")] = measure_bitstring2prob_y1
        end
    end
    # sample circuits whose z_in == 1
    for zc_out in ["z0u1", "z0u2", "z0u3", "z1"]
        z1_y0_output = RandomUnitary.random_unitary_measurement(
            z1_y0_circuit_setting_dict[zc_out]["circuit"],
            unitary, 
            measurement_noise, 
            z1_y0_circuit_setting_dict[zc_out]["n_qubits"], 
            n_shots
        )
        z1_y1_output = RandomUnitary.random_unitary_measurement(
            z1_y1_circuit_setting_dict[zc_out]["circuit"],
            unitary, 
            measurement_noise, 
            z1_y1_circuit_setting_dict[zc_out]["n_qubits"], 
            n_shots
        )
        z1_output = cat(dims=1, z1_y0_output, z1_y1_output)
        z1_measure_output, z1_cutted_output = z1_output[:, 1:end-1], z1_output[:, end]
        z1_measure_output_y0 = findall(x -> x == 0, z1_cutted_output)
        z1_measure_output_y1 = findall(x -> x == 1, z1_cutted_output)
        z1_measure_bitstring2count_y0 = z1_measure_output[z1_measure_output_y0, :]  # (n1, n_qubits-1)
        z1_measure_bitstring2count_y1 = z1_measure_output[z1_measure_output_y1, :]  # (n2, n_qubits-1)
        z1_bitstring2probs_y0 = Utils.counting_bitstring(z1_measure_bitstring2count_y0, true, 2 * n_shots)
        z1_bitstring2probs_y1 = Utils.counting_bitstring(z1_measure_bitstring2count_y1, true, 2 * n_shots)

        result_dict["z1y0_" * "$zc_out" * "y0"] = z1_bitstring2probs_y0
        result_dict["z1y1_" * "$zc_out" * "y0"] = z1_bitstring2probs_y0
        result_dict["z1y0_" * "$zc_out" * "y1"] = z1_bitstring2probs_y1
        result_dict["z1y1_" * "$zc_out" * "y1"] = z1_bitstring2probs_y1
    end
    return result_dict
end

function _forward_for_last_part(
    circuit_list, unitary, noise, n_shots
)
    single_qbit_gate_noise, two_qbit_gate_noise, cutted_noise, measurement_noise = noise

    # find circuits whose z_in == 1
    z1_y0_circuit_setting = nothing
    z1_y1_circuit_setting = nothing
    for _circuit_setting in circuit_list
        if _circuit_setting["zc_in"][2] == '1' && _circuit_setting["y_in"] == 0
            z1_y0_circuit_setting = Dict(key => value for (key, value) in _circuit_setting)
        elseif _circuit_setting["zc_in"][2] == '1' && _circuit_setting["y_in"] == 1
            z1_y1_circuit_setting = Dict(key => value for (key, value) in _circuit_setting)
        end
    end

    result_dict = Dict()
    # sample circuits whose z_in == 0
    for _circuit_setting in circuit_list
        if _circuit_setting["zc_in"][2] == '0'
            output = RandomUnitary.random_unitary_measurement(
                _circuit_setting["circuit"], 
                unitary, 
                measurement_noise, 
                _circuit_setting["n_qubits"], 
                n_shots
            )
            bitstring2probs = Utils.counting_bitstring(output, true, n_shots)

            result_dict[string(_circuit_setting["zc_in"], "y", _circuit_setting["y_in"])] = bitstring2probs
        end
    end
    # sample circuits whose z_in == 1
    z1_y0_output = RandomUnitary.random_unitary_measurement(
        z1_y0_circuit_setting["circuit"],
        unitary, 
        measurement_noise, 
        z1_y0_circuit_setting["n_qubits"], 
        n_shots
    )
    z1_y1_output = RandomUnitary.random_unitary_measurement(
        z1_y1_circuit_setting["circuit"],
        unitary, 
        measurement_noise, 
        z1_y1_circuit_setting["n_qubits"], 
        n_shots
    )
    z1_output = cat(dims=1, z1_y0_output, z1_y1_output) # (nshot, bottom_qubits) -> # (2 x nshot, bottom_qubits)
    z1_bitstring2probs = Utils.counting_bitstring(z1_output, true, 2*n_shots)

    result_dict["z1y0"] = z1_bitstring2probs
    result_dict["z1y1"] = z1_bitstring2probs
    return result_dict
end

function forward_for_one_part(
    circuit_list, unitary, noise, n_shots, is_first_part, is_last_part
)   
    if is_first_part
        return _forward_for_first_part(circuit_list, unitary, noise, n_shots)
    elseif is_last_part
        return _forward_for_last_part(circuit_list, unitary, noise, n_shots)
    else
        return _forward_for_middle_part(circuit_list, unitary, noise, n_shots)
    end
end

function main(args, noise, file_folder, ith_repeat)
    n_qubits_list = args["n_qubits_list"]
    n_unitary_seq = args["n_unitary_seq"]
    n_shots = args["n_shots"]
    n_parts = length(n_qubits_list)
    # make dir 
    for i_part in 1:n_parts
        mkpath(joinpath(file_folder, "$ith_repeat", "device0", "part$(i_part-1)"))
        mkpath(joinpath(file_folder, "$ith_repeat", "device1", "part$(i_part-1)"))
    end

    # get circuits
    circuits = Circuit.n_part_ghz(n_qubits_list, noise)

    # sample for each part
    unitary_set = [
        [1 0; 0 1], # Identity
        [0.5+0.5*im 0.5-0.5*im; 0.5-0.5*im 0.5+0.5*im], # sqrtX
        [0.5+0.5*im -0.5-0.5*im; 0.5+0.5*im 0.5+0.5*im], # sqrtY
    ]
    for i_part in 1:n_parts
        random_indices, i_part_unitarys = RandomUnitary.sample_randomized_unitary_from_set(
            i_part == n_parts ? n_qubits_list[i_part] : n_qubits_list[i_part]-1, 
            n_unitary_seq[i_part], 
            unitary_set
        )
        for ui in 1:n_unitary_seq[i_part]
            result_deviceA = forward_for_one_part(circuits[i_part], i_part_unitarys[:, ui], noise, n_shots, i_part == 1, i_part == n_parts)
            result_deviceB = forward_for_one_part(circuits[i_part], i_part_unitarys[:, ui], noise, n_shots, i_part == 1, i_part == n_parts)
            open(joinpath(file_folder, "$ith_repeat", "device0", "part$(i_part-1)", "$(ui-1)-th_unitary.json"), "w") do file
                JSON.print(file, result_deviceA, 4)
            end
            open(joinpath(file_folder, "$ith_repeat", "device1", "part$(i_part-1)", "$(ui-1)-th_unitary.json"), "w") do file
                JSON.print(file, result_deviceB, 4)
            end
        end
    end
end


function launch()
    args = Parser.get_argparser()
    file_folder = Parser.parse_filefolder(args)
    noise = Parser.parse_noise_argument(args)

    start_time = time()
    for ith_repeat in 1:args["n_repeat"]
        mkdir(joinpath(file_folder, "$ith_repeat"))
        main(args, noise, file_folder, ith_repeat)
        execution_time = time()  - start_time
        open(joinpath(file_folder, "output.txt"), "a") do file
            println(file, string("[", ith_repeat, "/", args["n_repeat"], "] Done. Used Time:", execution_time))
        end
    end
end


launch()