input = """..@@.@@@@.
@@@.@.@.@@
@@@@@.@.@@
@.@@@@..@.
@@.@@@@.@@
.@@@@@@@.@
.@.@.@.@@@
@.@@@.@@@@
.@@@@@@@@.
@.@.@@@.@."""

input = read("src/2025/inputs/day_4.txt", String);

using Test

function input_to_arr(input::String)::Matrix{Integer}
    input_lines = split(input, "\n")
    rows, cols = length(input_lines), length(strip(input_lines[1]))

    arr = zeros(Int, rows, cols)
    for (row, line) in enumerate(input_lines)
        line = strip(line)
        for (col, ch) in enumerate(line)
            if ch == '@'
                # Set every roll to 100
                arr[row, col] = 100
            end
        end
    end

    return arr
end

function get_adjacent(row::Integer, col::Integer, max_row::Integer, max_col::Integer)::Vector{Tuple{Integer, Integer}}
    """Returning all adjacent valid coords"""
    ret = Vector{Tuple{Integer, Integer}}()
    for d_row in -1:1
        # Skip if going outside bounds
        if d_row == -1 && row == 1 || d_row == 1 && row == max_row
            continue
        end
        for d_col in -1:1
            if d_col == -1 && col == 1 || d_col == 1 && col == max_col || d_col == 0 && d_row == 0
                continue
            end
            push!(ret, (row + d_row, col + d_col))
        end
    end

    return ret
end

@test get_adjacent(1, 1, 10, 10) == [(1, 2), (2, 1), (2, 2)]
@test get_adjacent(10, 9, 10, 10) == [(9, 8), (9, 9), (9, 10), (10, 8), (10, 10)]


function add_neigbours(arr::Matrix{Integer})::Matrix{Integer}
    rows, cols = size(arr)
    for (index, val) in pairs(arr)
        if val < 100
            continue
        end
        row, col = Tuple(index)
        for (adj_row, adj_col) in get_adjacent(row, col, rows, cols)
            if arr[adj_row, adj_col] > 99
                arr[adj_row, adj_col] += 1
            end
        end
    end

    return arr
end

orig_arr = input_to_arr(input)
neighbarr = add_neigbours(orig_arr)

few_neighbours = sum((neighbarr .> 99) .& (neighbarr .< 104))

println("Answer 1: $few_neighbours")


orig_arr = input_to_arr(input)

function remove_all(neighbarr::Matrix{Integer})::Integer
    total_removed = 0
    while true
        neighbarr = add_neigbours(neighbarr)
        to_remove = (neighbarr .> 99) .& (neighbarr .< 104)
        removed = sum(to_remove)
        if removed == 0
            return total_removed
        end
        total_removed += removed
        # println("Removed $removed, total $total_removed")

        neighbarr[to_remove] .= 0
        neighbarr[neighbarr .> 99] .= 100
    end
end

total_removed = remove_all(orig_arr)
println("Answer 2: $total_removed")
