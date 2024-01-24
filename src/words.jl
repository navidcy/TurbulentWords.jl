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

    alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyzΑΒΓΔΕΖΗΘΙΚΛΜΝΞΟΠΡΣΤΥΦΧΨΩαβγδεζηθικλμνξοπρστυφχψω"

    for letter in alphabet
        letter_array = bitmap_to_array(letter)
        nx, ny = size(letter_array)
        Nx = max(Nx, nx)
        Ny = max(Ny, ny)
    end

    return Nx, Ny
end

biggest_Nx, biggest_Ny = find_biggest_size()

function letter_to_array(letter, Ny=biggest_Ny; hpad=20)
    letter_array = bitmap_to_array(letter)

    nx, ny = size(letter_array)

    Nx = nx + 2hpad

    bigger_array = zeros(Nx, Ny)

    i, j = (Nx-nx)÷2, (Ny-ny)÷2
    bigger_array[i+1:i+nx, j+1:j+ny] .= letter_array

    return bigger_array
end

alternating(N) = [2isodd(n) - 1 for n = 1:N]

function word_to_array(word;
                       greek = false,
                       multiplicative_factors = ones(length(word)),
                       word_Ny = size(letter_to_array(word[1]), 2),
                       letter_pad::Int = 20,
                       vpad::Int = 0,
                       pad_to_square::Bool = false,
                       hpad::Int = 50)

    Nletters = length(word)

    word_tuple = ntuple(Nletters) do n
        if greek
            letter = word[2n-1]
        else
            letter = word[n]
        end
        factor = multiplicative_factors[n]
        factor .* letter_to_array(letter, word_Ny, hpad=letter_pad)
    end

    Nx = sum(size(letter, 1) for letter in word_tuple)
    Ny = size(word_tuple[1], 2)

    # Write the word with horizontal padding
    hpad = max(1, hpad)
    side_margin = zeros(hpad, Ny)
    word_array = deepcopy(side_margin)

    for letter in word_tuple
        word_array = vcat(word_array, letter)
    end

    word_array = vcat(word_array, side_margin)
    Nx = size(word_array, 1)

    # Add vertical padding
    top_and_bottom_margin = zeros(Nx, vpad)
    word_array = hcat(top_and_bottom_margin, word_array, top_and_bottom_margin)

    if !pad_to_square
        return word_array
    else
        Nx, Ny = size(word_array)

        if Nx == Ny
            return word_array
        elseif Nx > Ny
            square_word_array = zeros(Nx, Nx)
            square_word_array[:, Nx÷2-Ny÷2:Nx÷2+Ny-1-Ny÷2] .= word_array
            return square_word_array
        elseif Ny > Nx
            square_word_array = zeros(Ny, Ny)
            square_word_array[Ny÷2-Nx÷2:Nx÷2+Nx-1-Nx÷2, :] .= word_array
            return square_word_array
        end
    end
end
