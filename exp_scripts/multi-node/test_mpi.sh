#!/bin/bash
N=$1
mpicc -o bsp_mpi bsp_mpi.c
for i in $(seq 4 $N)
do
       echo "Processes $i"
       mpirun -map-by node --hostfile myhosts -np $i ./bsp_mpi 
done

