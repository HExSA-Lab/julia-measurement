import MPI
@everywhere include("bsp_julia_mpi.jl")


    iters = 100
    elements = 100
    flops = 100
    reads = 100
    writes = 100
    comms = 100
#    doit(iters,elements, flops, reads, writes,comms)    
    doit_mpi(iters,elements, flops, reads, writes,comms)    

