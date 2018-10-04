#!/bin/bash
sudo -u cc julia -e "using  Pkg; Pkg.add(\"MPI\"); Pkg.add(\"DocOpt\"); Pkg.update(); Pkg.build(\"MPI\")"

