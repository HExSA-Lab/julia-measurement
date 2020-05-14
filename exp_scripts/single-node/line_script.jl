using DelimitedFiles 
using Statistics
using Revise 
includet("driver.jl") 
# measure_spawn_on times fetch and spawn together
function overhead_spawn(min_proc, max_proc, iterations, throwout)
    	a = Array{Float64, 1}(undef, iterations)
    	preset_tune_for_europar_fix = [20, 400, 4000, 20000, 160000, 400000]
	ptfef = preset_tune_for_europar_fix
	filename = "/home/arizvi/julia-measurement/plotting_and_reporting/data/spawn_fetch_ov.dat" 
	fn  = open(filename, "a")
	mp = min_proc
	for i = 1:length(ptfef)
#	println(fn, "task_size = $(ptfef[i])")
		while min_proc < max_proc
			a  = exp_run(measure_spawn_on, fib(ptfef[i]),iterations,throwout, min_proc)
			min_proc = min_proc*2
#    			println(fn,"\t proc $min_proc, $(ptfef[i]), $(median(a))")
			println("$min_proc,task size = $(ptfef[i]),$(median(a))")
		end
		min_proc =mp
#	        println(" tune = $(preset_tune_for_europar_fix[i])     DONE!")
	end
	close(fn)

end

function null_spawn_and_threshold(min_proc, max_proc, iterations, throwout)
    	a = Array{Float64, 1}(undef, iterations)
	filename = "/home/arizvi/julia-measurement/plotting_and_reporting/data/spawn_fetch_null.dat" 
#	filename1 = "/home/arizvi/julia-measurement/plotting_and_reporting/data/spawn_fetch_threshold.dat" 
	fn  = open(filename, "a")
#	tn  = open(filename1, "a")
	while min_proc < max_proc
		a  = exp_run(measure_spawn_on, dummy(),iterations,throwout, min_proc)
		min_proc = min_proc*2
			println("$min_proc,threshhold,$(median(a))")
#	    	println(fn, "mean null with $min_proc processes on a single node = $(median(a))")
#    		println(tn, "mean threshold for $min_proc processes on a single node  = $(mean(a.*2))")
	end
	close(fn)
#	close(tn)

end
println("proc,leg_obj,median")
overhead_spawn(1,16, 100, 10)

null_spawn_and_threshold(1, 16, 100, 10)
