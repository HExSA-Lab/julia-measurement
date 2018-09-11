#!/bin/bash
N=$1

for (( i=16 ; i<=$1 ;i=i*2 ))
do
       echo "Processes $i"
       mpirun -map-by node --hostfile myhosts -np $i -i 100 -e 100 -f 1000000 -r 5000 -w 5000 -c 100 ./bsp_mpi 
done

