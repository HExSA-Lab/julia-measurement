@everywhere include("../../funcs_and_tasks/tunable_funcs.jl")
#@everywhere include("../../funcs_and_tasks/timing_tasks.jl")


#
# measures task creation throughhput
#
#
function measure_task_create_tput(f, iters, throwout, creations)
    # array of task creations per second
    tcps = Array{Float64}(iters)

    for i = 1:throwout
        s = time_ns()
        tsk = Task(f)
        schedule(tsk)
        e = time_ns()
    end

    for i = 1:iters
        s = time_ns()
        for j = 1:creations
            tsk = Task(f)
            schedule(tsk)
        end
        e = time_ns()
        tcps[i] = creations*1000000000 / ((e - s))
    end
    
    tcps

end


function ctx_switch_task()

    for i = 1:1000
        yield()
    end

end


function measure_task_switching(iters)

    # array of task switching latency
	tsl = Array{Float64}(iters)

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

#TODO : Cannot figure out what condition to apply
# the condition doesn't matter, the issue here is we need to
# coordinate between the tasks using a shared variable. Still
# figuring out how to do this


addprocs(1)


@everywhere mutable struct Condargs
    wait_iters::Int
    cvar::Condition
    starttime::Int64
    endtime::Int64
end


const work = RemoteChannel(()->Channel{Condargs}(1))
const res = RemoteChannel(()->Channel{Int64}(1))

@everywhere const cvar = Condition()

@everywhere function waitonit(work, res, cond)
	
    println("waitonint starting")

    cargs = take!(work)

    println("started at ", cargs.starttime, " waiting on ", cargs.cvar)

    for i=1:cargs.wait_iters
        wait(cvar) 	
        println("notified")
        endtime = time_ns()
        put!(res, endtime)
    end

end

function measure_notify_condition(throwout, iters)

    c = Condition()
    cargs = Condargs(throwout, c, 0, 0)
    println("running the remote do")

    put!(work, cargs)
    # run it on a different core
    @async remote_do(waitonit, 2, work, res)
    println("back from remote do")
    
    # remote proc is now waiting 

    for i=1:throwout

        s = time_ns()

        notify(c)

        e = take!(res)
            
        println("Got difference: ", e - s)
        
    end
    
    
end


