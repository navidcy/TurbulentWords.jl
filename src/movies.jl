function word_to_movie(word, filename; kw...)
    simulation = word_to_simulation(word; kw...)

    model = simulation.model
    u, v, w = model.velocities
    outputs = (; ζ = ∂x(v) - ∂y(u))
    filename = "word_turbulence"
    simulation.output_writers[:fields] = JLD2OutputWriter(model, outputs,
                                                          schedule = IterationInterval(10),
                                                          filename = filename * ".jld2",
                                                          overwrite_existing = true)

    run!(simulation)

    ζt = FieldTimeSeries(filename * ".jld2", "ζ")
    times = ζt.times

    fig = Figure(resolution = (600, 600))
    ax = Axis(fig[1, 1])
    hidedecorations!(ax)
    hidespines!(ax)
    n = Observable(1)

    ζₙ = @lift interior(ζt[$n], :, :, 1)

    ζmax = 0.8
    heatmap!(ax, ζₙ; colormap = :balance, colorrange = (-ζmax, ζmax))

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
end
