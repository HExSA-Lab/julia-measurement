#!/bin/bash
N=$1
for i in $(seq 2 $N)
do
       mpirun --allow-run-as-root -map-by node --mca btl_tcp_if_include eno1 --hostfile myhosts -np $i julia  -L bsp_script.jl 
done

