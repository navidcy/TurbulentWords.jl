function word_to_simulation(word; kw...)
    uᵢ, vᵢ, ψᵢ, ζᵢ = word_to_flow(word; kw...)

    grid = uᵢ.grid
    advection = WENO(order=9)
    model = NonhydrostaticModel(; grid, advection, timestepper = :RungeKutta3)

    set!(model, u=uᵢ, v=vᵢ)
    simulation = Simulation(model, Δt=0.01, stop_time=1)

    wizard = TimeStepWizard(cfl=0.8, max_change=1.1)
    simulation.callbacks[:wizard] = Callback(wizard, IterationInterval(5))
    
    progress(sim) = @info string("Iteration: ", iteration(sim), ", time: ", time(sim), ", Δt: ", sim.Δt)
    simulation.callbacks[:progress] = Callback(progress, IterationInterval(10))

    return simulation
end
