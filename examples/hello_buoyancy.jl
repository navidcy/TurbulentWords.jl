using Oceananigans
using TurbulentWords
using CairoMakie

simulation = word_to_simulation("hello", dynamics=:buoyancy_driven, pad_to_square=true)
simulation.stop_time = 0.1

model = simulation.model
b = model.tracers
outputs = (; b)
filename = "hello_buoyancy.jld2"
simulation.output_writers[:fields] = JLD2OutputWriter(model, outputs,
                                                      schedule = TimeInterval(0.01),
                                                      filename = filename,
                                                      overwrite_existing = true)


run!(simulation)

bt = FieldTimeSeries(filename, "b")

fig = Figure(resolution = (600, 600))
ax = Axis(fig[1, 1])
hidedecorations!(ax)
hidespines!(ax)
n = Observable(1)

bₙ = @lift interior(bt[$n], :, :, 1)

bmax = 0.8
heatmap!(ax, bₙ; colormap = :balance, colorrange = (-bmax, bmax))

stillframes = 20
framerate = 60
movingframes = length(times)

record(fig, filename * ".gif", framerate=60) do io
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
