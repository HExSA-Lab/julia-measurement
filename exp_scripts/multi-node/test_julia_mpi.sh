#!/bin/bash
N=$1
for i in $(seq 4 $N)
do
       echo "Processes $i"
       mpirun -map-by node --hostfile myhosts -np $i julia  -L bsp_script.jl 
done

