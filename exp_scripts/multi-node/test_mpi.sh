#!/bin/bash
N=$1
mpicc -O3 bsp_mpi.c
for (( i=16 ; i<=$1 ;i=i*2 ))
do
       echo "Processes $i"
       mpirun -map-by node --hostfile myhosts -np $i ./a.out -i 100 -e 100 -f 1000000 -r 5000000 -w 500000 -c 1000
done

