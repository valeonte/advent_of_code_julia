module day_21_numeric

using Test


function get_numeric_button_coords(pos::Char)::Tuple{Int8, Int8}
    if pos == 'A'
        row, col = 0, 2
    elseif pos == '0'
        row, col = 0, 1
    else
        int_pos = parse(Int8, pos)
        row, col = div(int_pos - 1, 3) + 1, rem(int_pos - 1, 3)
    end

    return row, col
end

@test get_numeric_button_coords('A') == (0, 2)
@test get_numeric_button_coords('0') == (0, 1)
@test get_numeric_button_coords('7') == (3, 0)


function is_good_path(cur_row::Integer, cur_col::Integer, path::Union{Vector{Char}, String})::Bool
    for ch in path
        if ch == '^'
            cur_row += 1
        elseif ch == 'v'
            cur_row -= 1
        elseif ch == '<'
            cur_col -= 1
        elseif ch == '>'
            cur_col += 1
        else
            throw("Bad char: $ch")
        end
        if (cur_row, cur_col) == (0, 0)
            return false
        end
    end
    return true
end


function get_all_presses_numeric(cur_pos::Char, target_pos::Char)::Vector{String}
    cur_row, cur_col = get_numeric_button_coords(cur_pos)
    target_row, target_col = get_numeric_button_coords(target_pos)

    up = target_row - cur_row
    if up > 0
        ret1 = "^" ^ up
    elseif up < 0
        ret1 = "v" ^ (-up)
    else
        ret1 = ""
    end

    right = target_col - cur_col
    if right > 0
        ret2 = ">" ^ right
    elseif right < 0
        ret2 = "<" ^ (-right)
    else
        ret2 = ""
    end

    all_ret::Vector{String} = []
    if right != 0 && up != 0
        # Check and add
        if is_good_path(cur_row, cur_col, ret1*ret2)
            push!(all_ret, ret1*ret2)
        end
        if is_good_path(cur_row, cur_col, ret2*ret1)
            push!(all_ret, ret2*ret1)
        end
    else
        # If it is one, it is good
        push!(all_ret, ret1 * ret2)
    end

    return all_ret
end

@test get_all_presses_numeric('A', '0') == ["<"]
@test "^^<<" in get_all_presses_numeric('A', '4')


function get_presses_for_numeric_string(series::String)::Vector{String}

    all_ret = [""]
    cur_pos = 'A'
    for ch in series
        new_ret::Vector{String} = []
        for ret in get_all_presses_numeric(cur_pos, ch)
            for pre_ret in all_ret
                push!(new_ret, pre_ret * ret * "A")
            end
        end
        all_ret = new_ret
        cur_pos = ch
    end

    return all_ret
end

# @test get_presses_for_numeric_string("029A") == "<A^A^^>AvvvA"

end
