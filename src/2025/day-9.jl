input = """7,1
11,1
11,7
9,7
9,5
2,5
2,3
7,3"""

input = read("src/2025/inputs/day_9.txt", String);

using Test

Tile = Tuple{Integer, Integer}

function parse_input(input::String)::Vector{Tile}
    println("Parsing input")
    ret = Vector{Tile}()
    for line in eachsplit(input, "\n")
        parts = split(strip(line, '\r'), ",")
        tile = Tuple(parse(Int, p) for p in parts)
        push!(ret, tile)
    end

    return ret
end

function calc_area(tile1::Tile, tile2::Tile)::Integer
    return (abs(tile1[1] - tile2[1]) + 1) * (abs(tile1[2] - tile2[2]) + 1)
end


function find_largest_area(tiles::Vector{Tile})::Integer
    println("Working out all pairs and areas to find max")
    max_area = 0
    for (i, tile1) in enumerate(tiles)
        println("$i / $(length(tiles))")
        for tile2 in tiles[i+1:end]
            area = calc_area(tile1, tile2)
            if area > max_area
                max_area = area
            end
        end
    end

    return max_area
end


tiles = parse_input(input)
println("Answer 1: $(find_largest_area(tiles))")

Edge = Tuple{Tile, Tile}


function get_surrounding_corner_tiles(tiles::Vector{Tile})::Tuple{Integer, Integer, Integer, Integer}
    println("Finding corner tiles")
    min_x, max_x, min_y, max_y = -1 ,-1, -1, -1
    for tile in tiles
        if min_x == -1 || tile[1] < min_x
            min_x = tile[1]
        end
        if max_x == -1 || tile[1] > max_x
            max_x = tile[1]
        end
        if min_y == -1 || tile[2] < min_y
            min_y = tile[2]
        end
        if max_y == -1 || tile[2] > max_y
            max_y = tile[2]
        end
    end

    println("Corner tiles $((min_x, max_x, min_y, max_y))")
    return min_x-1, max_x+1, min_y-1, max_y+1
end


Range = Tuple{Integer, Integer}
RangeGroup = Dict{Integer, Vector{Range}}

function edges_to_rows_and_cols(edges::Vector{Edge})::Tuple{RangeGroup, RangeGroup}
    cols = RangeGroup()
    rows = RangeGroup()
    for (tile1, tile2) in edges
        if tile1[1] == tile2[1]
            # column
            ranges = get!(Vector{Range}, cols, tile1[1])
            push!(ranges, Range(sort((tile1[2], tile2[2]))))
        else
            @test tile1[2] == tile2[2]  # ensure it is row
            ranges = get!(Vector{Range}, rows, tile1[2])
            push!(ranges, Range(sort((tile1[1], tile2[1]))))
        end
    end

    return rows, cols
end


function is_in_range_group(range_group::RangeGroup, idx::Integer, search::Integer)::Bool
    ranges = get(range_group, idx, nothing)
    if isnothing(ranges)
        return false
    end
    for range in ranges
        if range[1] <= search && search <= range[2]
            return true
        end
    end

    return false
end


function extend_col_group(col_group::RangeGroup, tile::Tile)
    idx, search = tile
    ranges = get!(Vector{Range}, col_group, idx)
    for (i, range) in enumerate(ranges)
        if range[1] <= search && search <= range[2]
            # already in range
            return
        elseif range[1] == search + 1
            ranges[i] = (range[1] - 1, range[2])
            return
        elseif range[2] == search - 1
            ranges[i] = (range[1], range[2] + 1)
            return
        end
    end

    # No adjacent found
    new_range = Range((search, search))
    idx = searchsortedfirst(ranges, new_range, by=x -> x[1])
    insert!(ranges, idx, new_range)
end


