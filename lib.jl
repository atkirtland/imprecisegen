"""
defines functions for convenient manipulation of imprecise probabilities
"""

using Gen
using IterTools

# https://github.com/probcomp/Gen.jl/pull/513
@dist labeled_uniform(items) = items[uniform_discrete(1, length(items))]
@dist knight(items) = items[knightian(1, length(items))]

function enumerate_outcomes(traces, log_norm_weights)

  outcome_counts = Dict()

  for (trace, log_w) in zip(traces, log_norm_weights)
    retval = get_retval(trace)
    curr = get!(outcome_counts, retval, 0.0)
    outcome_counts[retval] += exp(log_w)
  end

  return outcome_counts

end

function enumerate_outcomes_dict(trace_dict, log_norm_weights)
  outcome_counts = Array{Dict{Any,Float64}}(undef, size(trace_dict))
  for (idx, traces) in enumerate(trace_dict)
    outcome_counts[idx] = enumerate_outcomes(trace_dict[idx], log_norm_weights[idx])
  end
  return outcome_counts
end

function dict_to_points(data, keys::AbstractVector)
  points = []
  for d in dicts
    r = get(d, keys[1], 0.0)
    g = get(d, keys[2], 0.0)
    b = get(d, keys[3], 0.0)
    push!(points, (r, g, b))
  end
  return points
end

function partition_by_condition(condition, array)
  true_items = Vector{eltype(array)}()
  false_items = Vector{eltype(array)}()

  for item in array
    if condition(item)
      push!(true_items, item)
    else
      push!(false_items, item)
    end
  end

  return true_items, false_items
end

# a version that takes in a single probability and uses it to specify a region around each above vertex
@gen function guess(possibilities, filter_condition, prob::Float64, op::Function)
  @assert (op == (==)) || (op == (>=)) "Operation not supported yet!"
  above, below = partition_by_condition(filter_condition, possibilities)
  prod = collect(product(above, below)) |> vec
  if op == (>=)
    prod = vcat(prod, [(option, option) for option in above])
  end
  z = {:z} ~ knight(prod)
  b = {:b} ~ bernoulli(prob)
  if b
    return z[1]
  else
    return z[2]
  end
end

function binary_tuples(n)
  binary = [false, true]
  return collect(product(ntuple(_ -> binary, n)...)) |> vec
end
