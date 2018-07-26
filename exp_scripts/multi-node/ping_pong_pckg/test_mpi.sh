#!/bin/bash
mpicc -o pp_mpi pp_mpi.c
mpirun -map-by node --hostfile myhosts -np 2 ./pp_mpi 

