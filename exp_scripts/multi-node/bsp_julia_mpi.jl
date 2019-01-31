#= For Julia version 0.7 or higher 
using Distributed
=#

#=
#!/usr/bin/julia

using MPI

using DocOpt

include("cli.jl")
=#

#= FOR JULIA VERSION 0.7 OR HIGHER
mutable struct bsptype
=#
import MPI 
type bsptype
    size     :: Int64
    rank     :: Int64
    iters    :: Int64
    elements :: Int64
    flops    :: Int64
    reads    :: Int64
    writes   :: Int64
    comms    :: Int64
    comm_world
end

function do_flops(a)

    i          = Int64
    x::Float64 = 1995.1937
    sum        = x
    val        = Float64
    mpy        = Float64

    if a.rank == 0
        fn_suffix = "_mpi_"*string(a.size)*".dat"
        mn        = "flops"*fn_suffix
        fs        = open(mn, "a")
        start     = time_ns()
    end

    # do the actual floating point math
    for i=1 :a.flops
    	val = x
	    mpy = x
    	sum = sum + mpy*val
    end

    if a.rank == 0
        stop  = time_ns()
	write(fs,"$(stop-start)\n")
        close(fs)
    end
    sum
end


function do_reads(a)

    #= FOR JULIA VERSION 0.7 OR HIGHER
    mymem     = Array{Int64,1}(undef, a.reads)
    =#
   
    mymem     = Array{Int64,1}(a.reads)
    sum       = Float64
    x         = Float64
    i         = Int64

    if a.rank == 0
        fn_suffix = "_mpi_"*string(a.size)*".dat"
        mn        = "reads"*fn_suffix
        fs        = open(mn, "a")
        start     = time_ns()
    end

    # do the actual reads
    for i=1:a.reads
	    sum = mymem[i]
    end

    if a.rank == 0
        stop      = time_ns()
        write(fs,"$(stop- start)\n")
        close(fs)
    end
    sum

end


function do_writes(a)

    x::Float64   = 93.0
    sum::Float64 = x

    #= FOR JULIA VERSION 0.7 OR HIGHER
    mymem     = Array{Int64,1}(undef, a.writes)
    =#
    mymem = Array{Int64,1}(a.writes)


    if a.rank == 0
        fn_suffix = "_mpi_"*string(a.size)*".dat"
        mn        = "writes"*fn_suffix
        fs        = open(mn, "a")
    end

    if a.rank == 0
        start = time_ns()
    end

    # do the actual writes
    for i=1:a.writes
    	mymem[i] = sum
    end

    if a.rank == 0
        stop       = time_ns()
        write(fs,"$(stop- start)\n")
        close(fs)
    end
    mymem
end


function do_computes(a)

    i  = Int64
    for i=1:a.elements

    	do_flops(a)
        do_reads(a)
    	do_writes(a)

    end

end


function do_commus(a)
   println("do_comms")

    #= FOR JULIA VERSION 0.7 OR HIGHER
    b	      = Array{Int64,1}(undef, a.comms)
    =#
    b         = Array{Int64,1}(a.comms)
    #= FOR JULIA VERSION 0.7 OR HIGHER 
    a1 = Array{Int64,1}(undef, a.comms)
    =#
    a1 = Array{Int64,1}(a.comms)

    if a.rank == a.size-1
        fwd = 0
    else
        fwd = a.rank+1
    end

    if a.rank == 0
        bck = a.size-1
    else
        bck = a.rank-1
    end

    if a.rank == 0
        fn_suffix = "_mpi_"*string(a.size)*".dat"
        mn        = "comms"*fn_suffix
        fs        = open(mn, "a")
        start     = time_ns()
    end

    # do the actual communication phase
    for i=1:a.comms
        MPI.Send(b, fwd, 10, a.comm_world)
        MPI.Recv!(a1, bck, 10, a.comm_world)
    end

    # wait for everyone to finish
    MPI.Barrier(a.comm_world)

    if  a.rank == 0
        stop      = time_ns()
	println("$(stop-start)\n")
        #remote_do(write,0,fs,"$(stop- start)\n")
        close(fs)
    end
    a1
end

function doit_mpi(iters, elements, flops, reads, writes, comms)
    MPI.Init()

    bspcomm = MPI.COMM_WORLD

    #= FOR JULIA VERSION 0.7 OR HIGHER 
    Distributed.@everywhere include("bsp_julia_mpi.jl")
    =#
    Distributed.@everywhere include("bsp_julia_mpi.jl")

    rank = MPI.Comm_rank(bspcomm)
    size = MPI.Comm_size(bspcomm)

    a = bsptype(size, rank, iters, elements, flops, writes, reads, comms, bspcomm)
    
    for i=1:iters
    	do_computes(a)


        do_commus(a)
    end

    println("About to finalize")
    MPI.Abort(bspcomm, 0)

end
#=
# arg parsing
args = docopt(doc, version=v"0.0.1")

iters  = parse(Int, args["--iterations"])
elms   = parse(Int, args["--elements"])
flops  = parse(Int, args["--flops"])
reads  = parse(Int, args["--reads"])
writes = parse(Int, args["--writes"])
comms  = parse(Int, args["--comms"])

# actual invocation
doit_mpi(iters, elms, flops, reads, writes, comms)
=#
