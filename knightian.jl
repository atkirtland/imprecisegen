struct Knightian <: Distribution{Int} end

"""
    knightian(probs::AbstractArray{U, 1}) where {U <: Real}

Given a vector of probabilities `probs` where `sum(probs) = 1`, sample an `Int` `i` from the set {1, 2, .., `length(probs)`} with probability `probs[i]`.


Copied from the Categorical code. Need to change to take in labels instead of probabilities. Right now the probs do nothing~
"""
const knightian = Knightian()

function Gen.logpdf(::Knightian, x::Int, probs::AbstractArray{U,1}) where {U<:Real}
  # (x > 0 && x <= length(probs)) ? log(probs[x]) : -Inf
  return 0.0
end

# function Gen.logpdf_grad(::Knightian, x::Int, probs::AbstractArray{U,1}) where {U<:Real}
#   grad = zeros(length(probs))
#   grad[x] = 1.0 / probs[x]
#   (nothing, grad)
# end

function Gen.random(::Knightian, probs::AbstractArray{U,1}) where {U<:Real}
  @assert false "This should not be run!"
  # rand(Distributions.Knightian(probs))
end
Gen.is_discrete(::Knightian) = true

(::Knightian)(probs) = random(Knightian(), probs)

# Gen.has_output_grad(::Knightian) = false
# Gen.has_argument_grads(::Knightian) = (true,)

export knightian
