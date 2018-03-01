# Can measure both sendtime and tasktime together in one function.
# Cannot provide string(exp_func) to arguments of MPI.Send and MPI.Recv
# Can create a string array of exp_funcs and pass defined numbers in
#   MPI.Send and MPI.Recv
# dispatch uses expcomm which is declared in exp_run. Will not work.
#  Will nested function effect performance?
# @exp_f:	[chosen index from funcs_list]
#	tasks_list =[dummy,fib,fac,sleep_work]
#	TASK_DUMMY  = 1
#	TASK_FIBO = 2
#	TASK_FAC = 3
#	TASK_SLEEP = 4,
# @tune:	[argument of function which tunes the amount of work]
# @iters: 	[number of iterations of experiment]
# @throwout:	[number of iterations to be thrown out]
# @max_count:   [maximum numbers of processes run]
# @pn: 		[plotfile name]
# @sendtimes:   [name of file where sendtime of process is stored
#						  with extension]
# @tasktimes:   [name of file where tasktime of process is stored
#						  with extension]
#
#
#
#
#
#
###
tasks_list =[dummy,fib,fac,sleep_work]
TASK_DUMMY  = 1
TASK_FIBO = 2
TASK_FAC = 3
TASK_SLEEP = 4
import MPI
@everywhere include("../../funcs_and_tasks/tunable_funcs.jl")
@everywhere include("timers.jl")
@everywhere import Timers
function exp_run(exp_f,tune,iters, throwout,max_count,pn,sendtimes, tasktimes)
	MPI.Init()
	expcomm  = MPI.COMM_WORLD
	rank  = MPI.Comm_rank(expcomm)
##Size should change for each max_count . Put loop here?
	size = MPI.Comm_size(expcomm)
	if rank == 0 
		write(sendtimes, "iteration sendtime  \n")
	end
	if rank == 1 
		write(tasktimes, "iteration tasktime  \n")
	end
	for i=1:throwout
		dispatch(exp_f,tune)
		i = i+1
	end
	for i=1:iters
		start = Timers.MPI_Wtime()
		dispatch(exp_f,tune)
		endtime   =Timers.MPI_Wtime()
		total = endtime -start
		if rank == 0 
			write(sendtimes, "$i  $total  \n")
		elseif rank == 1
			write(tasktimes, "$i  $total  \n")
		end
		i = i+1
	end
	MPI.Finalize()
end

function dispatch(taskid, arg)
	if rank==0
		a = Array(Int64,2)
		a[1] = taskid
		a[2] = arg
		MPI.Send(a,rank+1, rank+10, expcomm)
	elseif rank ==1
		a = Array(Int64,2)
		MPI.Recv!(a ,0, 10, expcomm)
		tasks[a[1]](a[2])
	else
	end
end
