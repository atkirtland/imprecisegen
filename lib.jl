
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
