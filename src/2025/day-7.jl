input = """.......S.......
...............
.......^.......
...............
......^.^......
...............
.....^.^.^.....
...............
....^.^...^....
...............
...^.^...^.^...
...............
..^...^.....^..
...............
.^.^.^.^.^...^.
..............."""

input = read("src/2025/inputs/day_7.txt", String);


function parse_input(input::String)::Tuple{Tuple{Integer, Integer}, Set{Tuple{Integer, Integer}}}
    """Parse input to return start and splitters."""
    start = (0, 0)
    splitters = Set{Tuple{Integer, Integer}}()
    for (row, line) in enumerate(eachsplit(input, "\n"))
        for (col, ch) in enumerate(line)
            if ch == '.'
                continue
            elseif ch == 'S'
                start = (row, col)
            elseif ch == '^'
                push!(splitters, (row, col))
            end
        end
    end

    return start, splitters
end


function count_splits(start::Tuple{Integer, Integer}, splitters::Set{Tuple{Integer, Integer}})::Integer
    # we parse the beams row by row, skipping bits we might have already done
    beams_seen = Set{Tuple{Integer, Integer}}()
    beams_q = Vector{Tuple{Integer, Integer}}()

    max_row = maximum(b[1] for b in splitters)
    push!(beams_q, start)

    splits = 0
    while length(beams_q) > 0
        beam = pop!(beams_q)
        if beam in beams_seen
            # Already checked beam
            continue
        end
        push!(beams_seen, beam)
        # println("Checking $beam")

        if beam in splitters
            splits += 1
            # println("Splitting to $((new_row, beam[2] - 1)) and $((new_row, beam[2] + 1))")
            push!(beams_q, (beam[1], beam[2] - 1))
            push!(beams_q, (beam[1], beam[2] + 1))
        else
            new_row = beam[1] + 1
            if new_row > max_row
                # reached the bottom
                continue
            end
            # println("Moving on to $((new_row, beam[2]))")
            push!(beams_q, (new_row, beam[2]))
        end
    end

    return splits
end

start, splitters = parse_input(input)
splits = count_splits(start, splitters)

println("Answer 1: $splits")


function timelines_from(row::Integer, col::Integer)::Integer
    beam = (row, col)
    if row > max_row
        # println("Hit bottom at $beam => 1")
        return 1  # we ran throuhh the bottom, single timeline
    end

    known = get(known_froms, beam, -1)

    if known > -1
        # println("Got cached $beam => $known")
        return known
    end

    if beam in splitters
        # println("On splitter $beam")

        # on a splitter now
        left = timelines_from(row, col-1)
        right = timelines_from(row, col+1)
        ret = left + right
    else
        # println("On space $beam")

        ret = timelines_from(row+1, col)
    end

    known_froms[beam] = ret

    # println("Calculated $beam => $ret")
    return ret
end


start, splitters = parse_input(input)
max_row = maximum(b[1] for b in splitters)

known_froms = Dict{Tuple{Integer, Integer}, Integer}()

tls = timelines_from(start[1], start[2])

println("Answer 2: $tls, tlss calculated: $(length(known_froms))")
