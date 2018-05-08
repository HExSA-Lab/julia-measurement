#
# @parallel will take the jobs to be done and divy them up # amongst available
workers right away.  # @parallel we get The specified range partitioned across
all workers.  # pmap will start each worker on a job.  # Once a worker finishes
with a job, it will give it the next available job.  # It is similar to queue
based multiprocessing as is common in python.  # Thus pmap is  not so much
a case of "redistributing" work # but rather of only giving it out at the right
time # and to the right worker in the first place.
#
#

#
# Measures @parallel for loop.
#
# Measure the time taken to set an array element to its index # in parallel
# using a @parallel for by nprocs workers. This is an embarassingly parallel
# op so there won't be any synchronization points (or reductions) performed
# across loops.
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


# TODO: pmap needs to be passed a function which determines
# which index it should start at and end at
function init_sub_array(a)

    # use nworkers() and worker_id() to figure
    # out where I start and where I end, and 
    # also use a.len()

    start = 1 # change me
    end = 0 # change me

    for i=start:end
        a[i] = i
    end

end

# Measures pmap() primitive
#
# measures time taken by pmap to allocating a new array  
# 	@iters		: number of iterations
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
        # TODO: update above
        pmap(init_sub_array, a)
        e = time_ns()
    end

    for i=1:iters
        s = time_ns()
        pmap(init_sub_array, a)
        e = time_ns()
        times[i] = e - s
    end

    rmprocs(workers())

    times

end


# Measures the same as the above but using the
# experimental threads package.
#
# 	@iters		: number of iterations
#	@throwout  	: number of iterations to throwout 
#	@size		: size of array
#
function measure_thread_for(iters, throwout, size)

    a = SharedArray{Int}(size)
    
    times = Array{Int64}(iters)

    for i=1:throwout
        s = time_ns()
        @sync Threads.@threads for j=1:size
            a[j] = j
        end
        e = time_ns()
    end

    for i=1:iters
        s = time_ns()
        @sync Threads.@threads for j=1:size
            a[j] = j
        end
        e = time_ns()
        times[i] = e - s
    end

    times

end
