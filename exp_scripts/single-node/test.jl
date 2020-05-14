#include all files.
using Distributed
using SharedArrays
include("../../funcs_and_tasks/tunable_funcs.jl")
include("atomics.jl")
include("driver.jl")
include("procs.jl")
include("tasks.jl")
#include("intr.jl")
include("channels.jl")
include("synch.jl")
include("cond.jl")
include("parfor.jl")
include("procs.jl")
#=
global ITERATIONS  = 100
global THROWOUT    = 10
global CREATIONS   = 1000
global FUNCTION = dummy
global SIZE = 50000000
=#
function benchmark_julia_performance( throwout,iters, creations, proc_creations, chan_size, nprocs, size, def, newval, set, compare )
	f = dummy
	println("#measure task throughput")

	a = measure_task_create_tput(f, iters, throwout, creations)
	writedlm("../../plotting_and_reporting/data/julia_task_create_throughput.dat", a)
	
	println("#####################")
	
	println("#measure task switching") 

	a = measure_task_switching(iters)
	writedlm("../../plotting_and_reporting/data/julia_task_switching.dat", a)

	println("#####################")
#=
	println("#measure condition notify")

	a = measure_notify_condition(throwout, iters)
	writedlm("../../plotting_and_reporting/data/julia_notify_condition.dat", a)

	println("#####################")
=#
	println("#measure channels -put take fetch")


	a = measure_put_channel(throwout, iters, chan_size)
	writedlm("../../plotting_and_reporting/data/julia_channel_put.dat", a)

	println("##################### put")
	
	a = measure_take_channel(throwout, iters, chan_size)
	writedlm("../../plotting_and_reporting/data/julia_channel_take.dat", a)

	println("##################### take")

	a = measure_fetch_channel(throwout, iters)
	writedlm("../../plotting_and_reporting/data/julia_channel_fetch.dat", a)

	println("##################### fetch")

#=	println("#measure interrupt: calib_int_call and measure_int_latency")

	a = calib_int_call(throwout, iters)
	writedlm("../../plotting_and_reporting/data/julia_calib_int_call.dat", a)

	println("##################### calib_int_call")

	a = measure_int_latency(throwout, iters)
	writedlm("../../plotting_and_reporting/data/julia_interrupt_latency.dat", a)

	println("##################### measure_int_latency")

