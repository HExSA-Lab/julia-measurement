import MPI
@everywhere include("pp_julia_mpi.jl")

    throwout = 10
    iters = 100
    doit_mpi(iters, throwout)    
