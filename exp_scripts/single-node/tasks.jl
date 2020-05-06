@everywhere include("../../funcs_and_tasks/tunable_funcs.jl")
#@everywhere include("../../funcs_and_tasks/timing_tasks.jl")


#
# measures task creation throughhput
#
#
function measure_task_create_tput(f, iters, throwout, creations)
    # array of task creations per second
    tcps = Array{Float64,1}(undef,iters+throwout)

    for i = 1:throwout+iters
        s = time_ns()
        for j = 1:creations
            tsk = Task(f)
            schedule(tsk)
        end
        e = time_ns()
        tcps[i] = creations*1000000000 / ((e - s))
    end
    
    tcps[throwout+1:throwout+iters]

end


function ctx_switch_task()

    for i = 1:1000
        yield()
    end

end


function measure_task_switching(iters)

    # array of task switching latency
	tsl = Array{Float64,1}(undef,iters)

	# create two tasks
	tsk1 = Task(ctx_switch_task)	
	tsk2 = Task(ctx_switch_task)

	# schedule these tasks

    # warm up once
	schedule(tsk1)
	schedule(tsk2)

    while istaskdone(tsk1) == false && istaskdone(tsk2) == false
        # wait on them to finish
        yield()
    end

	# the actual experiment

	for i = 1 :iters 

        tsk1 = Task(ctx_switch_task)	
        tsk2 = Task(ctx_switch_task)

        schedule(tsk1)
        schedule(tsk2)

		s = time_ns()
        
        while istaskdone(tsk1) == false && istaskdone(tsk2) == false
            # wait on them to finish
            yield()
        end

        e = time_ns()

        # time it took to yield 1000 times for each Task (total of 2000 yields())
		tsl[i] = (e - s)/2000

	end

	tsl

end

