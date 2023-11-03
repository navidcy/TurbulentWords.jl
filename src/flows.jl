function word_to_flow(word_str::String; kw...)
    word_array = word_to_array(word_str)
    return word_to_flow(word_array; kw...)
end

function word_to_flow(word::AbstractArray;
                      architecture = Oceananigans.Architectures.CPU(),
                      extent = (1, 1),
                      halo = (5, 5),
                      topology = (Periodic, Periodic, Flat))

    word = ensure_even_sized_word(word)

    # Create the word grid
    Nx, Ny = size(word)
    grid = RectilinearGrid(architecture, size=(Nx, Ny); extent, halo, topology)

    solver = FFTBasedPoissonSolver(grid)

    ψ = CenterField(grid)
    ζ = solver.storage .= word

    solve!(ψ, solver, ζ)

    # Interpolate to ffc
    ψᶠᶠᶜ = @at (Face, Face, Center) identity(ψ)
    ψᶠᶠᶜ = compute!(Field(ψᶠᶠᶜ))

    ζᶠᶠᶜ = Field{Face, Face, Center}(grid)
    ζᶠᶠᶜ .= word

    u = compute!(Field(-∂y(ψᶠᶠᶜ)))
    v = compute!(Field(+∂x(ψᶠᶠᶜ)))

    #=
    grid = TwoDGrid(; nx, ny, Lx, Ly)

    ζh = rfft(word)
    ψh = @. - ζh * grid.invKrsq
    uh = @.   im * grid.l  * grid.invKrsq * ζh
    vh = @. - im * grid.kr * grid.invKrsq * ζh

    u = irfft(uh, grid.nx)
    v = irfft(vh, grid.nx)
    ψ = irfft(ψh, grid.nx)
    ζ = irfft(ζh, grid.nx)
    =#

    return u, v, ψᶠᶠᶜ, ζᶠᶠᶜ
end

function word_to_simulation(word)
    uᵢ, vᵢ, ψᵢ, ζᵢ = word_to_flow(word)

    grid = uᵢ.grid
    advection = WENO(order=9)
    model = NonhydrostaticModel(; grid, advection, timestepper = :RungeKutta3)

    set!(model, u=uᵢ, v=vᵢ)
    simulation = Simulation(model, Δt=0.05)

    wizard = TimeStepWizard(cfl=0.8, max_change=1.1, max_Δt=0.2)
    simulation.callbacks[:wizard] = Callback(wizard, IterationInterval(10))
    
    progress(sim) = @info string("Iteration: ", iteration(sim), ", time: ", time(sim), ", Δt: ", sim.Δt)
    simulation.callbacks[:progress] = Callback(progress, TimeInterval(0.5))

    return simulation
end
                                


