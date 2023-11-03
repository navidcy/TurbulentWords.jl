"""
    bitmap_to_array(letter)

Return an array of booleans that correspond to the bitmap
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
    Nx, Ny = 0, 0

    alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

    for letter in alphabet
        letter_array = bitmap_to_array(letter)
        nx, ny = size(letter_array)
        Nx = max(Nx, nx)
        Ny = max(Ny, ny)
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

alternating(N) = [2isodd(n) - 1 for n = 1:N]

function word_to_array(word;
                       multiplicative_factors = ones(length(word)),
                       word_Ny = size(letter_to_array(word[1]), 2),
                       hpad = 20,
                       pad_to_square = false,
                       margin_pad = 50)
    
    Nletters = length(word)

    word_tuple = ntuple(Nletters) do n
        letter = word[n]
        factor = multiplicative_factors[n]
        factor .* letter_to_array(letter; letter_Ny=word_Ny, hpad)
    end

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
