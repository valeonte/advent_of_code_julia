input = """123 328  51 64
 45 64  387 23
  6 98  215 314
*   +   *   +  """

input = read("src/2025/inputs/day_6.txt", String);


function parse_input(input::String)::Tuple{Matrix{Integer}, Vector{Char}}
    input_lines = split(input, "\n")
    row1 = [parse(Int, el) for el in eachsplit(input_lines[1], " ") if length(el) > 0]

    nums = zeros(Int, length(input_lines)-1, length(row1))
    nums[1, :] = row1
    operators = Vector{Char}()

    for (i, line) in enumerate(input_lines[2:end])
        elems = [el for el in eachsplit(line, " ") if length(el) > 0]
        if isdigit(elems[1][1])
            nums[i+1, :] = [parse(Int, el) for el in elems]
        else
            operators = [el[1] for el in elems]
        end
    end

    return nums, operators
end


function sum_answer_1(nums::Matrix{Integer}, operators::Vector{Char})::Integer
    total = 0
    for (i, oper) in enumerate(operators)
        if oper == '+'
            total += sum(nums[:, i])
        elseif oper == '*'
            total += prod(nums[:, i])
        else
            error("Nope $oper")
        end
    end

    return total
end

nums, operators = parse_input(input)
total = sum_answer_1(nums, operators)


println("Answer 1: $total")


function parse_lines_2(input::String)::Vector{String}
    input_lines = [strip(row, '\r') for row in eachsplit(input, "\n")]
    max_len = maximum(length(line) for line in input_lines)
    for (i, line) in enumerate(input_lines)
        if max_len == length(line)
            break
        end
        while length(line) < max_len
            line = line * " "
        end
        input_lines[i] = line
    end

    return input_lines
end


function sum_answer_2(input::Vector{String})::Integer
    rows = length(input_lines) - 1

    total = 0
    cur_col = length(input_lines[1])
    while cur_col > 0
        # println("Starting at col $cur_col")
        col_nums = Vector{Integer}()
        while cur_col > 0
            col_digits = [input_lines[row][cur_col] for row in 1:rows]
            str_num = strip(join(col_digits))
            if length(str_num) == 0
                break
            end
            num = parse(Int, str_num)
            push!(col_nums, num)
            cur_col -= 1
        end
        # println("Got nums $col_nums")

        oper = input_lines[end][cur_col+1]
        if oper == '+'
            total += sum(col_nums)
        elseif oper == '*'
            total += prod(col_nums)
        else
            error("Nope $oper")
        end
        # println("New total $total")
        cur_col -= 1
    end

    return total
end

input_lines = parse_lines_2(input)
total = sum_answer_2(input_lines)

print("Answer 2: $total")