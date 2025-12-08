input = """162,817,812
57,618,57
906,360,560
592,479,940
352,342,300
466,668,158
542,29,236
431,825,988
739,650,466
52,470,668
216,146,977
819,987,18
117,168,530
805,96,715
346,949,466
970,615,88
941,993,340
862,61,35
984,92,344
425,690,689"""

max_connections = 10

input = read("src/2025/inputs/day_8.txt", String);
max_connections = 1000


Point = Tuple{Integer, Integer, Integer}

function parse_input(input::String)::Vector{Point}
    """Parse input to return start and splitters."""
    println("Parsing input")
    ret = Vector{Point}()
    for line in eachsplit(input, "\n")
        parts = split(strip(line, '\r'), ",")
        point = Tuple(parse(Int, p) for p in parts)
        push!(ret, point)
    end

    return ret
end

function calc_dist(point1::Point, point2::Point)::Float64
    return sqrt((point1[1] - point2[1])^2 + (point1[2] - point2[2])^2 + (point1[3] - point2[3])^2)
end


function get_pairs_distances(points::Vector{Point})::Tuple{Vector{Float64}, Vector{Tuple{Point, Point}}}
    println("Working out all pairs and distances sorted")
    distances = Vector{Float64}()
    pairs = Vector{Tuple{Point, Point}}()

    for (i, point1) in enumerate(points)
        println("$i / $(length(points))")
        for point2 in points[i+1:end]
            dist = calc_dist(point1, point2)
            idx = searchsortedfirst(distances, dist)
            insert!(distances, idx, dist)
            insert!(pairs, idx, (point1, point2))
        end
    end

    println("$(length(distances)) pairs distances calculated")
    return distances, pairs
end


function get_circuits(pairs::Vector{Tuple{Point, Point}}, max_connections::Integer)::Dict{Point, Integer}

    println("Working out circuits after $max_connections connections")
    circuits = Dict{Point, Integer}()

    next_circuit = 1
    connections_made = 0
    for (point1, point2) in pairs
        circuit1 = get(circuits, point1, -1)
        circuit2 = get(circuits, point2, -1)
        if circuit1 == -1
            connections_made += 1  # there will be a connection made
            if circuit2 == -1
                # both unconnected
                println("Connecting un-connected $point1 -> $point2, circuit $next_circuit, connections $connections_made")
                circuits[point1] = next_circuit
                circuits[point2] = next_circuit
                next_circuit += 1
            else
                # 1 unconnected, 2 connected, connect 1 to 2's circuit
                println("Connecting un-connected $point1 to circuit $circuit2 of $point2, connections $connections_made")
                circuits[point1] = circuit2
            end
        else
            if circuit2 == -1
                connections_made += 1
                println("Connecting un-connected $point2 to circuit $circuit1 of $point1, connections $connections_made")
                # 2 unconnected, 1 connected, connect 2 to 1's circuit
                circuits[point2] = circuit1
            elseif circuit1 == circuit2
                connections_made += 1
                println("Already on same circuit $circuit1, points $point1 and $point2, connections $connections_made")
                # Already on the same circuit nothing to do
            else
                connections_made += 1
                println("Merging $circuit2 of $point2 to $circuit1 of $point1, connections $connections_made")
                # Both connected to different circuits, merge both to circuit1
                for (point, circuit) in circuits
                    if circuit == circuit2
                        circuits[point] = circuit1
                    end
                end
            end
        end

        if connections_made == max_connections
            break
        end
    end

    return circuits
end


points = parse_input(input)
distances, pairs = get_pairs_distances(points)
circuits = get_circuits(pairs, max_connections)

point_circuits = values(circuits)
circuit_sizes = sort([count(==(i), point_circuits) for i in unique(point_circuits)])

println("Answer 1: $(prod(circuit_sizes[end-2:end]))")


function get_circuits2(points::Vector{Point}, pairs::Vector{Tuple{Point, Point}})::Integer

    println("Working out circuits after $max_connections connections")
    circuits = Dict{Point, Integer}(p => i for (i, p) in enumerate(points))

    circuit_tracker = Set{Integer}(values(circuits))
    last_merged_points_xs::Tuple{Integer, Integer} = -1, -1
    for (point1, point2) in pairs
        circuit1 = circuits[point1]
        circuit2 = circuits[point2]

        if circuit1 != circuit2
            pop!(circuit_tracker, circuit2)
            last_merged_points_xs = point1[1], point2[1]
            println("Merging $circuit2 of $point2 to $circuit1 of $point1,  $(length(circuit_tracker)) unique circuit(s)")

            # Both connected to different circuits, merge both to circuit1
            for (point, circuit) in circuits
                if circuit == circuit2
                    circuits[point] = circuit1
                end
            end
        end

        if length(circuit_tracker) == 1
            break
        end
    end

    return prod(last_merged_points_xs)
end

println("Answer 2: $(get_circuits2(points, pairs))")
