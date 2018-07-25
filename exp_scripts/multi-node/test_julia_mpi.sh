#!/bin/bash
N=$1
for (( i=16 ; i<=$1 ;i=i*2 ))
do
       echo "Processes $i"
       mpirun -map-by node --hostfile myhosts -np $i julia  -L bsp_script.jl 
done

