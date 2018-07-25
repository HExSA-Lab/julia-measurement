import MPI
@everywhere include("bsp_julia_mpi.jl")


    iters = 1
    elements = 1
    flops = 1000000
    reads = 5000
    writes = 5000
    comms = 100
#    doit(iters,elements, flops, reads, writes,comms)    
    doit_mpi(iters,elements, flops, reads, writes,comms)    

