import MPI
type bsptype
    size::Int64
    rank::Int64
    iters::Int64
    elements:: Int64
    flops :: Int64
    reads :: Int64
    writes :: Int64
    comms :: Int64
    comm_world
end

function do_flops(a)

    i = Int64
    sum = Float64
    x::Float64=1995
    
    val = Float64
    mpy = Float64 
    
    sum=x
    for i=1 :a.flops
    	val=x
	    mpy=x
    	sum = sum + mpy*val
    end
end

function do_reads(a)

    i = Int64
    mymem = Array{Int64}(reads)
    sum = Float64
    x = Float64
    for i=1:a.reads
	    sum = mymem[i]
    end
end

function do_writes(a)

    sum = Float64
    x::Float64=93

    sum = x

    mymem = Array{Int64}(writes)

    for i=1:a.writes
    	mymem[i] = sum
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
    println("entered do_comm")
    b = Array{Int64}(a.comms)
    println(a.rank, "<---rank")
    println(a.size, "<---size")
    if a.rank== a.size-1
        fwd = 0
    else
        fwd = a.rank+1
    end
    if a.rank==0
        bck = a.size-1
    else
        bck = a.rank-1
    end
    println(fwd,"<--fwd")
    println(bck,"<--bck")
    for i=1:a.comms
            MPI.Send(b, fwd, 10, a.comm_world)
            a1 = Array{Int64}(a.comms)
            MPI.Recv!(a1, bck, 10, a.comm_world)
    end
    MPI.Barrier(a.comm_world)
end

function doit_mpi(iters, elements, flops, reads, writes, comms)

    MPI.Init()
    bspcomm = MPI.COMM_WORLD
    rank = MPI.Comm_rank(bspcomm)
    size = MPI.Comm_size(bspcomm)
    a = bsptype(size, rank, iters, elements, flops, writes, reads, comms, bspcomm)
    println(a)
    MPI.Barrier(bspcomm)
    for i=1:iters
    	do_compute(a)
	    do_comms(a)
    end
    MPI.Barrier(bspcomm)
    MPI.Finalize()

    for i in workers()
        host, pid = fetch(@spawnat i (gethostname(), getpid()))
        println("Hello from process $(pid) on host $(host)!")
    end
    if MPI.Finalized()
        println("finalized")
    end
    rmprocs(workers)
    for i in workers()
        host, pid = fetch(@spawnat i (gethostname(), getpid()))
        println("Hello from process $(pid) on host $(host)!")
    end
    
end