function calculate_outside_cols(tiles::Vector{Tile})
    println("Working out all outside cols")
    min_x, max_x, min_y, max_y = get_surrounding_corner_tiles(tiles)

    edges = Vector{Edge}([(tiles[i], tiles[i+1]) for i in 1:length(tiles)-1])
    push!(edges, Edge((tiles[end], tiles[1])))  # The closing edge
    edge_rows, edge_cols = edges_to_rows_and_cols(edges)

    # We store ranges in columnar ranges
    outside_cols = RangeGroup()

    q = Vector{Tile}([(min_x, min_y)])
    cnt = 1
    while length(q) > 0
        cnt += 1
        if rem(cnt, 100000) == 0
            println("$cnt loops done, q length $(length(q))")
        end

        btile = pop!(q)

        for tile in [(btile[1]+1, btile[2]), (btile[1]-1, btile[2]), (btile[1], btile[2]+1), (btile[1], btile[2]-1)]
            if tile[1] < min_x || tile[1] > max_x || tile[2] < min_y || tile[2] > max_y
                # println("Out of bounds $(tile)")
                # Out of bounds
                continue
            elseif is_in_range_group(edge_rows, tile[2], tile[1]) || is_in_range_group(edge_cols, tile[1], tile[2])
                # We hit the coloured tiles, move on
                # println("Coloured tile $(tile)")
                continue
            end
            if is_in_range_group(outside_cols, tile[1], tile[2])
                # Already classified outside
                # println("Already outside tile $(tile)")
                continue
            end

            # New outside tile, extending and appending
            # println("New outside tile $(tile)")
            extend_col_group(outside_cols, tile)
            push!(q, tile)
        end
    end

    println("Calculated outside cols in $cnt loops")
    return outside_cols
end

function calc_area_zip(tile1::Tile, tile2::Tile, zipx::Dict{Integer, Tuple{Integer, Integer}}, zipy::Dict{Integer, Tuple{Integer, Integer}})::Integer
    x1, x2 = sort((tile1[1], tile2[1]))
    dx = sum(zipx[x][2] - zipx[x][1] + 1 for x in x1:x2)
    y1, y2 = sort((tile1[2], tile2[2]))
    dy = sum(zipy[y][2] - zipy[y][1] + 1 for y in y1:y2)

    return dx * dy
end


function find_largest_coloured_area(tiles::Vector{Tile}, outside_cols::RangeGroup, zipx::Dict{Integer, Tuple{Integer, Integer}}, zipy::Dict{Integer, Tuple{Integer, Integer}})::Integer
    println("Working out all pairs and areas to find max with no tiles in outside cols")
    max_area = 0
    for (i, tile1) in enumerate(tiles)
        println("$i / $(length(tiles))")
        for tile2 in tiles[i+1:end]
            area = calc_area_zip(tile1, tile2, zipx, zipy)
            if area <= max_area
                continue
            end

            # check for outside tiles
            xs = sort((tile1[1], tile2[1]))
            ys = sort((tile1[2], tile2[2]))
            failed = false
            for x in xs[1]:xs[2]
                for y in ys[1]:ys[2]
                    if is_in_range_group(outside_cols, x, y)
                        failed = true
                        break
                    end
                end
                if failed
                    break
                end
            end

            if !failed
                max_area = area
            end
        end
    end

    return max_area
end


function remap_dim(tiles::Vector{Tile}, dim::Integer)::Tuple{Dict{Integer, Tuple{Integer, Integer}}, Dict{Integer, Integer}}
    println("Remapping dim $dim of $(length(tiles)) tiles")
    zipx = Dict{Integer, Tuple{Integer, Integer}}()
    xmap = Dict{Integer, Integer}()

    last_x = -1
    cnt = 1
    for x in sort(unique(tile[dim] for tile in tiles))
        if last_x > -1 && x - last_x > 1
            zipx[cnt] = (last_x+1, x-1)
            cnt += 1
        end
        zipx[cnt] = (x, x)
        xmap[x] = cnt
        cnt += 1
        last_x = x
    end

    return zipx, xmap
end

zipx, xmap = remap_dim(tiles, 1)
zipy, ymap = remap_dim(tiles, 2)

new_tiles = Vector{Tile}([(xmap[tile[1]], ymap[tile[2]]) for tile in tiles])

outside_cols = calculate_outside_cols(new_tiles)
largest_area = find_largest_coloured_area(new_tiles, outside_cols, zipx, zipy)
println("Answer 2: $largest_area")
