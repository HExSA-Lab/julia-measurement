import MPI
import MPI: Status
using Profile
using PProf 

mutable struct bsptype
    size::Int64
    rank::Int64
    iters::Int64
    comm_world
end

const MYCOMMWORLD = Cint(1140850688)
function MySend(buf::Array{Int8}, cnt::Cint, dst::Cint, tag::Cint, comm::Cint)
	ccall((:MPI_Send, "libmpich"), Cint, 
				   (Ptr{Cchar}, Cint, Cint, Cint, Cint, Cint),
				   Base.cconvert(Ptr{Cchar}, buf), 
				   cnt,
				   Cint(1275068673),
				   dst,
				   tag,
				   comm)
	return nothing
end

function MyRecv(buf::Array{Int8}, cnt::Cint, src::Cint, tag::Cint, comm::Cint)
	stat_ref = Ref{Status}(MPI.STATUS_EMPTY)
	ccall((:MPI_Recv, "libmpich"), Cint, 
				   (Ptr{Cchar}, Cint, Cint, Cint, Cint, Cint, Ptr{Status}),
				   Base.cconvert(Ptr{Cchar}, buf), 
				   cnt,
				   Cint(1275068673),
				   src,
				   tag,
				   comm,
				   stat_ref)
	return stat_ref[]
end


function do_ping_pong(a)
    ping = 0
    pong = 1
    min = 8
    max = 1024*1024
    i = min
    #println("ping", ping)
    #println("pong", pong)
    while i <= max
        if a.rank ==ping
            file_suffix = "_"*string(i)*".dat"
            fs = open("comms_size"*file_suffix, "a")
        end
        arr=Array{Int8,1}(undef,i)

        if a.rank ==ping

              start = time_ns()

        end

        #PING

        if a.rank == ping
            #@profile MPI.Send(arr, pong, 10, a.comm_world)
            @profile MySend(arr, Base.cconvert(Cint, length(arr)), Base.cconvert(Cint, pong), Cint(10), MYCOMMWORLD)
        else
            MyRecv(arr, Base.cconvert(Cint, length(arr)), Base.cconvert(Cint, ping), Cint(10), MYCOMMWORLD)
        end

        #PONG

        if a.rank== pong
            MySend(arr, Base.cconvert(Cint, length(arr)), Base.cconvert(Cint, ping), Cint(10), MYCOMMWORLD)
        else
            MyRecv(arr, Base.cconvert(Cint, length(arr)), Base.cconvert(Cint, pong), Cint(10), MYCOMMWORLD)
        end

        if a.rank == ping

            # end timer print out result
            stop  = time_ns()
            write(fs,"$(stop- start)\n")
            close(fs)
            #println("time written")
        end
    i = i *2
    MPI.Barrier(a.comm_world)
    #println("After Barrier")
    
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
#	if i ==1 
#		@profile do_ping_pong(a)
#		pprof(web=true)
#	end
	do_ping_pong(a)
	#print("iteration-->",i)
    end
    #MPI.Abort(bspcomm, 0)
	MPI.Finalize()
end

