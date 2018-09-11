#!/bin/bash

for (( i=1; i <=$1; i=i*2 ))
do
    ./bsp_julia_native.jl -n $i 
    julia remove.jl
done
