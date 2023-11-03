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
                       pad_to_square = false,
                       margin_pad = 50)
    
    word_tuple = Tuple(factor .* letter_to_array(letter; letter_Ny = word_Ny, hpad) for (factor, letter) in zip(multiplicative_factors, word))

    Nx = sum(size(letter, 1) for letter in word_tuple)
    Ny = size(word_tuple[1], 2)

    if margin_pad < 1
        margin_pad = 1
    end

    word_array = zeros(margin_pad, Ny)
    for letter in word_tuple
        word_array = vcat(word_array, letter)
    end
    word_array = vcat(word_array, zeros(margin_pad, Ny))

    if !pad_to_square
        return word_array
    else
        Nx, Ny = size(word_array)

        if Nx == Ny
            return word_array
        elseif Nx > Ny
            square_word_array = zeros(Nx, Nx)
            square_word_array[:, Nx÷2:Nx÷2+Ny-1] .= word_array
            return square_word_array
        elseif Ny > Nx
            square_word_array = zeros(Ny, Ny)
            square_word_array[Ny÷2:Nx÷2+Nx-1, :] .= word_array
            return square_word_array
        end
    end
end

function ensure_even_sized_word(word)
    Nx, Ny = size(word)

    even_sized_word = zeros(Nx + mod(Nx, 2), Ny + mod(Ny, 2))
    even_sized_word[1:Nx, 1:Ny] .= word

    return even_sized_word
end

