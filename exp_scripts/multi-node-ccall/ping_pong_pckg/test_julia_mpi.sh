#!/bin/bash
mpirun -map-by node --hostfile myhosts -np 2 /home/arizvi/julia-1.3.1/bin/julia pp_script_julia_mpi.jl 

