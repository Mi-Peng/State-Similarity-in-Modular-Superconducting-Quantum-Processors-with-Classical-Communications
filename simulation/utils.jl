module Utils

function counts_to_probs(
    counts_dict::Dict{String, Int}, 
    total_counts::Int=nothing
)::Dict{String, Float64}
    """
    Args:
        counts_dict::Dict{String, Int}: bitstring to its count number, e.g. Dict("000"=>12, "111"=>18).
        total_counts::Int : the total number of counts, `nothing` for sum up the value of counts_dict.
    Returns:
        probs_dict::Dict{String, Float64}:  bitstring to its probability, e.g. Dict("00"=>0.4, "11"=>0.6)

    >>> counts_to_probs(Dict("00"=>12, "11"=>18))
    >>> Dict("00"=>0.4, "11"=>0.6)
    """
    if total_counts === nothing
        total_counts = sum(values(counts_dict))
    end
    probs_dict = Dict{String, Float64}(k => counts_dict[k] / total_counts for k in keys(counts_dict))
    return probs_dict
end

function counting_bitstring(
    sampling_array::Matrix{Int}, 
    toprobs::Bool=false, 
    total_counts::Int=nothing
)::Union{Dict{String, Int}, Dict{String, Float64}}
    """
    Args:
        sampling_array::Matrix{Int}: binary output of circuit,shape:(number_shots, number_qubits).
        toprobs::Bool : whether convert the output into probs dict.
        total_counts:Int : the denominator when calculating probs.
    Returns:
        bitstring2count::Dict{String, Int}: bitstring to its count number.
    
    >>> sampling_array = [1 0 1;
                          1 1 1; 
                          1 0 1;
                          1 1 1;
                          0 0 0;
                         ]
    >>> counting_bitstring(sampling_array, false)
    >>> Dict("000" => 1, "111" => 2, "101" => 2)
    """
    bitstring2count = Dict{String, Int}()
    for row in eachrow(sampling_array)
        bitstring = join(string.(row), "")
        bitstring2count[bitstring] = get(bitstring2count, bitstring, 0) + 1
    end

    if toprobs
        bitstring2probs = counts_to_probs(bitstring2count, total_counts)
        return bitstring2probs
    else
        return bitstring2count
    end
end


end