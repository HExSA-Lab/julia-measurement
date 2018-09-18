using Distributed
using Profile
type bsptype_julia
    nprocs   :: Int64
    iters    :: Int64
    elements :: Int64
    flops    :: Int64
    reads    :: Int64
    writes   :: Int64
    comms    :: Int64
end


function do_flops(a)
    i          = Int64
    x::Float64 = 1995.0
    sum        = x
    val        = Float64
    mpy        = Float64
    
    if myid() == workers()[1]
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

    if myid() == workers()[1]
        stop  = time_ns()
        write(ms,"$(stop- start)\n")
        close(ms)
    end
end


function do_reads(a)

    i     = Int64
    mymem = Array{Int64}(a.reads)
    sum   = Float64
    x     = Float64

    if myid() == workers()[1]
        fn_suffix = "_native_"*string(a.nprocs)*".dat"
        mn        = "reads"*fn_suffix
        ms        = open(mn, "a")
        start     = time_ns()
    end

    # do the actual reads
    for i=1:a.reads
	    sum = mymem[i]
    end

    if myid() == workers()[1]
        stop  = time_ns()
        write(ms,"$(stop- start)\n")
        close(ms)
    end
end


function do_writes(a)

    x::Float64 = 93.0
    sum        = x

    mymem = Array{Int64}(a.writes)

    if myid() == workers()[1]
        fn_suffix = "_native_"*string(a.nprocs)*".dat"
        mn        = "writes"*fn_suffix
        ms        = open(mn, "a")
        start     = time_ns()
    end

    # do the actual writes
    for i = 1 : a.writes
    	mymem[i] = sum
    end

    if myid() == workers()[1]
        stop  = time_ns()
        write(ms,"$(stop- start)\n")
        close(ms)
    end

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

    arr = Array{Int64}(a.comms)
    my_id      = my_id()
    master     = workers()[1]
    last_worker= workers()[nprocs()-1]


        # time here
    if myid()== 1
            fn_suffix = "_native_"*string(a.nprocs)*".dat"
            fs = open("comms"*fn_suffix, "a")
            start = time_ns()
    end

    for i = 1 : a.comms
        for p in workers()
            if p == last_worker
                @sync @spawnat(master, arr)
            else
                @sync @spawnat(p+1, arr) # sending a to workers p+1 from worker p
            end
        end
    end

        # time here
    if myid() == 1
        stop  = time_ns()
        write(fs, "$(stop- start)\n")
        close(fs)
    end


end


function doit(nprocs, iters, elements, flops, reads, writes, comms)

    hostfile = open("myhosts", "r")
    lines    = 0

    for line in eachline(hostfile)
        lines = lines+1
    end

    seekstart(hostfile)

    for i=1:lines-1
        machine_name = strip(readuntil(hostfile, '\n'))
        addprocs([(machine_name, nprocs)])
    end 

    close(hostfile)

    Distributed.@everywhere include("bsp_julia_native.jl")
    a = bsptype_julia(nprocs, iters, elements, flops,reads, writes, comms)
    println("Starting exeoriment")

    for i=1:iters
        for p in workers()
            remote_do(do_compute, p, a)
        end

	    do_comms(a)

        println("iteration ---->", i)

    end

    rmprocs(workers())
end
#=
# arg parsing
args = docopt(doc, version=v"0.0.1")

procs  = parse(Int, args["--nprocs"])
iters  = parse(Int, args["--iterations"])
elms   = parse(Int, args["--elements"])
flops  = parse(Int, args["--flops"])
reads  = parse(Int, args["--reads"])
writes = parse(Int, args["--writes"])
comms  = parse(Int, args["--comms"])

# actual invocation
doit(procs, iters, elms, flops, reads, writes, comms)
=#
