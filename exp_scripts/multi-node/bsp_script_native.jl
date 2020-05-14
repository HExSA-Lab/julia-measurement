#= For version 0.7 or above in Julia
using Distributed
Distributed.@everywhere include("bsp_julia_native.jl")
=#
@everywhere include("bsp_julia_native.jl")


    iters = 100
    elements = 10
    flops = 1000000
    reads = 5000000
    writes = 5000000
    comms = 10000
    processes = [1,2,4,8]
    for j in processes
        doit(j, iters,elements, flops, reads, writes,comms)    
    end
