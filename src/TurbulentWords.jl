"""
Create turbulent animations from words using Oceananigans.jl
"""
module TurbulentWords

using CairoMakie
using Oceananigans
using FFTW
using Oceananigans.Solvers: FFTBasedPoissonSolver, solve!
using Oceananigans.BoundaryConditions: fill_halo_regions!

export letter_to_array,
       alternating,
       word_to_array,
       word_to_flow,
       word_to_simulation

include("words.jl")
include("flows.jl")
include("simulations.jl")
include("movies.jl")

end # module TurbulentWords
