module TurbulentWords

using CairoMakie
using Oceananigans
using Oceananigans.Solvers: FFTBasedPoissonSolver, solve!

export letter_to_array,
       word_to_array,
       word_to_flow,
       word_to_simulation

include("words.jl")
include("flows.jl")

end # module TurbulentWords

