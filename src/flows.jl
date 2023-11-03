function word_to_flow(word_str::String; kw...)

    word_array = word_to_array(word_str;
                               multiplicative_factors = alternating(length(word_str)),
                               kw...)

    return word_to_flow(word_array; kw...)
end

function word_to_flow(word::AbstractArray;
                      architecture = CPU(),
                      extent = (1, 1),
                      halo = (5, 5),
                      topology = (Periodic, Periodic, Flat),
                      kw...)

    word = ensure_even_sized_word(word)

    # Create the word grid
    Nx, Ny = size(word)
    grid = RectilinearGrid(architecture, size=(Nx, Ny); extent, halo, topology)

    solver = FFTBasedPoissonSolver(grid)

    ψ = CenterField(grid)
    ζ = solver.storage .= word

    # solve for streamfunction
    solve!(ψ, solver, ζ)

    # Interpolate to ffc
    ψᶠᶠᶜ = @at (Face, Face, Center) identity(ψ)
    ψᶠᶠᶜ = compute!(Field(ψᶠᶠᶜ))

    ζᶠᶠᶜ = Field{Face, Face, Center}(grid)
    ζᶠᶠᶜ .= word

    # compute velocities from streamfunction
    u = compute!(Field(-∂y(ψᶠᶠᶜ)))
    v = compute!(Field(+∂x(ψᶠᶠᶜ)))

    return u, v, ψᶠᶠᶜ, ζᶠᶠᶜ
end
