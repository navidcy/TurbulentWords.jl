# # Hello flow example

using TurbulentWords
using Oceananigans
using CairoMakie

hi = word_to_array("hello",
                   pad_to_square = true,
                   multiplicative_factors = alternating(5))

fig = Figure(size=(400, 400))
ax = Axis(fig[1, 1], aspect=1)
heatmap!(ax, hi, colormap=:balance)
fig

# ## Convert word to flow

# `word_to_flow` considers the word as the vertical vorticity of a two-dimensional flow
# and then it computes the incompressible flow ``u`` and ``v``, as well as the streamfunction
# ``\psi`` that correspond to that vorticity distribution.

u, v, ψ, ζ = word_to_flow(hi)

ulim = 0.05
fig = Figure(size=(800, 400))
axu = Axis(fig[1, 1], aspect=1, title="zonal velocity u")
axv = Axis(fig[1, 2], aspect=1, title="meridional velocity v")
heatmap!(axu, interior(u, :, :, 1), colorrange=(-ulim, ulim), colormap=:balance)
heatmap!(axv, interior(v, :, :, 1), colorrange=(-ulim, ulim), colormap=:balance)
fig
