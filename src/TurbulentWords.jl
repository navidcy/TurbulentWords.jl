module TurbulentWords

using FourierFlows
using CairoMakie

export letter_to_array, find_biggest_size, bitmap_to_array, word_to_array

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

function word_to_array(word; word_Ny = size(letter_to_array(word[1]), 2), hpad=20)
    
    word_tuple = Tuple(letter_to_array(letter; letter_Ny = word_Ny, hpad) for letter in word)
    Nx = sum(size(letter, 1) for letter in word_tuple)
    Ny = size(word_tuple[1], 2)

    word_array = word_tuple[1]

    for letter in word_tuple[2:end]
        word_array = vcat(word_array, letter)
    end

    return word_array
end

end # module TurbulentWords
