
using  MPI
using Distributed
using Revise 
Distributed.@everywhere includet("bsp_julia_mpi.jl");

#mpirun -map-by node --hostfile myhosts -np $i ./a.out -i 100 -e 10 -f 1000000 -r 500000 -w 500000 -c 1000

    iters = 100
    elements = 10
    flops = 1000000
    reads = 50000
    writes = 50000
    comms = 1000
#    doit(iters,elements, flops, reads, writes,comms)    
    doit_mpi(iters,elements, flops, reads, writes,comms)    
    println(workers())
    rmprocs(workers())
