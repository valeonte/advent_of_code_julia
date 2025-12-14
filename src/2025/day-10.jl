input = """[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}
[.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}"""

using Logging

Logging.disable_logging(Logging.Debug)
input = read("src/2025/inputs/day_10.txt", String);
Logging.disable_logging(Logging.Info)

using Test
using Combinatorics
using Dates


struct Machine
    light::Integer
    buttons::Vector{Integer}
    joltage::Vector{Integer}
end


function parse_input(input::String)::Vector{Machine}
    @info "Parsing input"
    ret = Vector{Machine}()
    for line in eachsplit(input, "\n")
        parts = split(strip(line, '\r'), " ")
        light = 0
        for ind in reverse(parts[1][2:end-1])
            light = light << 1
            if ind == '#'
                light += 1
            end
        end

        buttons = Vector{Integer}()
        for part in parts[2:end-1]
            button = 0
            for d in split(part[2:end-1], ",")
                pow = parse(Int, d)
                button += 2 ^ pow
            end
            push!(buttons, button)
        end

        joltage = Vector{Integer}([parse(Int, d) for d in eachsplit(parts[end][2:end-1], ",")])

        machine = Machine(light, buttons, joltage)
        push!(ret, machine)
    end

    return ret
end


function find_min_button_presses(machine::Machine)::Vector{Integer}
    for n in 1:length(machine.buttons)
        for comb in combinations(machine.buttons, n)
            res = 0
            for k in comb
                res = xor(res, k)
            end
            if res == machine.light
                @debug "Found combo $comb for n=$n"
                return comb
            end
        end
    end

    error("No button combination worked!")
end


function find_minimum_machines_presses(machines::Vector{Machine})::Integer
    presses = 0
    for machine in machines
        @debug machine
        c = find_min_button_presses(machine)
        presses += length(c)
    end

    return presses
end


# machines = parse_input(input)
# presses = find_minimum_machines_presses(machines)

# println("Answer 1: $presses")


struct Machine2
    joltage::Vector{Integer}

    button_indices::Vector{Vector{Integer}}
    button_increments::Vector{Vector{Integer}}
end

function parse_input2(input::String)::Vector{Machine2}
    println("Parsing input 2")
    ret = Vector{Machine2}()
    for line in eachsplit(input, "\n")
        parts = split(strip(line, '\r'), " ")
        joltage = Vector{Integer}([parse(Int, d) for d in eachsplit(parts[end][2:end-1], ",")])

        # We store buttons as 1 and 0 at the appropriate locations as per joltage
        button_indices = Vector{Vector{Integer}}()
        button_increments = Vector{Vector{Integer}}()
        for part in parts[2:end-1]
            button_inc = zeros(Integer, length(joltage))
            button_idx = Vector{Integer}()
            for d in split(part[2:end-1], ",")
                idx = parse(Int, d) + 1
                push!(button_idx, idx)
                button_inc[idx] = 1
            end
            push!(button_increments, button_inc)
            push!(button_indices, button_idx)
        end

        machine = Machine2(joltage, button_indices, button_increments)
        push!(ret, machine)
    end

    return ret
end


function get_min_presses_for_machine(machine::Machine2, min_total_presses::Integer, entry::Bool = false)::Union{Integer, Nothing}
    if all(machine.joltage .== 0)
        @info "Machine solved!"
        return 0
    end
    if length(machine.button_indices) == 0 || min_total_presses <= 0
        # 0 buttons, or 0 presses left, impossible to solve
        @info "Machine impossible!"
        return
    end

    @info "Solving" machine min_total_presses

    max_presses = ones(Integer, length(machine.button_indices)) * maximum(machine.joltage)
    jidx_counter = Dict{Integer, Integer}()
    for (bidx, button) in enumerate(machine.button_indices)
        for jidx in button
            cur = get!(jidx_counter, jidx, 0)
            if machine.joltage[jidx] > 0
                jidx_counter[jidx] = cur + 1
            end
            if machine.joltage[jidx] < max_presses[bidx]
                max_presses[bidx] = machine.joltage[jidx]
            end
        end
    end
    for (j, jolt) in enumerate(machine.joltage)
        if jolt > 0 && !haskey(jidx_counter, j)
            @info "Got joltage with no buttons, path impossible"
            return
        end
    end

    @info "Max presses: $max_presses"

    if min_total_presses == Int(1e9)
        min_total_presses = sum(max_presses)+1
    end
    got_better_solution = false

