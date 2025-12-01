include("day_21_numeric.jl")
include("day_21_directional.jl")

using .day_21_numeric
using .day_21_directional


function get_minimum_button_presses(code::String, key_robots::Integer)::String

    min_length = 1000000000
    min_pr = ""
    for pr1 in day_21_numeric.get_presses_for_numeric_string(code)
        process_queue::Vector{Tuple{String, Integer}} = [(pr1, key_robots-1)]
        while length(process_queue) > 0
            pr, robots = pop!(process_queue)
            new_prs = day_21_directional.get_presses_for_directional_string(pr)
            for pr2 in new_prs
                if robots == 1
                    if length(pr2) < min_length
                        println("New minimum length for $code !", length(pr2))
                        min_pr = pr2
                        min_length = length(pr2)
                    end
                else
                    push!(process_queue, (pr2, robots - 1))
                end
            end
        end
    end

    return min_pr
end

function compute_total_complexity(codes::Vector{String}, robots::Integer)
    total = 0
    for code in codes
        presses = get_minimum_button_presses(code, robots)
        num_code = parse(Int, code[1:end-1])
        complexity = length(presses) * num_code
        total += complexity
        println(code, ": ", length(presses), " * ", num_code, " = ", complexity)
    end
    println("Total complexity: ", total)
    return total
end

# Compute for both groups without relying on a global variable
# compute_total_complexity(["029A", "980A", "179A", "456A", "379A"], 3)
compute_total_complexity(["340A", "586A", "839A", "413A", "968A"], 4)
