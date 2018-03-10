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
function measure_notify_condition(iters)
	ncl  =Array{Float64}(iters)
#= 	#create tasks 
	
	tsk1 = Task(f)

	#create a condition 
	cond  =Condition()
	schedule(tsk1)
	for i = 1:throwout 
        	wait(cond)
		fac(20)
		s = time_ns()
		println(1)
		notify(cond, all = true, error = false)
		println(2)
		e = time_ns()
	end
	for i = 1:iters 
        	wait(cond)
		fac(20)
		s = time_ns()
		notify(cond, all = true, error = false)
		e = time_ns()
		ncl[i] = e-s
	end
=#
	c =  Condition() # what is he condition exactly
	for i = 1:iters
		@async begin
			wait(c)
			#notified
		end
		@async begin 
			#do some work, what work though?
			s = time_ns()
			notify(c)
			e = time_ns()	
			ncl[i] = e- s 
			#finished
		end
	end
	ncl
end

