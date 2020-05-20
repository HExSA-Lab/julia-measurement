using MPI
using Distributed
using Revise
@everywhere includet("bsp_julia_mpi.jl");
#mpirun -map-by node --hostfile myhosts -np $i ./a.out -i 100 -e 10 -f 1000000 -r 500000 -w 500000 -c 1000
    iters = 100
    elements = 10
    flops = 1000000
    reads = 500000
    writes = 500000
    comms = 1000
    doit_mpi(iters,elements, flops, reads, writes,comms)    
    rmprocs(workers())
