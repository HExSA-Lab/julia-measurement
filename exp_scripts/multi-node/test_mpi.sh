#!/bin/bash
N=$1
mpicc -o bsp_mpi bsp_mpi.c
for (( i=16 ; i<=$1 ;i=i*2 ))
do
       echo "Processes $i"
       mpirun -map-by node --hostfile myhosts -np $i ./bsp_mpi 
done