#    j, jolt = [(j, jolt) for (j, jolt) in enumerate(machine.joltage) if jolt > 0][1]
    # j = [key for (key, cnt) in jidx_counter if cnt == minimum(values(jidx_counter))][1]
    j = first(keys(jidx_counter));

    @info "Aiming to zero out j=$j for joltage=$(machine.joltage[j])"
    relevant_buttons = [i for (i, b) in enumerate(machine.button_indices) if j in b]
    sort!(relevant_buttons, by=x->-length(machine.button_indices[x]))

    @info "Relevant buttons: $relevant_buttons, aka $(machine.button_indices[relevant_buttons])"
    max_joltage = sum(max_presses[relevant_buttons])
    for b in relevant_buttons
        # min presses is the fewest times we can press this button to get to where we want
        # from the presses of the others.
        min_presses = max(2*max_presses[b] - max_joltage, 0)
        @info "Examining button $b, aka $(machine.button_indices[b]), presses $min_presses - $(max_presses[b])"
        for presses in min_presses:max_presses[b]
            if presses > min_total_presses
                break
            end

            @info "Pressing button $b, aka $(machine.button_indices[b]), $presses times"
            new_machine = Machine2(
                machine.joltage - presses * machine.button_increments[b],
                machine.button_indices[1:end .!= b],
                machine.button_increments[1:end .!= b]
            )
            @info "New machine: $new_machine"
            sub_min_presses = get_min_presses_for_machine(new_machine, min_total_presses-presses)
            if !isnothing(sub_min_presses)
                total_presses = presses + sub_min_presses
                if total_presses < min_total_presses
                    @info "New min total presses: $total_presses"
                    got_better_solution = true
                    min_total_presses = total_presses
                end
            end
        end
    end

    if got_better_solution
        if entry
            println("Got one solution $min_total_presses")
        end
        return min_total_presses
    end
end

function find_total_min_presses2(machines2::Vector{Machine2}, from::Integer = 1, to::Integer = Int(1e9))::Integer
    total_min = 0
    for (i, machine) in enumerate(machines2)
        if i < from || i > to
            continue
        end
        println("Simplyfying machine $i / $(length(machines2)): $machine")
        machine = simplify_machine(machine)
        println("$(now()): Solving machine $i / $(length(machines2)): $machine")
        min_presses = get_min_presses_for_machine(machine, Int(1e9), true)
        total_min += min_presses

        println("Done with $min_presses presses, RUNNING SUM $total_min")
    end

    return total_min
end


