@everywhere include("../../funcs_and_tasks/tunable_funcs.jl")
#@everywhere include("../../funcs_and_tasks/timing_tasks.jl")


#
# measures task creation throughhput
#
#
function measure_task_create_tput(f, iters, throwout, creations)
#array of task creations per second
    tcps = Array{Float64}(iters)

    for i = 1:throwout
        s = time_ns()
        tsk = Task(f)
        e = time_ns()
    end

    for i = 1:iters
        s = time_ns()
        for j = 1:creations
            tsk = Task(f)
        end
        e = time_ns()
        tcps[i] = creations*1000000000 / ((e - s))
    end
    
    tcps

end


# TODO : Cannot figure out how to time this because task is not returning time calculated in function f
function measure_task_create_lat(f, iters, throwout)
#array of task creation latency
    	tcl = Array{Float64}(iters)
	for i = 1:throwout
        	s = time_ns()
		#println(1)
        	tsk = Task(f) 		# end time is  not being returned by f , @time is also not giving back proper time 
		println(tsk)
		#tcl[i] = tsk - s
		#println(3)
	end                                                                                                                                        

	tcl
	println(tcl)

end

function measure_task_switching(f, iters, throwout)
#array of task switching latency
	tsl = Array{Float64}(iters)
	# create two tasks

	tsk1  = Task(f)	
	tsk2 = Task(f)

	#schedule these tasks

	schedule(tsk1)
	schedule(tsk2)

	#switch tasks

	for i = 1 :throwout 
		s = time_ns()
		println(1)
		yieldto(tsk2)
		e = time_ns()
		yieldto(tsk1)
	end
	for i = 1 :iters 
		s = time_ns()
		yieldto(tsk2)
		e = time_ns()
		yieldto(tsk1)
		tsl[i] = e-s
	end

	tsl
	println(tsl)

end

#TODO : Cannot figure out what condition to apply
function measure_notify_condition(f, cond , iters , throwout)
	ncl  =Array{Float64}(iters)
	#create tasks 
	
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
	
	ncl
	println(ncl)
end

measure_notify_condition(dummy, fac(20), 10,10)
