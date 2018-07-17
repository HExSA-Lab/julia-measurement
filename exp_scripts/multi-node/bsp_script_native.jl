@everywhere include("bsp_julia.jl")


    iters = 100
    elements = 100
    flops = 1000000
    reads = 5000
    writes = 5000
    comms = 100
    nprocs = parse(Int, ARGS[1])
    np  = Int(nprocs/2)
    processes = [2^n for n=2:np]
    for j in processes
        doit(j, iters,elements, flops, reads, writes,comms)    
    end
