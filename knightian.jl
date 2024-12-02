struct Knightian <: Distribution{Int} end

"""
    knightian(low::Integer, high::Integer)

Represents a Knightian choice from the set {low, low + 1, ..., high-1, high}.
Code modified from `uniform_discrete.jl`.
"""
const knightian = Knightian()

function Gen.logpdf(::Knightian, x::Int, low::Integer, high::Integer)
  return 0.0
end

# TODO I'm not sure if any of the grad functions need to change.
function Gen.logpdf_grad(::Knightian, x::Int, lower::Integer, high::Integer)
  (nothing, nothing, nothing)
end

function Gen.random(::Knightian, low::Integer, high::Integer)
  @assert false "You cannot sample from the Knightian distribution!"
end
Gen.is_discrete(::Knightian) = true

(::Knightian)(low, high) = Gen.random(Knightian(), low, high)

Gen.has_output_grad(::Knightian) = false
Gen.has_argument_grads(::Knightian) = (false, false)

export knightian
