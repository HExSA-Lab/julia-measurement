
#
# @parallel will take the jobs to be done and divy them up 
# amongst available workers right away.
# @parallel we get The specified range partitioned across all workers. 
# pmap will start each worker on a job. 
# Once a worker finishes with a job, it will give it the next available job. 
# It is similar to queue based multiprocessing as is common in python. 
# Thus pmap is  not so much a case of "redistributing" work 
# but rather of only giving it out at the right time 
# and to the right worker in the first place.
#
#


# measure @parallel
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

# measure pmap()
# measures time taken by pmap to allocating a new array  
# 	@ iters		: number of iterations
#	@throwout  	: number of iterations to throwout 
#	@size		: size of array
#	@nprocs		: number of workers
#
function measure_pmap(iters, throwout, size, nprocs)

    addprocs(nprocs)

    a = [1:size]
    times = Array{Int64}(iters)

    for i=1:throwout
        s = time_ns()
        pmap(y -> y,a)
        e = time_ns()
    end

    for i=1:iters
        s = time_ns()
        pmap(y -> y, a)
        e = time_ns()
        times[i] = e - s
    end

    rmprocs(workers())

    times

end
