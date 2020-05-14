import MPI
using Distributed
Distributed.@everywhere include("one_sided.jl")

    iters = 100
    puts = 50000
    gets = 50000
    driver(iters,puts, gets)    
    rmprocs(workers())
