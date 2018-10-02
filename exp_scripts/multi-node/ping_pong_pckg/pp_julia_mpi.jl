import MPI

type bsptype
    size::Int64
    rank::Int64
    iters::Int64
    comm_world
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
        else
            MPI.Recv!(arr, ping, 10, a.comm_world)
        end

        #PONG

        if a.rank== pong
            MPI.Send(arr, ping, 10, a.comm_world)
        else
            MPI.Recv!(arr, pong, 10, a.comm_world)
        end

        if a.rank == ping

            # end timer print out result
            stop  = time_ns()
            write(fs,"$(stop- start)\n")
            close(fs)
            println("time written")
        end
    i = i *2
    MPI.Barrier(a.comm_world)
    println("After Barrier")
    
    end
end

function doit_mpi(iters, throwout)
   
    MPI.Init()
    bspcomm = MPI.COMM_WORLD
    @everywhere include("pp_julia_mpi.jl")
    rank = MPI.Comm_rank(bspcomm)
    size = MPI.Comm_size(bspcomm)
    a = bsptype(size, rank, iters, bspcomm)
    
    for i=1:iters+throwout
	do_ping_pong(a)
	print("iteration-->",i)
    end
    MPI.Abort(bspcomm, 0)
end

