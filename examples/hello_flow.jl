using TurbulentWords
using CairoMakie

hi = word_to_array("hello",
                   pad_to_square = true,
                   multiplicative_factors = alternating(5))

fig = Figure(resolution=(800, 800))
ax = Axis(fig[1, 1], aspect=1)
heatmap!(ax, hi, colormap=:balance)
fig

u, v, ψ, ζ = word_to_flow(hi)

ulim = 0.05
fig = Figure(resolution=(800, 400))
axu = Axis(fig[1, 1], aspect=1, title="u")
axv = Axis(fig[1, 2], aspect=1, title="v")
heatmap!(axu, interior(u, :, :, 1), colorrange=(-ulim, ulim), colormap=:balance)
heatmap!(axv, interior(v, :, :, 1), colorrange=(-ulim, ulim), colormap=:balance)
fig
