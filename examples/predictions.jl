"""
Here's an example:
Suppose we're concerned about three events, A, B, and C. We don't know how they are related, but it would be wrong to assume they are independent.
Let's guess that
P(A) = 0.9
P(B) = 0.85
P(C) = 0.95
Then maybe we're curious about an event like P(at least two of A, B, C occur).
Imprecise probability lets us model the uncertainty over the dependence structure on A, B, and C to get bounds on this probability!
"""

using Gen
using IterTools

include("../knightian.jl")
include("../lib.jl")
include("../imprecise-enumerative.jl")
include("../visualize.jl")

@gen function pa90()
  guess1 ~ guess(['r', 'g', 'b'], x -> x == 'r', 0.9, ==)
  return guess1
end

@gen function pageq90()
  guess1 ~ guess(['r', 'g', 'b'], x -> x == 'r', 0.9, >=)
  return guess1
end

# Example showing a more complicated halfspace selection with `guess`
@gen function pa8090()
  x ~ bernoulli(0.5)
  if x
    g = {:guess1} ~ guess(['r', 'g', 'b'], x -> x == 'r', Dict(('r', 'g') => 0.9, ('r', 'b') => 0.8), <=)
  else
    g = {:guess1} ~ guess(['r', 'g', 'b'], x -> x == 'r', Dict(('r', 'g') => 0.9, ('r', 'b') => 0.5), <=)
  end
  return g
end

# Previous version was equivalent to:
# @gen function pa8090()
#   guess1 ~ guess(['r', 'g', 'b'], x -> x != 'r', Dict(('g','r') => 0.9, ('b','r') => 0.8), >=)
#   return guess1
# end

# This is to test expanding the semantics of conditioning on a credal set
@gen function twoofthree()
  possibilities = binary_tuples(3)
  guess1 ~ guess(possibilities, x -> x[1], 0.9, ==)
  guess2 ~ guess(possibilities, x -> x[2], 0.85, ==)
  guess3 ~ guess(possibilities, x -> x[3], 0.92, ==)
end



titles = ["P(A)=0.9", "P(A)>=0.9", "P(A) 80/90", "2 of three"]
ps = [plot(framestyle=:none, aspect_ratio=1, xlims=(-0.1, 1.1), ylims=(-0.1, sqrt(3) / 2 + 0.1), title=titles[i]) for i in 1:4]

# P(A)=0.9

model = pa90
model_args = ()
observations = EmptyChoiceMap()
sample_choices = [
  ((:guess1 => :b), [false, true]),
]
sample_choice_vol_iter = choice_vol_grid(sample_choices...)
knight_choices = [
  ((:guess1 => :z), [('r', 'g'), ('r', 'b')]),
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

# P(A)>=0.9

model = pageq90
model_args = ()
observations = EmptyChoiceMap()
sample_choices = [
  ((:guess1 => :b), [false, true]),
]
sample_choice_vol_iter = choice_vol_grid(sample_choices...)
knight_choices = [
  ((:guess1 => :z), [('r', 'r'), ('r', 'g'), ('r', 'b')]),
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

# P(A) 80/90

model = pa8090
model_args = ()
observations = EmptyChoiceMap()
sample_choices = [
  (:x, [false, true]),
  ((:guess1 => :b), [false, true]),
  # ((:guess2 => :b), [false, true]),
]
sample_choice_vol_iter = choice_vol_grid(sample_choices...)
knight_choices = [
  ((:guess1 => :z), [('g', 'g'), ('b', 'b'), ('g', 'r'), ('b', 'r')]),
  # ((:guess2 => :z), [('g','g'), ('b', 'b'), ('g','r'), ('b', 'r')]),
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

# 2 of 3

model = twoofthree
model_args = ()
observations = EmptyChoiceMap()
sample_choices = [
  ((:guess1 => :b), [false, true]),
  ((:guess2 => :b), [false, true]),
  ((:guess3 => :b), [false, true]),
]
sample_choice_vol_iter = choice_vol_grid(sample_choices...)
knight_choices = [
  ((:guess1 => :z), [(true, false, false), (true, false, true), (true, true, false), (true, true, true)]),
  ((:guess2 => :z), [(false, true, false), (false, true, true), (true, true, false), (true, true, true)]),
  ((:guess3 => :z), [(false, false, true), (false, true, true), (true, false, true), (true, true, true)])
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

# TODO compute lower and upper probabilities

# combine

final_plot = plot(ps...)
display(final_plot)
