"""
    (traces, log_norm_weights, lml_est) = enumerative_inference(
        model::GenerativeFunction, model_args::Tuple,
        observations::ChoiceMap, choice_vol_iter
    )

Run enumerative inference over a `model`, given `observations` and an iterator over 
choice maps and their associated log-volumes (`choice_vol_iter`), specifying the
choices to be iterated over. An iterator over a grid of choice maps and log-volumes
can be constructed with [`choice_vol_grid`](@ref).

Return an array of traces and associated log-weights with the same shape as 
`choice_vol_iter`. The log-weight of each trace is normalized, and corresponds
to the log probability of the volume of sample space that the trace represents.
Also return an estimate of the log marginal likelihood of the observations (`lml_est`).

All addresses in the `observations` choice map must be sampled by the model when
given the model arguments. The same constraint applies to choice maps enumerated
over by `choice_vol_iter`, which must also avoid sharing addresses with the 
`observations`. When the choice maps in `choice_vol_iter` do not fully specify
the values of all unobserved random choices, the unspecified choices are sampled
from the internal proposal distribution of the model.
"""
function imprecise_enumerative_inference(
  model::GenerativeFunction{T,U}, model_args::Tuple,
  observations::ChoiceMap, knight_choice_vol_iter::I, sample_choice_vol_iter::J
) where {T,U,I,J}

  if Base.IteratorSize(I) isa Base.HasShape
    knightType = Array
    knightFun = size
    knightEmpty = isempty(knightFun(knight_choice_vol_iter))
  elseif Base.IteratorSize(I) isa Base.HasLength
    knightType = Vector
    knightFun = length
    knightEmpty = knightFun(knight_choice_vol_iter) > 0
  else
    knight_choice_vol_iter = collect(knight_choice_vol_iter)
    knightType = Vector
    knightFun = length
    knightEmpty = knightFun(knight_choice_vol_iter) > 0
  end

  if Base.IteratorSize(J) isa Base.HasShape
    sampleType = Array
    sampleFun = size
    sampleEmpty = isempty(sampleFun(sample_choice_vol_iter))
  elseif Base.IteratorSize(J) isa Base.HasLength
    sampleType = Vector
    sampleFun = length
    sampleEmpty = sampleFun(sample_choice_vol_iter) > 0
  else
    sample_choice_vol_iter = collect(sample_choice_vol_iter)
    sampleType = Vector
    sampleFun = length
    sampleEmpty = sampleFun(sample_choice_vol_iter) > 0
  end



  trace_dict = knightType{sampleType{U}}(undef, knightFun(knight_choice_vol_iter))
  for idx in eachindex(trace_dict)
    trace_dict[idx] = sampleType{U}(undef, sampleFun(sample_choice_vol_iter))
  end
  log_weights_dict = knightType{sampleType{Float64}}(undef, knightFun(knight_choice_vol_iter))
  for idx in eachindex(log_weights_dict)
    log_weights_dict[idx] = sampleType{Float64}(undef, sampleFun(sample_choice_vol_iter))
  end

  if knightEmpty
    knight_choice_vol_iter = [(EmptyChoiceMap(),0.0)]
  end
  if sampleEmpty
    sample_choice_vol_iter = [(EmptyChoiceMap(),0.0)]
  end

  for (i, (knight_choices, log_vol)) in enumerate(knight_choice_vol_iter)
    for (j, (sample_choices, log_vol)) in enumerate(sample_choice_vol_iter)
      constraints = merge(observations, sample_choices, knight_choices)
      (trace_dict[i][j], log_weight) = generate(model, model_args, constraints)
      log_weights_dict[i][j] = log_weight + log_vol
    end
  end
  log_total_weight = [logsumexp(log_weights) for log_weights in log_weights_dict]
  # TODO
  # log_normalized_weights = [log_weights .- log_total_weight for log_weights in log_weights_dict]
  # log_normalized_weights = Array{Array{Float64}}(undef, size(log_weights_dict))
  for i in eachindex(log_weights_dict)
    log_weights_dict[i] = log_weights_dict[i] .- log_total_weight[i]
  end
  return (trace_dict, log_weights_dict, log_total_weight)
end

export imprecise_enumerative_inference
