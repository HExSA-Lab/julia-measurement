#= For julia version 0.7 or higher 
using Distributed
using Profile
mutable struct  bsptype_julia
=#
type bsptype_julia 
    nprocs::Int64   
    iters::Int64    
    elements::Int64 
    flops::Int64    
    reads::Int64    
    writes::Int64   
    comms::Int64   
    my_id::Int64
    size::Int64
end


function do_flops(a)
    i          = Int64
    x::Float64 = 1995.0
    sum        = x
    val        = Float64
    mpy        = Float64

    my_id      = myid()
    master     = workers()[1]
    
    if my_id == master
        fn_suffix = "_native_"*string(a.nprocs)*".dat"
        mn        = "flops"*fn_suffix
        ms        = open(mn, "a")
        start     = time_ns()
    end

    # do the actual floating point math
    for i=1 : a.flops
    	val = x
	mpy = x
    	sum = sum + mpy*val
    end

    if my_id == master
        stop  = time_ns()
        write(ms,"$(stop- start)\n")
        close(ms)
    end
    sum 
end


function do_reads(a)

    i     = Int64
    #= For julia version 0.7 or higher 
    mymem = Array{Int64}(undef,a.reads)
    =#
    mymem = Array{Int64}(a.reads)
    sum   = Float64
    x     = Float64

    my_id      = myid()
    master     = workers()[1]

    if my_id == master
        fn_suffix = "_native_"*string(a.nprocs)*".dat"
        mn        = "reads"*fn_suffix
        ms        = open(mn, "a")
        start     = time_ns()
    end

    # do the actual reads
    for i=1:a.reads
	    sum = mymem[i]
    end

    if my_id == master
        stop  = time_ns()
        write(ms,"$(stop- start)\n")
        close(ms)
    end
    sum
end


function do_writes(a)

    x::Float64 = 93.0
    sum        = x

    #= For julia version 0.7 or higher 
    mymem = Array{Int64}(undef,a.writes)
    =#
    mymem = Array{Int64}(a.writes)
    my_id      = myid()
    master     = workers()[1]



    if my_id == master
        fn_suffix = "_native_"*string(a.nprocs)*".dat"
        mn        = "writes"*fn_suffix
        ms        = open(mn, "a")
        start     = time_ns()
    end

    # do the actual writes
    for i = 1 : a.writes
    	mymem[i] = sum
    end

    if my_id == master
        stop  = time_ns()
        write(ms,"$(stop- start)\n")
        close(ms)
    end
    mymem
end


function do_compute(a)

    i  = Int64

    for i=1:a.elements
    	do_flops(a)
	do_reads(a)
    	do_writes(a)
    end

end


function do_comms(a)

    #= For julia version 0.7 or higher 
    arr = Array{Int64}(undef,a.comms)
    =#
    arr = Array{Int64}(a.comms)
    my_id      = a.my_id
    master     = procs()[1]
    last_worker= workers()[nworkers()]



    # time here
    if my_id == master 
            fn_suffix = "_native_"*string(a.nprocs)*".dat"
            fn ="comms"*fn_suffix
	    fs = remote_do(open, master, fn , "a")
           # start = remotecall_fetch(time_ns, master)
	    start  =remote_do(time_ns, master)
    end
    for i = 1 : a.comms
            if my_id == last_worker
                @sync @spawnat(master, arr)
            else
                @sync @spawnat(my_id+1, arr) # sending a to workers p+1 from worker p
            end
    end

    # time here
    if my_id == master
#        stop  = remotecall_fetch(time_ns, master)
 	stop = remote_do(time_ns, master)
	elapsed = stop-start
        remote_do(write, master, fs, "$elapsed\n")
        remote_do(close,master, fs)
   end

end


function doit(nprocs, iters, elements, flops, reads, writes, comms)

    hostfile = open("myhosts", "r")
    lines    = 0

    for line in eachline(hostfile)
        lines = lines+1
    end

    seekstart(hostfile)

    for i=1:lines
        machine_name = strip(readuntil(hostfile, '\n'))
	if machine_name=="mpi-instance-0"
		addprocs(nprocs-1)
	else
        	addprocs([(machine_name, nprocs)])
	end
    end 

    close(hostfile)
    size = nworkers()+1
    println("Processes Done ---->",size)
    Distributed.@everywhere include("bsp_julia_native.jl")
    for p in procs()
	my_id = remotecall_fetch(()->myid(),p)
    	a = bsptype_julia(nprocs, iters, elements, flops,reads, writes, comms, my_id, size)
    	println("Starting experiment")

    	for i=1:iters
            @sync remote_do(do_compute, p, a)
	    @sync remote_do(do_comms, p, a)
            #println("iteration ---->", i)
        end



    end

    rmprocs(workers())
end
#=
arg parsing
args = docopt(doc, version=v"0.0.1")

procs  = parse(Int, args["--nprocs"])
iters  = parse(Int, args["--iterations"])
elms   = parse(Int, args["--elements"])
flops  = parse(Int, args["--flops"])
reads  = parse(Int, args["--reads"])
writes = parse(Int, args["--writes"])
comms  = parse(Int, args["--comms"])

 actual invocation
doit(procs, iters, elms, flops, reads, writes, comms)
=#
