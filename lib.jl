"""
defines functions for convenient manipulation of imprecise probabilities
"""

using Gen
using IterTools

# https://github.com/probcomp/Gen.jl/pull/513
@dist labeled_uniform(items) = items[uniform_discrete(1, length(items))]
# https://www.gen.dev/docs/v0.3/ref/distributions/
@dist function labeled_cat(labels, probs)
  index = categorical(probs)
  labels[index]
end
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

# probs must either be a Float64 or a Dict with key something true under the filter_condition
@gen function guess(possibilities, filter_condition, probs, op::Function)
  @assert op in [==, >=, <=] "Operation not supported!"
  if typeof(probs) == Float64
    # Interpret this as specifying a region around each above vertex
    probs = Dict{Any,Float64}(() => probs)
  end
  above, below = partition_by_condition(filter_condition, possibilities)
  if op == (<=)
    above, below = below, above
    probs = Dict((k[2], k[1]) => v for (k, v) in probs)
  end
  prod = collect(product(above, below)) |> vec
  if op in [>=, <=]
    prod = vcat(prod, [(option, option) for option in above])
  end
  z = {:z} ~ knight(prod)
  # I'm not certain 1.0 is the "right" choice of the default probability (if such a choice exists), but this makes the 80/90 example with both >= and <= give a nontrivial answer
  prob = get(probs, (z[1], z[2]), get(probs, z[1], get(probs, (), 1.0)))
  b = {:b} ~ bernoulli(prob)
  return b ? z[1] : z[2]
end

function binary_tuples(n)
  binary = [false, true]
  return collect(product(ntuple(_ -> binary, n)...)) |> vec
end
