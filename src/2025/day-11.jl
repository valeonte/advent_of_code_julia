input = """aaa: you hhh
you: bbb ccc
bbb: ddd eee
ccc: ddd eee fff
ddd: ggg
eee: out
fff: out
ggg: out
hhh: ccc fff iii
iii: out"""

using Logging

Logging.disable_logging(Logging.Debug)
input = read("src/2025/inputs/day_11.txt", String);Logging.disable_logging(Logging.Info)

using Test
using Dates


Rack = Dict{String, Vector{String}}


function parse_input(input::String)::Rack
    @info "Parsing input"
    ret = Rack()
    for line in eachsplit(input, "\n")
        parts = split(strip(line, '\r'), ": ")
        name = parts[1]
        outputs = split(parts[2], " ")

        ret[name] = outputs
    end

    return ret
end


function count_paths_from(server::String, rack::Rack, cache::Dict{String, Integer})::Integer
    if haskey(cache, server)
        return cache[server]
    end
    @info "Counting paths from", server
    connections = rack[server]

    ret = 0
    for conn in connections
        if conn == "out"
            return 1
        else
            ret += count_paths_from(conn, rack, cache)
        end
    end

    cache[server] = ret
    return ret
end



rack = parse_input(input)
you_paths = count_paths_from("you", rack, Dict{String, Integer}())
println("Answer 1: $you_paths")


input = """svr: aaa bbb
aaa: fft
fft: ccc
bbb: tty
tty: ccc
ccc: ddd eee
ddd: hub
hub: fff
eee: dac
dac: fff
fff: ggg hhh
ggg: out
hhh: out"""

Logging.disable_logging(Logging.Debug)
input = read("src/2025/inputs/day_11.txt", String);Logging.disable_logging(Logging.Info)


struct CacheKey
    server::String
    got_dac::Bool
    got_fft::Bool
end


function count_paths_from2(server::String, rack::Rack, cache::Dict{CacheKey, Integer}, got_dac::Bool = false, got_fft::Bool = false)::Integer
    cache_key = CacheKey(server, got_dac, got_fft)
    if haskey(cache, cache_key)
        return cache[cache_key]
    end

    @info "Counting paths from" cache_key
    connections = rack[server]

    ret = 0
    for conn in connections
        if conn == "out"
            if got_dac && got_fft
                return 1
            else
                return 0
            end
        else
            new_got_dac = got_dac || conn == "dac"
            new_got_fft = got_fft || conn == "fft"

            ret += count_paths_from2(conn, rack, cache, new_got_dac, new_got_fft)
        end
    end

    cache[cache_key] = ret
    return ret
end

rack = parse_input(input)
svr_paths = count_paths_from2("svr", rack, Dict{CacheKey, Integer}())
println("Answer 2: $svr_paths")
