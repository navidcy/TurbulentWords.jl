# TurbulentWords.jl

Make turbulence from words.

![demo-clima](https://github.com/navidcy/TurbulentWords.jl/assets/7112768/b9efefc0-73c1-4206-9144-4c25af9ce25f)

## Installation

To install from a Julia REPL:

```julia
julia> ]

pkg> add https://github.com/navidcy/TurbulentWords.jl.git

pkg> instantiate
```

## Usage

### A turbulent word

```julia
using TurbulentWords
using CairoMakie

fig = Figure(resolution = (2200, 450))
ax = Axis(fig[1, 1])
word = word_to_array("TUMULTUOUS", hpad=25)
heatmap!(ax, word)
fig
```

<img width="1421" alt="image" src="https://github.com/navidcy/TurbulentWords.jl/assets/15271942/2902699a-db72-4e27-bfac-6c4cb4476fa1">

### A turbulent flow

```julia
using TurbulentWords
using Oceananigans
using CairoMakie

u, v, ψ, ζ = word_to_flow("TEMPESTUOUS")

fig = Figure(resolution = (1200, 1200))

ax1 = Axis(fig[1, 1], aspect=1, title="vorticity")
ax2 = Axis(fig[1, 2], aspect=1, title="streamfunction")
ax3 = Axis(fig[2, 1], aspect=1, title="u")
ax4 = Axis(fig[2, 2], aspect=1, title="v")

heatmap!(ax1, interior(ζ, :, :, 1), colormap=:balance)
heatmap!(ax2, interior(ψ, :, :, 1), colormap=:speed)
heatmap!(ax3, interior(u, :, :, 1), colormap=:balance)
heatmap!(ax4, interior(v, :, :, 1), colormap=:balance)

fig
```

![demo-clima](https://github.com/navidcy/TurbulentWords.jl/assets/7112768/8b294b74-ef50-4ac8-84bf-f2b05483f7e1)

### A turbulent simulation

```julia
using TurbulentWords
using Oceananigans
using CairoMakie

simulation = word_to_simulation("STORMY")
simulation.stop_time = 0.1
run!(simulation)
```

### Another turbulent simulation

```julia
using TurbulentWords
using Oceananigans
using CairoMakie

simulation = word_to_simulation("ROILING", dynamics=:buoyancy_driven)
simulation.stop_time = 0.1
run!(simulation)
```

