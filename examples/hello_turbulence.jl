# # A two-dimensional turbulence example

using Oceananigans
using TurbulentWords
using CairoMakie

# We construct a simulation with a word and run it.

simulation = word_to_simulation("hello", pad_to_square=true)
simulation.stop_time = 10

model = simulation.model
u, v, w = model.velocities
outputs = (; ζ = ∂x(v) - ∂y(u))
filename = "hello_turbulence"
simulation.output_writers[:fields] = JLD2OutputWriter(model, outputs,
                                                      schedule = TimeInterval(0.1),
                                                      filename = filename * ".jld2",
                                                      overwrite_existing = true)

run!(simulation)

# Now we load the saved output

ζt = FieldTimeSeries(filename * ".jld2", "ζ")
times = ζt.times

# and make a movie

fig = Figure(resolution = (600, 600))
ax = Axis(fig[1, 1])
hidedecorations!(ax)
hidespines!(ax)

n = Observable(1)

ζn = @lift ζt[$n]

ζlim = 0.8
heatmap!(ax, ζn; colormap = :balance, colorrange = (-ζlim, ζlim))

stillframes = 20
framerate = 60
movingframes = length(times)

record(fig, filename * ".mp4", framerate=32) do io
    [recordframe!(io) for _ = 1:stillframes]

    for nn in 1:movingframes
        n[] = nn
        recordframe!(io)
    end

    for nn in movingframes:-1:1
        n[] = nn
        recordframe!(io)
    end

    [recordframe!(io) for _ = 1:stillframes]
end

# ![](hello_turbulence.mp4)
