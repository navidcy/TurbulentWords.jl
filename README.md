# TurbulentWords.jl

<p align="left">
    <a href="https://navidcy.github.io/TurbulentWords.jl/stable">
        <img alt="stable docs" src="https://img.shields.io/badge/documentation-in%20stable-blue">
    </a>
    <a href="https://navidcy.github.io/TurbulentWords.jl/dev">
        <img alt="latest docs" src="https://img.shields.io/badge/documentation-in%20development-orange">
    </a>

   <a href="https://github.com/navidcy/TurbulentWords.jl/releases">
      <img alt="GitHub tag (latest SemVer pre-release)" src="https://img.shields.io/github/v/tag/navidcy/TurbulentWords.jl?include_prereleases&label=latest%20version&logo=github&sort=semver&style=flat-square">
   </a>
    <a href="https://github.com/SciML/ColPrac">
      <img alt="ColPrac: Contributor's Guide on Collaborative Practices for Community Packages" src="https://img.shields.io/badge/ColPrac-Contributor's%20Guide-blueviolet">
    </a>
</p>

*Make turbulence with words.*

![demo-clima](https://github.com/navidcy/TurbulentWords.jl/assets/7112768/b9efefc0-73c1-4206-9144-4c25af9ce25f)

## Installation

To install from a Julia REPL:

```julia
julia> ]

pkg> add TurbulentWords

pkg> instantiate
```

TurbulentWords.jl requires Julia v1.6 or later but we encourage using Julia v1.10.

## Usage

### A turbulent word

```julia
using TurbulentWords
using CairoMakie

fig = Figure(size=(2400, 300))
ax = Axis(fig[1, 1])
word = word_to_array("TUMULTUOUS")
heatmap!(ax, word)
fig
```

<img width="1421" alt="image" src="https://github.com/navidcy/TurbulentWords.jl/assets/15271942/2902699a-db72-4e27-bfac-6c4cb4476fa1">

### A turbulent flow

```julia
using TurbulentWords
using Oceananigans
using CairoMakie

u, v, ψ, ζ = word_to_flow("TEMPESTUOUS", vpad=50)

fig = Figure(size = (800, 800))

ax1 = Axis(fig[1, 1], title="Vorticity, ∂v/∂x - ∂u/∂y")
ax2 = Axis(fig[2, 1], title="Streamfunction, ψ")
ax3 = Axis(fig[3, 1], title="u = - ∂ψ/∂y")
ax4 = Axis(fig[4, 1], title="v = + ∂ψ/∂x")

[hidedecorations!(ax) for ax in (ax1, ax2, ax3, ax4)]

heatmap!(ax1, interior(ζ, :, :, 1), colormap=:balance, colorrange = (-1.2, 1.2))
heatmap!(ax2, interior(ψ, :, :, 1), colormap=:speed)
heatmap!(ax3, interior(u, :, :, 1), colormap=:balance)
heatmap!(ax4, interior(v, :, :, 1), colormap=:balance)

fig
```

![image](https://github.com/navidcy/TurbulentWords.jl/assets/7112768/c1602b42-46cb-4c85-b972-52319b31f7a8)

### A turbulent simulation

```julia
using TurbulentWords
using Oceananigans
using CairoMakie

simulation = word_to_simulation("STORMY")
simulation.stop_time = 5
run!(simulation)

model = simulation.model
u, v, w = model.velocities
ζ = Field(∂x(v) - ∂y(u)) |> compute!

fig = Figure()
ax = Axis(fig[1, 1])
hidedecorations!(ax)
heatmap!(ax, interior(ζ, :, :, 1), colormap=:balance)

fig
```

![image](https://github.com/navidcy/TurbulentWords.jl/assets/15271942/9f5c4f4c-4306-4dbc-a72f-2bf41c250b92)


### Another turbulent simulation

```julia
using TurbulentWords
using Oceananigans
using CairoMakie

simulation = word_to_simulation("ROILING", dynamics=:buoyancy_driven)
simulation.stop_time = 0.3
run!(simulation)

b = simulation.model.tracers.b

fig = Figure()
ax = Axis(fig[1, 1])
hidedecorations!(ax)
heatmap!(ax, interior(b, :, 1, :), colormap=:balance)

fig
```

![image](https://github.com/navidcy/TurbulentWords.jl/assets/15271942/bec3e795-a72f-43d5-a05d-3a65ec5852c2)

It's too cool (hot?) to stop at just 0.3 though

```julia
simulation.stop_time = 0.5
run!(simulation)
heatmap!(ax, interior(b, :, 1, :), colormap=:balance)

fig
```

![image](https://github.com/navidcy/TurbulentWords.jl/assets/15271942/741739a4-2e39-4f2e-8cbf-0807d5d01faa)
