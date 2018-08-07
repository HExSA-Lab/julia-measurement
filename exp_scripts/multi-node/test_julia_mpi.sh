#!/bin/bash
N=$1
for (( i=16 ; i<=$1 ;i=i*2 ))
do
       echo "Processes $i"
       mpirun -map-by node --hostfile myhosts -np $i julia -L --iterations 100 --elements 100 --flops 1000000 --reads 5000 --writes 5000 --comms 100 bsp_julia_mpi.jl
done

