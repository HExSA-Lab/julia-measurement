

# 
# measure the time taken to set an array in parallel
# using a @parallel for by nprocs workers. 
#
# @iters: number of trials to run for the experiment
# @throwout: number of trials to throw out
# @size: size of the array (of integers) to partition among procs
# @nprocs: number of julia workers to use
#
function measure_parfor(iters, throwout, size, nprocs)

    addprocs(nprocs)

    a = SharedArray{Int}(size)
    
    times = Array{Int64}(iters)

    for i=1:throwout
        s = time_ns()
        @sync @parallel for j=1:size
            a[j] = j
        end
        e = time_ns()
    end

    for i=1:iters
        s = time_ns()
        @sync @parallel for j=1:size
            a[j] = j
        end
        e = time_ns()
        times[i] = e - s
    end

    rmprocs(workers())

    times

end
