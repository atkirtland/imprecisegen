"""
Suppose we want to model an unknown distribution T(s|s,a) for s∈{r,g,b}.
For a fixed s_0,a_0, we begin with three guesses for what T(s|s_0,a_0) may be, namely 
1. P(r|s_0,a_0)=0.9, P(g|s_0,a_0)=0.05, P(b|s_0,a_0)=0.05
2. P(r|s_0,a_0)=0.05, P(g|s_0,a_0)=0.9, P(b|s_0,a_0)=0.05
3. P(r|s_0,a_0)=0.05, P(g|s_0,a_0)=0.05, P(b|s_0,a_0)=0.9
We construct a credal set as the convex hull of these three guesses.
Then, we condition on noisy observations and get a new credal set representing the possible guesses following Bayes rule for all possible distributions in the original credal set.
"""

using Gen
using IterTools

include("../knightian.jl")
include("../lib.jl")
include("../imprecise-enumerative.jl")
include("../visualize.jl")

@gen function rgb()
  δ = 0.9
  ε = 0.4
  z ~ knight([1, 2, 3])
  if z == 1
    p = {:pp} ~ labeled_cat(['r', 'g', 'b'], [δ, (1 - δ) / 2, (1 - δ) / 2])
  elseif z == 2
    p = {:pp} ~ labeled_cat(['r', 'g', 'b'], [(1 - δ) / 2, δ, (1 - δ) / 2])
  elseif z == 3
    p = {:pp} ~ labeled_cat(['r', 'g', 'b'], [(1 - δ) / 2, (1 - δ) / 2, δ])
  end
  for i in 1:3
    nq = {:noisyq => i} ~ bernoulli(1 - ε)
    if nq
      pi = {:p => i} ~ labeled_uniform([p])
    else
      pi = {:p => i} ~ labeled_uniform(['r', 'g', 'b'])
    end
  end
  return p
end

#

titles = ["WM"]
ps = [plot(framestyle=:none, aspect_ratio=1, xlims=(-0.1, 1.1), ylims=(-0.1, sqrt(3) / 2 + 0.1), title=titles[i]) for i in 1:1]

model = rgb
model_args = ()
obs = [
  (:p => 1, 'r'),
  (:p => 2, 'r'),
  (:p => 3, 'r'),
]
observations = choicemap(obs...)
sample_choices = [
  (:pp, ['r', 'g', 'b']),
  (:noisyq => 1, [false, true]),
  (:noisyq => 2, [false, true]),
  (:noisyq => 3, [false, true]),
  # (:p => 1, ['r', 'g', 'b']),
  # (:p => 2, ['r', 'g', 'b']),
  # (:p => 3, ['r', 'g', 'b']),
]
sample_choice_vol_iter = choice_vol_grid(sample_choices...)
knight_choices = [
  (:z, [1, 2, 3]),
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

final_plot = plot(ps...)
display(final_plot)
