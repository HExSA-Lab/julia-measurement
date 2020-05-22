#!/bin/bash
mpirun -map-by node --hostfile myhosts -np 2 julia  -L pp_script_julia_mpi.jl 

