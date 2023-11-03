# TurbulentWords.jl

Create initial conditions from words for fluid simulations.

```julia
using TurbulentWords

fig = Figure(resolution = (2000, 600))
ax = Axis(fig[1, 1])
heatmap!(ax, word_to_array("GREG & NAVID", hpad=25))
fig
```

![demo](https://github.com/navidcy/TurbulentWords.jl/assets/7112768/850552df-a8dd-461f-941d-e9e65f6f8f26)
