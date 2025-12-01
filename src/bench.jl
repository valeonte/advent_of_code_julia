using Dates


n = 4000
iter = 10

function matmul(a::Matrix{Float64}, b::Matrix{Float64})::Matrix{Float64}
    return a * b
end


precompile(matmul, (Matrix{Float64}, Matrix{Float64}))


A = randn(n, n)
B = randn(n, n)

println("Multiplying $n x $n matrices $iter times")

start = Dates.now()

for i in 1:iter
    matmul(A, B)
end

dur = Dates.now() - start
println("Done in $dur")
