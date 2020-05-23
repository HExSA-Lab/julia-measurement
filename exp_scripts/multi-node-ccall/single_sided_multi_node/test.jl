using MPI
import Compat

function win()
	MPI.Init()
	rank = MPI.Comm_rank(MPI.COMM_WORLD)
	N  = MPI.Comm_size(MPI.COMM_WORLD)
	buf = fill(Int(rank),N)
	received = fill(-1,N)
	println(N ,"\n", buf, "\n", received,"\n")
	MPI.Win_create(buf, MPI.INFO_NULL, comm, win)
	MPI.Win_fence(0, win)
	MPI.Get(received, (rank+1)%N, win)
	MPI.Win_fence(0, win)
end
win()
