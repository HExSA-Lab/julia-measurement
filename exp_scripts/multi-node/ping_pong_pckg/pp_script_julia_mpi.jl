import MPI
using Distributed 
using Revise 
Distributed.@everywhere includet("pp_julia_mpi.jl")

    throwout = 10
    iters = 100
    doit_mpi(iters, throwout)    
