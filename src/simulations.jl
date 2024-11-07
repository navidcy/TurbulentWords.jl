function word_to_simulation(word;
                            dynamics = :two_dimensional_turbulence,
                            other_kw...)

    return word_to_simulation(Val(dynamics), word; other_kw...)
end

function word_to_simulation(::Val{:two_dimensional_turbulence}, word;
                            pad_to_square = true,
                            advection = WENO(order=9),
                            other_kw...)

    uᵢ, vᵢ, ψᵢ, ζᵢ = word_to_flow(word; pad_to_square, other_kw...)

    grid = uᵢ.grid
    pressure_solver = FFTBasedPoissonSolver(grid, FFTW.MEASURE)
    model = NonhydrostaticModel(; grid, advection, pressure_solver)
    set!(model, u=uᵢ, v=vᵢ)

    simulation = Simulation(model, Δt=0.01, stop_time=1)
    add_wizard_and_progress!(simulation)

    return simulation
end

function word_to_simulation(::Val{:buoyancy_driven}, word;
                            pad_to_square = true,
                            advection = WENO(order=5),
                            architecture = CPU(),
                            extent = (1, 1),
                            halo = (5, 5),
                            other_kw...)

    bᵢ = word_to_array(word;
                       pad_to_square,
                       multiplicative_factors = alternating(length(word)),
                       other_kw...)

    Nx, Nz = size(bᵢ)
    topology = (Periodic, Flat, Bounded)
    grid = RectilinearGrid(architecture, size=(Nx, Nz); extent, halo, topology)

    pressure_solver = FFTBasedPoissonSolver(grid, FFTW.MEASURE)
    model = NonhydrostaticModel(; grid, advection, pressure_solver,
                                tracers = :b,
                                buoyancy = BuoyancyTracer())

    bᵢ = reshape(bᵢ, Nx, 1, Nz) # assumes that y-topology is Flat
    set!(model, b=bᵢ)

    simulation = Simulation(model, Δt=0.01, stop_time=1)
    add_wizard_and_progress!(simulation)

    return simulation
end

function add_wizard_and_progress!(simulation)
    wizard = TimeStepWizard(cfl=0.8, max_change=1.1)
    simulation.callbacks[:wizard] = Callback(wizard, IterationInterval(5))

    wall_clock = Ref(time_ns())

    function progress(sim)
        elapsed = 1e-9 * (time_ns() - wall_clock[])
        @info string("Iteration: ", iteration(sim),
                     ", time: ", time(sim),
                     ", wall time: ", prettytime(elapsed),
                     ", Δt: ", sim.Δt)
        wall_clock[] = time_ns()
        return nothing
    end

    simulation.callbacks[:progress] = Callback(progress, IterationInterval(10))

    return nothing
end
