input = """987654321111111
811111111111119
234234234234278
818181911112111"""

input = read("src/2025/inputs/day_3.txt", String);

using Test

function find_max_two_batteries(bank::String)::Integer
    num1, num2 = 0, 0
    bank = strip(bank)
    for (i, ch) in enumerate(bank)
        num = parse(Int, ch)
        if i == length(bank)
            # Last digit can only improve num2
            if num > num2
                num2 = num
            end
        elseif num > num1
                num1 = num
                num2 = 0
        elseif num > num2
            num2 = num
        end
    end

    return num1 * 10 + num2
end

# @test find_max_two_batteries("987654321111111") == 98
# @test find_max_two_batteries("811111111111119") == 89
# @test find_max_two_batteries("234234234234278") == 78
# @test find_max_two_batteries("818181911112111") == 92


function find_total_joltage(input_string::String)::Integer
    total = 0
    for bank in eachsplit(input_string, "\n")
        total += find_max_two_batteries(String(bank))
    end
    return total
end

joltage = find_total_joltage(input)
println("Answer 1: $joltage")


function find_max_k_batteries(bank::String, k::Integer)::Integer
    nums = zeros(Int, k)
    bank = strip(bank)
    blen = length(bank)
    for (i, ch) in enumerate(bank)
        num = parse(Int, ch)

        # Index of the earliest element that can change
        min_changeable_idx = max(1, i - (blen - k))
        # println("$i - $ch - $min_changeable_idx")
        # All the go in the below loop, can be changed, no need to check
        change_occurred = false
        for j in min_changeable_idx:k
            if change_occurred
                # one of the previous changed, all following are zeroed
                # println("Zeroing num$j")
                nums[j] = 0
            elseif num > nums[j]
                # change this
                # println("Setting num$j to $num")
                nums[j] = num
                change_occurred = true  # so that the rest of the loop zero things out
            end
        end
    end

    ret = 0
    for num in nums
        ret = ret * 10 + num
    end

    return ret
end

@test find_max_k_batteries("987654321111111", 2) == 98
@test find_max_k_batteries("811111111111119", 2) == 89
@test find_max_k_batteries("234234234234278", 2) == 78
@test find_max_k_batteries("818181911112111", 2) == 92
@test find_max_k_batteries("818181911112111", 12) == 888911112111


function find_total_joltage_k(input_string::String, k::Integer)::Integer
    total = 0
    for bank in eachsplit(input_string, "\n")
        total += find_max_k_batteries(String(bank), k)
    end
    return total
end

joltage = find_total_joltage_k(input, 12)
println("Answer 2: $joltage")
