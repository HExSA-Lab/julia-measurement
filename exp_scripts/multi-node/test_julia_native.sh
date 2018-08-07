#!/bin/bash

for (( i=1; i <=$1; i=i*2 ))
do
    ./bsp_julia_native.jl --nprocs $i --iterations 100 --elements 100 --flops 1000000 --reads 5000 --writes 5000 --comms 100
    julia remove.jl
done
