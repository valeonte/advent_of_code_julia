input = """3-5
10-14
16-20
12-18

1
5
8
11
17
32"""

input = read("src/2025/inputs/day_5.txt", String);


function parse_input(input::String)::Tuple{Vector{Tuple{Integer, Integer}}, Vector{Integer}}
    ranges = Vector{Tuple{Integer, Integer}}()
    numbers = Vector{Integer}()
    in_ranges = true

    input_lines = split(input, "\n")
    for line in input_lines
        line = strip(String(line))
        if length(line) == 0
            in_ranges = false
            continue
        end
        if in_ranges
            num1, num2 = Tuple(split(line, "-"))
            push!(ranges, (parse(Int, num1), parse(Int, num2)))
        else
            push!(numbers, parse(Int, line))
        end
    end

    sort!(ranges, by=x -> x[1])
    return ranges, numbers
end


function count_fresh(ranges::Vector{Tuple{Integer, Integer}}, numbers::Vector{Integer})::Integer
    total_fresh = 0
    for num in numbers
        is_fresh = false
        for (start, stop) in ranges
            if start > num
                # no point in continuing
                break
            end
            if start <= num <= stop
                is_fresh = true
                break
            end
        end

        if is_fresh
            total_fresh += 1
        end
    end

    return total_fresh
end

ranges, numbers = parse_input(input)
total_fresh = count_fresh(ranges, numbers)

println("Answer 1: $total_fresh")


function count_all_fresh(ranges::Vector{Tuple{Integer, Integer}})
    total_fresh = 0
    next_to_count = 1
    for (start, stop) in ranges
        count_from_inc = max(start, next_to_count)
        # println("Counting from $count_from_inc")
        if stop >= count_from_inc
            extra = stop - count_from_inc + 1
            # println("Counting to $stop adding $extra")
            total_fresh += extra
            next_to_count = stop + 1
        end
    end

    return total_fresh
end

total_fresh = count_all_fresh(ranges)

println("Answer 2: $total_fresh")
