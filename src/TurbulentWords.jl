module TurbulentWords

using FourierFlows
using CairoMakie

export letter_to_array,
       word_to_array,
       compute_velocities_and_streamfunction_from_vorticityword,
       compute_velocities_and_vorticity_from_streamfunctionword

"""
    bitmap_to_array(letter)

Return an array of 1s and 0s that correspond to the bitmap
pattern of the `letter` character provided.
"""
function bitmap_to_array(letter)
    font = Makie.defaultfont()
    glyph_index = Makie.FreeTypeAbstraction.glyph_index(font, letter)
    bitmap, extent = Makie.renderface(font, glyph_index, 128)
    bools = bitmap[:, end:-1:1] .>  0

    return bools
end

function find_biggest_size()
    Mx, My = 0, 0

    alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

    for letter in alphabet
        letter_array = bitmap_to_array(letter)
        mx, my = size(letter_array)
        Mx = max(Mx, mx)
        My = max(My, my)
    end

    return Mx, My
end

Nx, Ny = find_biggest_size()

function letter_to_array(letter; letter_Ny=Ny, hpad=20)
    letter_array = bitmap_to_array(letter)

    nx, ny = size(letter_array)

    Ny = letter_Ny
    Nx = nx + 2hpad

    bigger_array = zeros(Nx, Ny)

    i, j = (Nx-nx)÷2, (Ny-ny)÷2
    bigger_array[i+1:i+nx, j+1:j+ny] .= letter_array

    return bigger_array
end

function word_to_array(word;
                       multiplicative_factors = Tuple(ones(length(word))),
                       word_Ny = size(letter_to_array(word[1]), 2),
                       hpad = 20,
                       pad_to_square = false)
    
    word_tuple = Tuple(factor .* letter_to_array(letter; letter_Ny = word_Ny, hpad) for (factor, letter) in zip(multiplicative_factors, word))

    Nx = sum(size(letter, 1) for letter in word_tuple)
    Ny = size(word_tuple[1], 2)

    word_array = word_tuple[1]

    for letter in word_tuple[2:end]
        word_array = vcat(word_array, letter)
    end

    if !pad_to_square
        return word_array
    else
        nx, ny = size(word_array)

        if nx == ny
            return word_array
        elseif nx > ny
            square_word_array = zeros(nx, nx)
            square_word_array[:, nx÷2:nx÷2+ny-1] .= word_array
            return square_word_array
        elseif ny > nx
            square_word_array = zeros(ny, ny)
            square_word_array[ny÷2:nx÷2+nx-1, :] .= word_array
            return square_word_array
        end
    end
end

function ensure_even_sized_word(word)
    nx, ny = size(word)

    even_sized_word = zeros(nx + mod(nx, 2), ny + mod(ny, 2))
    even_sized_word[1:nx, 1:ny] .= word

    return even_sized_word
end

function compute_velocities_and_vorticity_from_streamfunctionword(word)
    word = ensure_even_sized_word(word)
    nx, ny = size(word)

    grid = TwoDGrid(; nx, ny, Lx=nx, Ly=ny)

    ψh = rfft(word)
    uh = @. - im * grid.l  * ψh
    vh = @.   im * grid.kr * ψh
    u = irfft(uh, grid.nx)
    v = irfft(vh, grid.nx)

    ζh = @. - ζh * grid.Krsq
    ζ = irfft(ζh, grid.nx)

    return u, v, ζ
end

function compute_velocities_and_streamfunction_from_vorticityword(word)
    word = ensure_even_sized_word(word)
    nx, ny = size(word)

    grid = TwoDGrid(; nx, ny, Lx=nx, Ly=ny)

    ζh = rfft(word)
    ψh = @. - ζh * grid.invKrsq
    ψ = irfft(ψh, grid.nx)
    uh = @.   im * grid.l  * grid.invKrsq * ζh
    vh = @. - im * grid.kr * grid.invKrsq * ζh
    u = irfft(uh, grid.nx)
    v = irfft(vh, grid.nx)

    return u, v, ψ
end

end # module TurbulentWords
