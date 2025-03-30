using Gen

include("../knightian.jl")
include("../lib.jl")
include("../imprecise-enumerative.jl")
include("../visualize.jl")

@gen function onea()
  z ~ labeled_uniform([false, true])
  if z
    x ~ labeled_uniform([false, true])
    if x
      return 'r'
    else
      return 'g'
    end
  else
    y ~ labeled_uniform([false, true])
    if y
      return 'r'
    else
      return 'b'
    end
  end
end

@gen function oneb()
  z ~ labeled_uniform([false, true])
  if z
    x = {:a1} ~ knight([false, true])
    if x
      return 'r'
    else
      return 'g'
    end
  else
    y = {:a1} ~ knight([false, true])
    if y
      return 'r'
    else
      return 'b'
    end
  end
end

@gen function onec()
  z ~ labeled_uniform([false, true])
  if z
    x = {:a1} ~ knight([false, true])
    if x
      return 'r'
    else
      return 'g'
    end
  else
    y = {:a2} ~ knight([false, true])
    if y
      return 'r'
    else
      return 'b'
    end
  end
end

@gen function oned()
  z ~ knight([1, 2, 3])
  z1 ~ labeled_uniform(['r', 'g', 'b'])
  z2 ~ categorical([0.2, 0.35, 0.45])
  z3 ~ categorical([0.6, 0.1, 0.3])
  if z == 1
    return z1
  elseif z == 2
    if z2 == 1
      return 'r'
    elseif z2 == 2
      return 'g'
    else
      return 'b'
    end
  elseif z == 3
    if z3 == 1
      return 'r'
    elseif z3 == 2
      return 'g'
    else
      return 'b'
    end
  end
end

@gen function oned()
  z ~ knight([1, 2, 3, 4])
  if z == 1
    z1 ~ labeled_cat(['r', 'g', 'b'], [1 / 3, 0, 2 / 3])
    return z1
  elseif z == 2
    z2 ~ labeled_cat(['r', 'g', 'b'], [0, 2 / 3, 1 / 3])
    return z2
  elseif z == 3
    z3 ~ labeled_cat(['r', 'g', 'b'], [0, 1 / 3, 2 / 3])
    return z3
  elseif z == 4
    z4 ~ labeled_cat(['r', 'g', 'b'], [1 / 3, 1 / 3, 1 / 3])
    return z4
  end
end

titles = ["1a", "1b", "1c", "1d"]
ps = [plot(framestyle=:none, aspect_ratio=1, xlims=(-0.1, 1.1), ylims=(-0.1, sqrt(3) / 2 + 0.1), title=titles[i]) for i in 1:4]

# for 1a

model = onea
model_args = ()
# observations = choicemap(:return => 'r')
observations = EmptyChoiceMap()
sample_choices = [
  (:z, [false, true]),
  (:x, [false, true]),
  (:y, [false, true]),
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
pts = dict_to_points(dicts, ['r', 'g', 'b'])
plot_ternary(ps[1], pts)

# for 1b

model = oneb
model_args = ()
# observations = choicemap(:return => 'r')
observations = EmptyChoiceMap()
sample_choices = [
  (:z, [false, true]),
]
sample_choice_vol_iter = choice_vol_grid(sample_choices...)
knight_choices = [
  (:a1, [false, true]),
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
pts = dict_to_points(dicts, ['r', 'g', 'b'])
plot_ternary(ps[2], pts)

# 1c

model = onec

knight_choices = [
  (:a1, [false, true]),
  (:a2, [false, true]),
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
pts = dict_to_points(dicts, ['r', 'g', 'b'])
plot_ternary(ps[3], pts)

# 1d

model = oned
model_args = ()
# observations = choicemap(:return => 'r')
observations = EmptyChoiceMap()
sample_choices = [
  (:z1, ['r', 'g', 'b']),
  (:z2, ['r', 'g', 'b']),
  (:z3, ['r', 'g', 'b']),
  (:z4, ['r', 'g', 'b']),
]
sample_choice_vol_iter = choice_vol_grid(sample_choices...)
knight_choices = [
  (:z, [1, 2, 3, 4]),
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
pts = dict_to_points(dicts, ['r', 'g', 'b'])
plot_ternary(ps[4], pts)

# combine

final_plot = plot(ps...)
savefig(final_plot, "cip.svg")
display(final_plot)
