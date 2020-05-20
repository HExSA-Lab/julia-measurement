#!/bin/bash
N=$1
mpicc -O3 bsp_mpi.c
for (( i=14 ; i<=$1 ;i=i*2 ))
do
       echo "Processes $i"
       mpirun -map-by node --hostfile /home/arizvi/julia-measurement/exp_scripts/multi-node/myhosts -np $i ./a.out -i 100 -e 10 -f 1000000 -r 500000 -w 500000 -c 500
done

