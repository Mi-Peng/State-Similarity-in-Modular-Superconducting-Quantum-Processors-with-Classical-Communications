module RandomUnitary
import PastaQ
include("circuit.jl")

# Add the random unitary into the end of circuit.
function add_random_unitary(circuit, unitary)
    if unitary === nothing
        return circuit
    end
    for (i, element) in enumerate(unitary)
        circuit = vcat(circuit, [(element, i)])
    end
    return circuit
end

# Measurement of circuit with its random unitary
function random_unitary_measurement(circuit, unitary, measurement_noise, N, nshots)
    circuit = add_random_unitary(circuit, unitary)
    for i in 1:N
        circuit = Circuit.add_noise(circuit, measurement_noise, i)
    end

    bases = PastaQ.randombases(N, nshots; local_basis = ["Z"])
    ψ = PastaQ.runcircuit(N, circuit)
    data_pair = PastaQ.getsamples(ψ, bases)
    data = map(last, data_pair)
    return data # (nshots, nqubits)
end

# Sample randomized unitary
function sample_randomized_unitary_from_set(
    n_qubits::Int, n_unitary_seq::Int, unitary_set=[
        [1 0; 0 1], # Identity
        [0.5+0.5*im 0.5-0.5*im; 0.5-0.5*im 0.5+0.5*im], # sqrtX
        [0.5+0.5*im -0.5-0.5*im; 0.5+0.5*im 0.5+0.5*im], # sqrtY
    ]
)
    """
    Sample unitary from a set 
    Args:
        n_qubits::Int
        n_unitary_seq::Int
        unitary_set: set of unitary which could be chosen
    Returns:
        sampled_unitaries::(n_qubits, n_unitary_seq)
    """
    random_indices = rand(1:length(unitary_set), n_qubits * n_unitary_seq)
    sampled_unitaries = reshape(unitary_set[random_indices], n_qubits, n_unitary_seq)
    return reshape(random_indices, n_qubits, n_unitary_seq), sampled_unitaries
end

end