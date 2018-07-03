#!/bin/bash
N=$1
for i in $(seq 2 $N)
do
       echo "Processes $i"
       mpirun -map-by node --hostfile myhosts -np $i bsp_mpi 
done

