#!/usr/bin/env bash

cd /home/cc/julia-measurement/exp_scripts/multi-node
filename=myhosts

while read -r mchnames
do
	name="$mchnames"
	echo $name
	ssh -qn cc@$name "cd /home/cc/julia-measurement/exp_scripts/multi-node; git pull; mpicc -o bsp_mpi bsp_mpi.c;"
done < "$filename"
