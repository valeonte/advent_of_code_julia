input = """L68
L30
R48
L5
R60
L55
L1
L99
R14
L82""";

input = read("src/2025/inputs/day_1.txt", String);

function move_dial(pos::Integer, rotation)::Integer
    dir = rotation[1]
    distance = parse(Int, rotation[2:end])
    if dir == 'L'
        pos -= rem(distance, 100)
        if pos < 0
            pos += 100
        end
    else
        pos = rem(pos + distance, 100)
    end
    return pos
end


function count_zeros(start_pos::Integer, input_string::String)::Integer
    cur_pos = start_pos
    zero_counter = 0
    for rot in eachsplit(input_string, "\n")
        new_pos = move_dial(cur_pos, rot)
        if new_pos == 0
            zero_counter += 1
        end
        # println("$cur_pos -> $rot -> $new_pos")
        cur_pos = new_pos
    end

    return zero_counter
end


zeros = count_zeros(50, input)
println("Answer 1: $zeros")


function move_dial2(pos::Integer, rotation)::Tuple{Integer, Integer}
    """Return new position and times it crossed 0."""
    dir = rotation[1]
    distance = parse(Int, rotation[2:end])
    zero_crosses = div(distance, 100)
    if dir == 'L'
        if pos == 0
            # To avoid double-counting the 0s
            pos = 100-rem(distance, 100)
        else
            pos -= rem(distance, 100)
            if pos <= 0
                zero_crosses += 1
                if pos < 0
                    pos += 100
                end
            end
        end
    else
        pos += rem(distance, 100)
        if pos >= 100
            zero_crosses += 1
            pos -= 100
        end
    end
    return pos, zero_crosses
end


function count_zero_crosses(start_pos::Integer, input_string::String)::Integer
    cur_pos = start_pos
    zero_crosses = 0
    for rot in eachsplit(input_string, "\n")
        new_pos, new_zero_crosses = move_dial2(cur_pos, rot)
        # println("$cur_pos -> $rot -> $new_pos, $new_zero_crosses")
        zero_crosses += new_zero_crosses
        cur_pos = new_pos
    end

    return zero_crosses
end

zero_crosses = count_zero_crosses(50, input)

println("Answer 2: $zero_crosses")
