module TurbulentWords

using CairoMakie
using Oceananigans
using Oceananigans.Solvers: FFTBasedPoissonSolver, solve!

export letter_to_array,
       word_to_array,
       word_to_flow,
       alternating,
       word_to_simulation

include("words.jl")
include("flows.jl")
include("simulations.jl")
include("movies.jl")

end # module TurbulentWords
