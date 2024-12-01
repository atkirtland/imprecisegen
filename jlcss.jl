using Gen

include("knightian.jl")
include("lib.jl")
include("imprecise-enumerative.jl")
include("visualize.jl")

@gen function onea()
  z ~ categorical([0.5, 0.5])
  if z == 2
    x ~ categorical([0.5, 0.5])
    if x == 2
      return 'r'
    else
      return 'g'
    end
  else
    y ~ categorical([0.5, 0.5])
    if y == 2
      return 'r'
    else
      return 'b'
    end
  end
end

@gen function oneb()
  z ~ categorical([0.5, 0.5])
  if z == 2
    x = {:a1} ~ knightian([0.5, 0.5])
    if x == 2
      return 'r'
    else
      return 'g'
    end
  else
    y = {:a1} ~ knightian([0.5, 0.5])
    if y == 2
      return 'r'
    else
      return 'b'
    end
  end
end

@gen function onec()
  z ~ categorical([0.5, 0.5])
  if z == 2
    x = {:a1} ~ knightian([0.5, 0.5])
    if x == 2
      return 'r'
    else
      return 'g'
    end
  else
    y = {:a2} ~ knightian([0.5, 0.5])
    if y == 2
      return 'r'
    else
      return 'b'
    end
  end
end

titles = ["1a", "1b", "1c"]
ps = [plot(framestyle=:none, aspect_ratio=1, xlims=(-0.1, 1.1), ylims=(-0.1, sqrt(3) / 2 + 0.1), title=titles[i]) for i in 1:3]

# for 1a

model = onea
model_args = ()
# observations = choicemap(:return => 'r')
observations = EmptyChoiceMap()
sample_choices = [
  (:z, [1, 2]),
  (:x, [1, 2]),
  (:y, [1, 2]),
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
  (:z, [1, 2]),
]
sample_choice_vol_iter = choice_vol_grid(sample_choices...)
knight_choices = [
  (:a1, [1, 2]),
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
  (:a1, [1, 2]),
  (:a2, [1, 2]),
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

# combine

final_plot = plot(ps...)
savefig(final_plot, "jlcss.svg")
