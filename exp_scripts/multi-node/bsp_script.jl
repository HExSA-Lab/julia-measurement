using MPI
using Distributed
@everywhere include("bsp_julia_mpi.jl")

    iters = 100
    elements = 10
    flops = 1000000
    reads = 5000000
    writes = 500000
    comms = 10000
    doit_mpi(iters,elements, flops, reads, writes,comms)    
    rmprocs(workers())
