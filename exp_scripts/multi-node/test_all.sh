#!/bin/bash
rm -rf *.dat
./test_julia.sh
./test_julia_mpi.sh
./test_mpi.sh
