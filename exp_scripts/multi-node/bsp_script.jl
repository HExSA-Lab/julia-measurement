import MPI
using Distributed
Distributed.@everywhere include("bsp_julia_mpi.jl")


    iters = 100
    elements = 10
    flops = 1000000
    reads = 5
    writes = 5
    comms = 10
#    doit(iters,elements, flops, reads, writes,comms)    
    doit_mpi(iters,elements, flops, reads, writes,comms)    
    println(workers())
    rmprocs(workers())
