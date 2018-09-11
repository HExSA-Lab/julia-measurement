#!/usr/bin/env bash

filename=mchnames

while read -r mchnames
do
	name="$mchnames"
	echo $name
	ssh -qn -i mpi_key.pem cc@$name 
done < "$filename"
