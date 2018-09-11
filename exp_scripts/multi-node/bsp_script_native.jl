using Distributed
Distributed.@everywhere include("bsp_julia.jl")


    iters = 10
    elements = 10
    flops = 1000000
    reads = 5000
    writes = 5000
    comms = 100
    processes = [1,2,4,8]
    for j in processes
        doit(j, iters,elements, flops, reads, writes,comms)    
    end
