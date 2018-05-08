#
# Measurement framework for Julia future-like functions
#
# TODO: consider using BenchmarkTools.jl package here, if not
# we should justify the custom benchmarking (likely because we 
# want to use time-stamp counters)
#
# NOTE: @code_warntype generates a representation of your code that can be
# helpful in finding ex # pressions that result in type uncertainty. See
# @code_warntype below.
#

#using StatsBase


#
# This function measures the cost of a spawn 
#   @f: the function to spawn
#   @iters: the number of iterations over which to compute statistics
#   @throwout: the number of iterations to throw out (e.g. for cold cache/JIT effects)
#
# @return: an array of measured latencies
#
function measure_spawn_on(f, iters, throwout)

	latencies = Array{UInt64}(iters)

	for i = 1:throwout
		s = time_ns()
		fut = @spawn(f)
		@fetch(f)
		e = time_ns()
	end

	for i = 1:iters
		s = time_ns()
		fut = @spawn(f)
		e = time_ns()
		@fetch(fut)
		latencies[i] = e - s
	end

	return latencies

end

#
# This function measures the cost of a fetch that is
# preceded by a standard @spawn call.
#   @f: the function to spawn (the result of which will be fetched)
#   @iters: the number of iterations over which to compute statistics
#   @throwout: the number of iterations to throw out (e.g. for cold cache/JIT effects)
#
# @return: an array of measured latencies
#
function measure_fetch_on(f, iters, throwout)

	latencies = Array{UInt64}(iters)

	for i = 1:throwout
		fut = @spawn(f)
		s = time_ns()
		@fetch(fut)
		e = time_ns()
	end

	for i = 1:iters
		fut = @spawn(f)
		s = time_ns()
		@fetch(fut)
		e = time_ns()
		latencies[i] = e - s
	end

	return latencies

end


#
# This function measures the cost of a fetch that is
# preceded by a standard @spawn call.
#   @f: the function to spawn
#   @proc: the process ID on which to spawn the function
#   @iters: the number of iterations over which to compute statistics
#   @throwout: the number of iterations to throw out (e.g. for cold cache/JIT effects)
#
# @return: an array of measured latencies
#
function measure_spawn_at_on(f, proc, iters)

	latencies = Array{UInt64}(iters)
	
	for i = 1:throwout
		s = time_ns()
		fut = @spawnat(proc, f)
		@fetch(fut)
		e = time_ns()
	end

	for i = 1:iters
		s = time_ns()
		fut = @spawnat(proc, f)
		e = time_ns()
		@fetch(fut)
		latencies[i] = e - s
	end

	return latencies

end
