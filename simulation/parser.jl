module Parser
using JSON
import Dates
import ArgParse

function get_argparser()
    s = ArgParse.ArgParseSettings()
    @ArgParse.add_arg_table! s begin
        "--file_folder"
            help = "file to save output"
            arg_type = String
            default = nothing
        "--n_qubits_list"
            help = "the number of qubits for each part in order"
            arg_type = Int
            nargs = '+'
        "--n_unitary_seq"
            help = "the number of unitary sequence for each part in order"
            arg_type = Int
            nargs = '+'
        "--n_shots"
            help = "number of shots"
            arg_type = Int
            default = 1000
        "--n_repeat"
            help = "number of repeat times(for error bar/standard deviation estimation)" 
            arg_type = Int
            default = 3
        # noise
        "--single_qbit_gate_noise"
            arg_type = String
            default = nothing
        "--single_qbit_gate_noise_prob"
            arg_type = Float64
            default = nothing
        "--two_qbit_gate_noise"
            arg_type = String
            default = nothing
        "--two_qbit_gate_noise_prob"
            arg_type = Float64
            default = nothing
        "--cutted_noise"
            arg_type = String
            default = nothing
        "--cutted_noise_prob"
            arg_type = Float64
            default = nothing
        "--measurement_noise"
            arg_type = String
            default = nothing
        "--measurement_noise_prob"
            arg_type = Float64
            default = nothing
    end
    args = ArgParse.parse_args(s)
    return args
end

function parse_noise_argument(args::Dict)
    # single qubit gate noise
    if args["single_qbit_gate_noise"] !== nothing
        noise_type = args["single_qbit_gate_noise"]
        noise_prob = args["single_qbit_gate_noise_prob"]
        single_qbit_gate_noise = (noise_type, (; p = noise_prob))
    else
        single_qbit_gate_noise = nothing
    end

    # two qubit gate noise
    if args["two_qbit_gate_noise"] !== nothing
        noise_type = args["two_qbit_gate_noise"]
        noise_prob = args["two_qbit_gate_noise_prob"]
        two_qbit_gate_noise = (noise_type, (; p = noise_prob))
    else
        two_qbit_gate_noise = nothing
    end

    # cutted qubit noise
    if args["cutted_noise"] !== nothing
        noise_type = args["cutted_noise"]
        noise_prob = args["cutted_noise_prob"]
        cutted_noise = (noise_type, (; p = noise_prob))
    else
        cutted_noise = nothing
    end

    # measurement noise
    if args["measurement_noise"] !== nothing
        noise_type = args["measurement_noise"]
        noise_prob = args["measurement_noise_prob"]
        measurement_noise = (noise_type, (; p = noise_prob))
    else
        measurement_noise = nothing
    end
    return (single_qbit_gate_noise, two_qbit_gate_noise, cutted_noise, measurement_noise)
end

function parse_filefolder(args)
    if args["file_folder"] === nothing
        # make dir
        current_time = Dates.now()
        time_str = Dates.format(current_time, "yyyy-mm-dd_HH-MM-SS")
        file_folder = "WiresCut_$time_str"
        args["file_folder"] = file_folder
        mkpath(file_folder)
    else
        file_folder = args["file_folder"]
        mkpath(file_folder)
    end

    # save the args setting
    open(joinpath(file_folder, "output.txt"), "w") do file
        println(file, args)
    end
    return file_folder
end

end