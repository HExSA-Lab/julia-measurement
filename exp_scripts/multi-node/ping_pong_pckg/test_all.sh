#!/bin/bash
rm -rf *.dat
echo "Removing any previous output files"
echo " Testing Ping Pong on Julia Native Primitives"
./test_julia.sh 
echo "Testing Ping Pong on Julia and MPI"
./test_julia_mpi.sh 128
echo "Testing Ping Pong on C and MPI"
./test_mpi.sh 128
