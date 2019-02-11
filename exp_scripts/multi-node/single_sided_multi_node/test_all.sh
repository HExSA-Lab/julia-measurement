#!/bin/bash
N=$1
mpicc -O3 one_sided.c
for (( i=16 ; i<=$1 ;i=i*2 ))
do
       echo "Processes $i"
       mpirun -map-by node --hostfile myhosts -np $i ./a.out -i 100 -p 1000000 -g 1000000
       mpirun -map-by node --hostfile myhosts -np $i julia -L one_sided_script.jl
done

