input = """0:
###
##.
##.

1:
###
##.
.##

2:
.##
###
##.

3:
##.
###
##.

4:
###
#..
###

5:
###
.#.
###

4x4: 0 0 0 0 2 0
12x5: 1 0 1 0 2 2
12x5: 1 0 1 0 3 2"""

using Logging

Logging.disable_logging(Logging.Debug)
input = read("src/2025/inputs/day_12.txt", String);Logging.disable_logging(Logging.Info)

using Test
using Dates


Block = Vector{String}

struct Area
    x::Integer
    y::Integer

    counts::Vector{Integer}
end


function parse_input(input::String)::Tuple{Vector{Block}, Vector{Area}}
    @info "Parsing input"

    blocks = Vector{Block}()
    areas = Vector{Area}()
    if '\r' in input
        splitr = "\r\n\r\n"
    else
        splitr = "\n\n"
    end

    for multi in eachsplit(input, splitr)
        multi = strip(multi, '\r')
        if multi[2] == ':'
            # Block
            @info "Got block" multi
            block = [strip(b, '\r') for b in eachsplit(multi, "\n")][2:end]
            push!(blocks, block)
        else
            # Areas
            for arr in eachsplit(multi, "\n")
                arr = strip(arr, '\r')
                @info "Got area" arr
                parts = split(arr, ": ")
                dims = split(parts[1], 'x')
                x = parse(Int, dims[1])
                y = parse(Int, dims[2])

                counts = [parse(Int, p) for p in eachsplit(parts[2], ' ')]
                push!(areas, Area(x, y, counts))
            end
        end
    end

    return blocks, areas
end


function count_block_sizes(block::Block)::Integer

    ret = 0
    for bline in block
        for ch in bline
            if ch == '#'
                ret += 1
            end
        end
    end

    return ret
end


function blocks_fit_area(area::Area, block_sizes::Vector{Integer})::Bool
    area_area = area.x * area.y
    block_area = 0
    for (i, size) in enumerate(block_sizes)
        block_area += size * area.counts[i]
        if block_area > area_area
            return false
        end
    end

    return true
end


blocks, areas = parse_input(input)
block_sizes = Vector{Integer}([count_block_sizes(b) for b in blocks])

answer_1 = sum([blocks_fit_area(area, block_sizes) for area in areas])
println("Answer 1: $answer_1")
