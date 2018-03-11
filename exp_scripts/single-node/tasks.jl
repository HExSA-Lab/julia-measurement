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

c = Condition()
ch = Channel(4)
function notify_workers()
	notify(c)
	s = time_ns()
	put!(ch,s )
	println("Notifying ..")
end
function am_i_notified()
	
	wait(c) 	#unless notified task will be suspended and queued
	e = time_ns()
	println("Iam notified")
	put!(ch,e)
end
function measure_notify_condition(throwout, iters)
	ncl  	  =Array{Float64}(iters)
	tsk1 = Task(notify_workers) #fires the gun
	tsk2 = Task(am_i_notified)  #sprints

	for i = 1: throwout
		schedule(tsk2)	# task 2 is waiting for the gun
		if istaskdone(tsk2)== false
			yield()
		end
		schedule(tsk1)	# task 1 fires gun - start time 
			      	# task 1 will hear the bang and sprint 
		s = take!(ch)	#start time stamp
		e = take!(ch)   # end time stamp
		ncl[i] = e-s
	end
	for i = 1: iters
		schedule(tsk2)	# task 2 is waiting on condition c now 
		schedule(tsk1)	# task 1 will notify task 2 - start time 
			      	# task 1 will wake up and be queued
		s = take!(ch)	#start time stamp
		e = take!(ch)   # end time stamp
		ncl[i] = e-s
	end
	
	ncl
end

#
# measure Channels
# time taken to put an object into a channel
#	@iters : number of iterations 
# 	@throwout : number of iterations to throwout 
#
function measure_put_channel(throwout, iters)
	ch = Channel(32)
	lat = Array{Int64}(iters)
	for i = 1:throwout
		s = time_ns()
		put!(ch, 1)
		e = time_ns()
		take!(ch)
		lat[i] = e - s
	end
	for i = 1:iters
		s = time_ns()
		put!(ch, 1)
		e = time_ns()
		take!(ch)
		lat[i] = e - s
	end
	lat
end
function measure_take_channel(throwout, iters)
	ch = Channel(32)
	lat = Array{Int64}(iters)
	for i = 1:throwout
		put!(ch, 1)
		s = time_ns()
		take!(ch)
		e = time_ns()
		lat[i] = e - s
	end
	for i = 1:iters
		put!(ch, 1)
		s = time_ns()
		take!(ch)
		e = time_ns()
		lat[i] = e - s
	end
	lat
end
function measure_fetch_channel(throwout, iters)
	ch = Channel(32)
	lat = Array{Int64}(iters)
	for i = 1:throwout
		put!(ch, 1)
		s = time_ns()
		fetch(ch)
		e = time_ns()
		lat[i] = e - s
	end
	for i = 1:iters
		put!(ch, 1)
		s = time_ns()
		fetch(ch)
		e = time_ns()
		lat[i] = e - s
	end
	lat
end