=#	println("#measure pmap")

	a = measure_pmap(iters,throwout, size, nprocs)
	writedlm("../../plotting_and_reporting/data/julia_pmap.dat",a)

	println("##################### pmap")

	println("#measure parallel for ")

	a = measure_parfor(iters,throwout, size, nprocs)
	writedlm("../../plotting_and_reporting/data/julia_parallel_for.dat",a)

	println("##################### parfor")

	println("#measure experimental threads package")

	a = measure_thread_for(iters,throwout, size)
	writedlm("../../plotting_and_reporting/data/julia_thread_for.dat",a)

	println("##################### thread_for_experimental")
	
	println("#measure atomics set cas xchng add subtract or and nand xor min max")

	a = measure_atomic_set(iters,throwout)
	writedlm("../../plotting_and_reporting/data/julia_atomic_set.dat",a)
	
	println("##################### set")

	a = measure_atomic_cas(throwout, iters, def, compare, set)
	writedlm("../../plotting_and_reporting/data/julia_atomic_cas.dat",a)
	
	println("##################### cas")

	a = measure_atomic_xchng(throwout, iters, def, newval)
	writedlm("../../plotting_and_reporting/data/julia_atomic_xchng.dat",a)

	println("##################### xchng")
	
	a = measure_atomic_add(throwout, iters, def, newval)
	writedlm("../../plotting_and_reporting/data/julia_atomic_add.dat",a)

	println("##################### add")
	
	a = measure_atomic_subtract(throwout, iters, def, newval)
	writedlm("../../plotting_and_reporting/data/julia_atomic_subtract.dat",a)

	println("##################### sub")
	
	a = measure_atomic_or(throwout, iters, def, newval)
	writedlm("../../plotting_and_reporting/data/julia_atomic_or.dat",a)

	println("##################### or")
	
	a = measure_atomic_and(throwout, iters, def, newval)
	writedlm("../../plotting_and_reporting/data/julia_atomic_and.dat",a)

	println("##################### and")
	
	a = measure_atomic_nand(throwout, iters, def, newval)
	writedlm("../../plotting_and_reporting/data/julia_atomic_nand.dat",a)

	println("##################### nand")
	
	a = measure_atomic_xor(throwout, iters, def, newval)
	writedlm("../../plotting_and_reporting/data/julia_atomic_xor.dat",a)

	println("##################### xor")
	
	a = measure_atomic_min(throwout, iters, def, newval)
	writedlm("../../plotting_and_reporting/data/julia_atomic_min.dat",a)

	println("##################### min")
	
	a = measure_atomic_max(throwout, iters, def, newval)
	writedlm("../../plotting_and_reporting/data/julia_atomic_max.dat",a)

	println("##################### max")
	
	println("#measure locks - relocks -spinlocks and mutexes")
	println("#lock unlock and trylock for each")

	a = measure_relock_lock(iters, throwout)
	writedlm("../../plotting_and_reporting/data/julia_relock_lock.dat",a)

	println("##################### relock lock")
	
	a = measure_relock_trylock(iters, throwout)
	writedlm("../../plotting_and_reporting/data/julia_relock_trylock.dat",a)

	println("##################### relock trylock")
	
	a = measure_relock_unlock(iters, throwout)
	writedlm("../../plotting_and_reporting/data/julia_relock_unlock.dat",a)

	println("##################### relock unlock")
	
	a = measure_spinlock_lock(iters, throwout)
	writedlm("../../plotting_and_reporting/data/julia_spinlock_lock.dat",a)

	println("##################### spinlock lock")
	
	a = measure_spinlock_trylock(iters, throwout)
	writedlm("../../plotting_and_reporting/data/julia_spinlock_trylock.dat",a)

	println("##################### spinlock trylock")
	
	a = measure_spinlock_unlock(iters, throwout)
	writedlm("../../plotting_and_reporting/data/julia_spinlock_unlock.dat",a)

	println("##################### spinlock unlock")
	
	a = measure_mutex_lock(iters, throwout)
	writedlm("../../plotting_and_reporting/data/julia_mutex_lock.dat",a)

	println("##################### mutex lock")
	
	a = measure_mutex_trylock(iters, throwout)
	writedlm("../../plotting_and_reporting/data/julia_mutex_trylock.dat",a)

	println("##################### mutex trylock")
	
	a = measure_mutex_unlock(iters, throwout)
	writedlm("../../plotting_and_reporting/data/julia_mutex_unlock.dat",a)

	println("##################### mutex unlock")
	
	println("#measure Semaphores - iterations", iters, "throwout ", throwout)

	a = measure_sem_release(size, iters, throwout)
	writedlm("../../plotting_and_reporting/data/julia_sem_release.dat",a)

	println("##################### sem release")
	
	a = measure_sem_acquire(size, iters, throwout)
	writedlm("../../plotting_and_reporting/data/julia_sem_acquire.dat",a)
	
	println("##################### sem acquire")
	
	a = measure_proc_create_lat(iters, throwout)
	writedlm("../../plotting_and_reporting/data/julia_proc_create_lat.dat",a)
	a = measure_proc_create_tput(iters, throwout, proc_creations)
	writedlm("../../plotting_and_reporting/data/julia_proc_create_tput.dat",a)
	
	println("##################### sem acquire")
end


#function benchmark_julia_performance(throwout,iterations, creations, chan_size, nprocs, size, def, newval, set, compare )
benchmark_julia_performance( 		10         , 100    , 100     ,2 , 2        , 32  , 2  , 1   , 1     , 1  ,2)
