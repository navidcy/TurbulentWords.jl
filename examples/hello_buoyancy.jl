# # A stratified turbulence example

using Oceananigans
using TurbulentWords
using CairoMakie

# We construct a simulation with a word and run it.

simulation = word_to_simulation("hello", dynamics=:buoyancy_driven, pad_to_square=true)
simulation.stop_time = 0.8

model = simulation.model
b = model.tracers.b
outputs = (; b)
filename = "hello_buoyancy"
simulation.output_writers[:fields] = JLD2OutputWriter(model, outputs,
                                                      schedule = TimeInterval(0.02),
                                                      filename = filename * ".jld2",
                                                      overwrite_existing = true)


run!(simulation)

# Now we load the saved output

bt = FieldTimeSeries(filename * ".jld2", "b")
times = bt.times

# and make a movie

fig = Figure(resolution = (600, 600))
ax = Axis(fig[1, 1])
hidedecorations!(ax)
hidespines!(ax)
n = Observable(1)

bn = @lift bt[$n]

blim = 0.8
heatmap!(ax, bn; colormap = :balance, colorrange = (-blim, blim))

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

# ![](hello_buoyancy.mp4)
