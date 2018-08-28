#!/bin/bash
mpicc -O3 pp_mpi.c
mpirun -map-by node --hostfile myhosts -np 2 ./a.out

