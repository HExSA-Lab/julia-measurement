#!/bin/bash
rm -rf *.dat
echo "Removing any previous output files"
echo " Testing BSP on Julia Native Primitives"
./test_julia.sh
echo "Testing BSP on Julia and MPI"
./test_julia_mpi.sh 16
echo "Testing BSP on C and MPI"
./test_mpi.sh 16
