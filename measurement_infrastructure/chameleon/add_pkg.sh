#!/usr/bin/env bash
julia -e Pkg.add\(\"MPI\"\)
julia -e Pkg.build\(\"MPI\"\)
julia -e Pkg.update\(\)
