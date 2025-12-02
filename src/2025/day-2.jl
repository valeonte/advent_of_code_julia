input = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124";

input = read("src/2025/inputs/day_2.txt", String);

using Test

function silly_pattern(i::Integer, repetitions::Integer = 1)::Integer
    mult = 10 ^ (Int(ceil(log10(i + 1))))
    ret = i
    for _ in 1:repetitions
        ret = ret * mult + i
    end
    return ret
end

@test silly_pattern(10) == 1010
@test silly_pattern(123) == 123123
@test silly_pattern(5) == 55
@test silly_pattern(41, 4) == 4141414141
@test silly_pattern(10, 4) == 1010101010


function extract_ranges(input::String)::Vector{Tuple{Integer, Integer}}
    ranges::Vector{Tuple{Integer, Integer}} = []
    for range in eachsplit(input, ",")
        start_str, stop_str = Tuple(split(range, "-"))
        start = parse(Int, start_str)
        stop = parse(Int, stop_str)
        # println("Got range from $start to $stop")
        push!(ranges, (start, stop))
    end

    sort!(ranges, by=x -> x[1])
    return ranges
end


function get_silly_numbers1()::Set{Integer}
    i = 1
    silly_number = silly_pattern(i)
    silly_in_range = Set{Integer}()
    for (start, stop) in extract_ranges(input)
        while silly_number <= stop
            if silly_number >= start
                # println("Got silly number $silly_number in range $start - $stop")
                push!(silly_in_range, silly_number)
            end
            i += 1
            silly_number = silly_pattern(i)
        end
    end

    return silly_in_range
end

silly_in_range = get_silly_numbers1()

println("Answer 1: $(sum(silly_in_range))")


function get_silly_numbers2()::Set{Integer}
    silly_dict = Dict{Integer, Tuple{Integer, Integer}}()  # Mapping repetitions to last silly i and last silly number
    silly_in_range = Set{Integer}()
    # empty!(silly_dict)
    # empty!(silly_in_range)
    for (start, stop) in extract_ranges(input)
        # println("Range $start - $stop")
        for rep in 1:40
            i, silly_number = get!(silly_dict, rep) do
                1, silly_pattern(1, rep)
            end
            # println("Repetitions $rep starting from i=$i and silly=$silly_number")
            if silly_number > stop && i == 1
                # Stop when we get out of range on a new rep
                break
            end

            while silly_number <= stop
                if silly_number >= start && !(silly_number in silly_in_range)
                    # println("Range $start - $stop, got silly number $silly_number from i=$i, rep=$rep and silly=$silly_number")
                    push!(silly_in_range, silly_number)
                end
                i += 1
                silly_number = silly_pattern(i, rep)
                silly_dict[rep] = (i, silly_number)
            end
        end
    end
    return silly_in_range
end

silly_in_range = get_silly_numbers2()

println("Answer 2: $(sum(silly_in_range))")
