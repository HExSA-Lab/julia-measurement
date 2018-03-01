module Timers

import MPI

function MPI_Wtime()
    return ccall((:MPI_Wtime, "libmpi.so") , Float64, ())
end

start = Array{Float64}(64)
elapsed = Array{Float64}(64)

function timer_clear(n)
	elapsed[n] = 0.0
end

function timer_start(n)
	start[n] = MPI_Wtime()
end

function timer_stop(n)
	now = MPI_Wtime()
	tm = now - start[n]
	elapsed[n] += tm
end

function timer_read(n)
	return elapsed[n]
end
	
end