function simplify_machine(machine::Machine2)::Machine2
    # lights x buttons
    button_matrix = permutedims(hcat(machine.button_increments...))'
    new_joltage = machine.joltage

    # Machine 141
    # full_matrix = hcat(button_matrix, machine.joltage)
    # full_matrix[1,:] += full_matrix[3,:];
    # full_matrix[3,:] -= full_matrix[1,:];
    # full_matrix[10,:] -= full_matrix[1,:];

    # full_matrix[1,:] -= 2*full_matrix[2,:];
    # full_matrix[3,:] += full_matrix[2,:];
    # full_matrix[5,:] -= full_matrix[2,:]
    # full_matrix[6,:] -= full_matrix[2,:]
    # full_matrix[7,:] -= full_matrix[2,:]
    # full_matrix[8,:] -= full_matrix[2,:]
    # full_matrix[9,:] -= full_matrix[2,:]
    # full_matrix[10,:] += 2*full_matrix[2,:];

    # full_matrix[3,:] += full_matrix[8,:];
    # full_matrix[8,:] -= full_matrix[3,:];
    # full_matrix[9,:] -= full_matrix[3,:];

    # full_matrix[3,:] += full_matrix[4,:];
    # full_matrix[1,:] -= 2*full_matrix[4,:];
    # full_matrix[5,:] -= full_matrix[4,:];
    # full_matrix[7,:] -= full_matrix[4,:];
    # full_matrix[8,:] -= full_matrix[4,:];
    # full_matrix[9,:] -= full_matrix[4,:];
    # full_matrix[10,:] += full_matrix[4,:];

    # full_matrix[5,:] -= full_matrix[7,:];
    # full_matrix[2,:] -= full_matrix[5,:];
    # full_matrix[3,:] -= full_matrix[5,:];
    # full_matrix[4,:] -= full_matrix[5,:];
    # full_matrix[1,:] += 4*full_matrix[5,:];
    # full_matrix[7,:] += 2*full_matrix[5,:];
    # full_matrix[8,:] += 2*full_matrix[5,:];
    # full_matrix[9,:] += full_matrix[5,:];
    # full_matrix[10,:] -= 3*full_matrix[5,:];

    # full_matrix[6,:] -= full_matrix[10,:];
    # full_matrix[6,:] -= full_matrix[8,:];
    # full_matrix[5,:] -= full_matrix[6,:];
    # full_matrix[4,:] += full_matrix[6,:];
    # full_matrix[3,:] += 2*full_matrix[6,:];
    # full_matrix[2,:] += full_matrix[6,:];
    # full_matrix[1,:] -= 5*full_matrix[6,:];
    # full_matrix[7,:] -= 2*full_matrix[6,:];
    # full_matrix[8,:] -= 3*full_matrix[6,:];
    # full_matrix[9,:] -= 2*full_matrix[6,:];
    # full_matrix[10,:] += 4*full_matrix[6,:];

    # full_matrix[6,:] += 2*full_matrix[7,:];
    # full_matrix[5,:] -= full_matrix[7,:];
    # full_matrix[3,:] += 2*full_matrix[7,:];
    # full_matrix[1,:] -= 3*full_matrix[7,:];
    # full_matrix[8,:] -= 2*full_matrix[7,:];
    # full_matrix[9,:] -= 2*full_matrix[7,:];
    # full_matrix[10,:] += 2*full_matrix[7,:];

    # full_matrix[8,:] -= full_matrix[10,:];
    # full_matrix[9,:] += 2*full_matrix[8,:];
    # full_matrix[10,:] += full_matrix[8,:];
    # full_matrix[7,:] -= 3*full_matrix[8,:];
    # full_matrix[6,:] -= 3*full_matrix[8,:];
    # full_matrix[5,:] += full_matrix[8,:];
    # full_matrix[4,:] += full_matrix[8,:];
    # full_matrix[3,:] -= 2*full_matrix[8,:];
    # full_matrix[2,:] += full_matrix[8,:];

    # full_matrix[9,:] -= 5*full_matrix[10,:];
    # full_matrix[8,:] -= 2*full_matrix[10,:];
    # full_matrix[7,:] += 7*full_matrix[10,:];
    # full_matrix[6,:] += 7*full_matrix[10,:];
    # full_matrix[5,:] -= 2*full_matrix[10,:];
    # full_matrix[4,:] -= 2*full_matrix[10,:];
    # full_matrix[3,:] += 5*full_matrix[10,:];
    # full_matrix[2,:] -= 2*full_matrix[10,:];
    # full_matrix[1,:] -= full_matrix[10,:];

    # full_matrix[10,:] += full_matrix[6,:];
    # full_matrix[6,:] += full_matrix[5,:];

    change = true
    cnt = 1
    while change && cnt < 20
        cnt += 1
        # simplifying: If any row is subset of any other row, subtract
        change = false
        for row1 in 1:length(new_joltage)
            row1_indices = [i for (i, b) in enumerate(button_matrix[row1, :]) if b == 1]
            if all(button_matrix[row1, :] .== 0)
                # no point in checking this
                continue
            end
            for row2 in 1:length(new_joltage)
                if row2 == row1
                    continue
                end
                row2_indices = [i for (i, b) in enumerate(button_matrix[row2, :]) if b == 1]
                change = all(i in row2_indices for i in row1_indices)
                if change
                    @warn "Subtracting row $row1 from $row2" button_matrix
                    button_matrix[row2, :] = button_matrix[row2, :] - button_matrix[row1, :]
                    new_joltage[row2] -= new_joltage[row1]
                    break
                end
            end
            if change
                break
            end
        end
    end

    new_button_increments = [Vector{Integer}(col) for col in eachcol(button_matrix)]
    new_button_indices = [Vector{Integer}([i for (i, b) in enumerate(butt) if b == 1]) for butt in new_button_increments]

    return Machine2(new_joltage, new_button_indices, new_button_increments)
end


machines2 = parse_input2(input)


# machine = machines2[141]
# machine = simplify_machine(machine)

# get_min_presses_for_machine(machine)

if length(ARGS) == 2
    from = parse(Int, ARGS[1])
    to = parse(Int, ARGS[2])
    println("Solving from $from to $to")
    total_min = find_total_min_presses2(machines2, from, to)
else
    total_min = find_total_min_presses2(machines2)
end
println("Answer 2: $total_min")

#sort([length(m.button_indices) for m in machines2])

# 1- 40: 3860
# 41 - 80:  3903
# 81-120: 4101
# 121-140: 2472
# 141: 112
# 142-149: 1048
# 150-158: 567
println(3860+3903+4101+2472+112+1048+567)