"""
Two urn [Ellsberg paradox](https://en.wikipedia.org/wiki/Ellsberg_paradox) example.
"""

using Gen

include("../knightian.jl")
include("../lib.jl")
include("../imprecise-enumerative.jl")
include("../visualize.jl")

@gen function onea()
  a ~ labeled_uniform(['r', 'b'])
  if a == 'r'
    return 1
  else
    return 0
  end
end

@gen function twoa()
  a ~ labeled_uniform(['r', 'b'])
  if a == 'b'
    return 1
  else
    return 0
  end
end

@gen function oneb()
  b ~ labeled_uniform(['r', 'b'])
  if a == 'r'
    return 1
  else
    return 0
  end
end

@gen function twob()
  b ~ labeled_uniform(['r', 'b'])
  if a == 'b'
    return 1
  else
    return 0
  end
end

model = onea
model_args = ()
# observations = choicemap(:return => 'r')
observations = EmptyChoiceMap()
sample_choices = [
  (:a, ['r', 'b']),
]
sample_choice_vol_iter = choice_vol_grid(sample_choices...)
knight_choices = [
]
knight_choice_vol_iter = choice_vol_grid(knight_choices...)

trace_dict, log_norm_weights, lml_est = imprecise_enumerative_inference(
  model,
  model_args,
  observations,
  knight_choice_vol_iter,
  sample_choice_vol_iter,
)

dicts = enumerate_outcomes_dict(trace_dict, log_norm_weights)

