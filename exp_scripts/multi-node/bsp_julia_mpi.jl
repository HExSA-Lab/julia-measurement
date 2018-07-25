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
    lat_flops = Array{Float64}(a.flops)
    if a.rank==0
        fs = open("flops.dat", "a")
    end
    for i=1 :a.flops
        if a.rank==0
        	start = time_ns()
        end
    	val=x
	    mpy=x
    	sum = sum + mpy*val
        if a.rank==0
            stop  = time_ns()
            lat_flops[i] = stop- start
        end
    end
    if a.rank==0
        temp = lat_flops
        writedlm(fs, temp)
	close(fs)
    end
end

function do_reads(a)
    i = Int64
    mymem = Array{Int64}(reads)
    sum = Float64
    x = Float64
    lat_reads = Array{Float64}(a.reads)
    if a.rank==0
        fs = open("reads.dat", "a")
    end
    for i=1:a.reads
        if a.rank==0
        	start = time_ns()
        end
	    sum = mymem[i]
        if a.rank==0
            stop  = time_ns()
            lat_reads[i] = stop- start
        end
    end
    if a.rank==0
        temp =lat_reads
        writedlm(fs, temp)
	close(fs)
    end
end

function do_writes(a)

    sum = Float64
    x::Float64=93

    sum = x

    mymem = Array{Int64}(writes)

    lat_writes = Array{Float64}(a.writes)
    if a.rank==0
        fs = open("writes.dat", "a")
    end
    for i=1:a.writes
        if a.rank==0
        	start = time_ns()
        end
    	mymem[i] = sum
        if a.rank==0
            stop  = time_ns()
            lat_writes[i] = stop- start
        end
    end
    if a.rank==0
        temp = lat_writes
        writedlm(fs, temp)
	close(fs)
    end
end

function do_computes(a)

    i  = Int64
    lat_computes = Array{Float64}(a.elements)
    if a.rank==0
        fs = open("computes.dat", "a")
    end

    for i=1:a.elements
        if a.rank==0
        	start = time_ns()
        end
    	do_flops(a)
	do_reads(a)
    	do_writes(a)
        if a.rank==0
            stop  = time_ns()
            lat_computes[i] = stop- start
        end
    end
    if a.rank==0
        temp = lat_computes
        writedlm(fs, temp)
	close(fs)
    end
end

function do_comms(a)
    b = Array{Int64}(a.comms)
    lat_comms = Array{Float64}(a.comms)
    if a.rank==0
        fs = open("comms.dat", "a")
    end
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
    for i=1:a.comms
        if fwd == 1
        	start = time_ns()
        end
        MPI.Send(b, fwd, 10, a.comm_world)
        a1 = Array{Int64}(a.comms)
        MPI.Recv!(a1, bck, 10, a.comm_world)
        if fwd == 1
            stop  = time_ns()
            lat_comms[i] = stop- start
        end
    
    end
    MPI.Barrier(a.comm_world)
    if  a.rank==0
        temp = lat_comms
        writedlm(fs, temp)
	close(fs)
    end
end

function do_ping_pong(a)
    ping = 0
    pong = 1
    min = 8
    max = 1024*1024
    i = min
    println("ping", ping)
    println("pong", pong)
    while i <= max
        if a.rank ==ping
            file_suffix = "_"*string(i)*".dat"
            fs = open("comms_size"*file_suffix, "a")
        end
        arr=Array{Int8}(i)

        if a.rank ==ping

              start = time_ns()

        end

        #PING

        if a.rank == ping
            MPI.Send(arr, pong, 10, a.comm_world)
            println("ping has sent")
        else
            MPI.Irecv!(arr, ping, 10, a.comm_world)
            println("pong has recieved")
        end

        #PONG

        if a.rank== pong
            MPI.Send(arr, ping, 10, a.comm_world)
	    println("pong has sent")
        else
            MPI.Irecv!(arr, pong, 10, a.comm_world)
            println("ping has recieved")
        end

        if a.rank == ping

            # end timer print out result
	    println("Why not")
            stop  = time_ns()
            write(fs,"$(stop- start)\n")
            close(fs)
            println("time written")
        end
    i = i *2
    
    MPI.Barrier(a.comm_world)
    end
end

function doit_mpi(iters, elements, flops, reads, writes, comms)
   
    MPI.Init()
    bspcomm = MPI.COMM_WORLD
    @everywhere include("bsp_julia_mpi.jl")
    rank = MPI.Comm_rank(bspcomm)
    size = MPI.Comm_size(bspcomm)
    a = bsptype(size, rank, iters, elements, flops, writes, reads, comms, bspcomm)
    
    for i=1:iters
    	do_computes(a)
	if size==16
		do_ping_pong(a)
	end
   	do_comms(a)
	print("iteration-->",i)
    end
    println("About to finalize")
    MPI.Finalize()
    println("Finalized")    
end
