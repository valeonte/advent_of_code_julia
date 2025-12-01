module day_21_directional

using Test

directional_keys = Dict{Char, Tuple{Int8, Int8}}([
    ('^', (1, 1)),
    ('A', (1, 2)),
    ('<', (0, 0)),
    ('v', (0, 1)),
    ('>', (0, 2)),
])


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
        if (cur_row, cur_col) == (1, 0)
            return false
        end
    end
    return true
end


function get_all_presses_directional(cur_pos::Char, target_pos::Char)::Vector{String}
    cur_row, cur_col = directional_keys[cur_pos]
    target_row, target_col = directional_keys[target_pos]

    right = target_col - cur_col
    if right > 0
        ret1 = ">" ^ right
    elseif right < 0
        ret1 = "<" ^ (-right)
    else
        ret1 = ""
    end

    down = cur_row - target_row
    if down > 0
        ret2 = "v" ^ down
    elseif down < 0
        ret2 = "^" ^ (-down)
    else
        ret2 = ""
    end

    all_ret::Vector{String} = []
    if right != 0 && down != 0
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

@test "v<" in get_all_presses_directional('A', 'v')
@test get_all_presses_directional('<', '^') == [">^"]


function get_presses_for_directional_string(series::String)::Vector{String}
    all_ret = [""]
    cur_pos = 'A'
    for ch in series
        new_ret::Vector{String} = []
        for ret in get_all_presses_directional(cur_pos, ch)
            for pre_ret in all_ret
                push!(new_ret, pre_ret * ret * "A")
            end
        end
        all_ret = new_ret
        cur_pos = ch
    end

    return all_ret
end

@test "v<<A>>^A<A>AvA^<AA>Av<AAA>^A" in get_presses_for_directional_string("<A^A>^^AvvvA")
@test "v<A<AA>>^AvAA^<A>Av<<A>>^AvA^Av<A>^A<Av<A>>^AAvA^Av<A<A>>^AAAvA^<A>A" in get_presses_for_directional_string("v<<A>>^A<A>AvA^<AA>Av<AAA>^A")

end
