using Oceananigans, TurbulentWords

using Oceananigans.Architectures: arch_array

Lx = Ly = 2π

# construct u and v from word
ζᵢ = word_to_array("CliMA",
                   multiplicative_factors = (1, -1, 1, -1, 1),
                   pad_to_square = true,
                   margin_pad = 90)

uᵢ, vᵢ, ψᵢ, ζᵢ = compute_velocities_and_streamfunction_from_vorticityword(ζᵢ; Lx, Ly)

Nx, Ny = size(ζᵢ)

arch = CPU()
grid = RectilinearGrid(arch, size=(Nx, Ny),
                       extent=(Lx, Ly),
                       halo = (5, 5),
                       topology=(Periodic, Periodic, Flat))

model = NonhydrostaticModel(; grid,
                            timestepper = :RungeKutta3,
                            advection = WENO(order=9))

u, v, w = model.velocities

# set the velocities from the word-velocities
interior(u)[1:Nx, 1:Ny, 1] .= arch_array(arch, uᵢ)
interior(v)[1:Nx, 1:Ny, 1] .= arch_array(arch, vᵢ)

simulation = Simulation(model, Δt=0.05, stop_time=10)

wizard = TimeStepWizard(cfl=0.8, max_change=1.1, max_Δt=0.2)
simulation.callbacks[:wizard] = Callback(wizard, IterationInterval(5))

progress(sim) = @info string("Iteration: ", iteration(sim), ", time: ", time(sim), ", Δt: ", sim.Δt)
simulation.callbacks[:progress] = Callback(progress, TimeInterval(0.5))

# Output
ζ = ∂x(v) - ∂y(u)

filename = "clima"
simulation.output_writers[:fields] = JLD2OutputWriter(model, (; ζ),
                                                      schedule = TimeInterval(0.25),
                                                      filename = filename * ".jld2",
                                                      overwrite_existing = true)

run!(simulation)

# load saved output

ζ_timeseries = FieldTimeSeries(filename * ".jld2", "ζ")
times = ζ_timeseries.times
x, y, z = nodes(ζ_timeseries)

# and make animation

using CairoMakie

n = Observable(1)

ζmax = 0.8

fig = Figure(resolution = (600, 600))
ax = Axis(fig[1, 1]; limits = ((0, Lx), (0, Ly)), aspect = AxisAspect(1))

ζₙ = @lift interior(ζ_timeseries[$n], :, :, 1)

heatmap!(ax, x, y, ζₙ; colormap = :balance, colorrange = (-ζmax, ζmax))

hidedecorations!(ax)
hidespines!(ax)

fig

still_frames = 20 # add some still frames in the beginning and end

record(fig, filename * ".gif", framerate=60) do io
    for _ in 1:still_frames
        recordframe!(io)
    end

    @info "loop forward"
    for i in 1:4:length(times)
        @info i
        n[] = i
        recordframe!(io)
    end

    @info "loop backward"
    for i in length(times):-4:1
        @info i
        n[] = i
        recordframe!(io)
    end

    for _ in 1:still_frames
        recordframe!(io)
    end
end
