#!/bin/bash
N=$1
for (( i=14 ; i<=$1 ;i=i*2 ))
do
       echo "Processes $i"
       mpirun -map-by node --hostfile /home/arizvi/julia-measurement/exp_scripts/multi-node/myhosts -np $i /home/arizvi/julia-1.3.1/bin/julia /home/arizvi/julia-measurement/exp_scripts/multi-node/bsp_script.jl

done

