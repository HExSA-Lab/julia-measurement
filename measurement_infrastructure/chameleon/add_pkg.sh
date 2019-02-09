#!/usr/bin/env bash
julia -e 'import Pkg; Pkg.add.(["MPI", "Compat", "Statistics", "Distributed"]); Pkg.update()'
