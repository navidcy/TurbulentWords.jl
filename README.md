# TurbulentWords.jl

Make turbulence from words.

![demo-clima](https://github.com/navidcy/TurbulentWords.jl/assets/7112768/b9efefc0-73c1-4206-9144-4c25af9ce25f)

The above animation was created with [`examples/two_dimensional_turbulence.jl`](https://github.com/navidcy/TurbulentWords.jl/blob/main/examples/two_dimensional_turbulence.jl).


## Installation

To install, from a Julia REPL:

```julia
julia> ]

pkg> add https://github.com/navidcy/TurbulentWords.jl.git

pkg> instantiate
```

## Usage

A simple word:

```julia
using TurbulentWords
using CairoMakie

fig = Figure(resolution = (2200, 450))
ax = Axis(fig[1, 1])
heatmap!(ax, word_to_array("A WORDY PHRASE", hpad=25))
fig
```

![demo](https://github.com/navidcy/TurbulentWords.jl/assets/7112768/d9c0696a-61a1-44d6-a5bc-00e99a59ed9b)

We can also create a two-dimensional incompressible flow from a word and use it to initialize a fluid simulation.

```julia
using TurbulentWords
using CairoMakie

ζ = word_to_array("CliMA", multiplicative_factors = (1, -1, 1, -1, 1), pad_to_square=true) # vorticity
u, v, ψ = compute_velocities_and_streamfunction_from_vorticityword(ζ)

fig = Figure(resolution = (1200, 1200))

ax1 = Axis(fig[1, 1], aspect=1, title="vorticity")
ax2 = Axis(fig[1, 2], aspect=1, title="streamfunction")
ax3 = Axis(fig[2, 1], aspect=1, title="u")
ax4 = Axis(fig[2, 2], aspect=1, title="v")

heatmap!(ax1, ζ, colormap=:balance)
heatmap!(ax2, ψ, colormap=:speed)
heatmap!(ax3, u, colormap=:balance)
heatmap!(ax4, v, colormap=:balance)

fig
```

![demo-clima](https://github.com/navidcy/TurbulentWords.jl/assets/7112768/8b294b74-ef50-4ac8-84bf-f2b05483f7e1)
