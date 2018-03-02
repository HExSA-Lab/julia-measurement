# 
# performs spawn/fetch experiments 
# for various proc counts
#
using StatsBase
using GR
using StatPlots
using Plots

@everywhere include("spawn_fetch.jl")
@everywhere include("../../funcs_and_tasks/tunable_funcs.jl")

clear_workers = rmprocs(workers())
    

# @exp_f:     	the experiment function to run
# @f:         	the function to spawn
# @iters:     	number of iterations
# @throwout:  	number of cold calls
# @max_count: 	we perform the experiment for 
#             	1,2,4,...,max_count workers
#             	(on this node)
# @total_procs: 	number of processes to be divided evenly over nodes
# @node_list:	list of hosts/name of nodes that are added with parent 
#  		at the end of the list
# @fn:	name of output data file
#
function spawn_at_exp_run(exp_f, f, iters, throwout, node_list, total_procs, fn)
	
    lats = Any[]
    node_count = length(node_list)
    curr_ppn   = 1
    max_ppn    = total_procs / node_count
    
    @assert node_count > 0 "Empty node list"
    
    @assert total_procs > 0 "Must provide process count > 0"

    @assert total_procs % node_count == 0 "Total process count must evenly divide thhe number of nodes"

    if !fn
        fn = "exp.dat"
    end
        
    while curr_ppn != max_ppn

        println(curr_ppn," processes per node")

        # add procs for remote nodes
        # -1 here because master (this node) is the last in the node list
        for j=1:node_count-1
            addprocs([node_list[j], curr_ppn])
        end

        # add procs for master (this node)
        addprocs(curr_ppn)

        push!(lats, exp_f(f, iters, throwout))

        curr_ppn *= 2

        # this will kill off remote workers too
        clear_workers()
    
    end

    writedlm(fn, lats) #writes the output in .dat file forwarded in the function

end

#
# main starts here 
#
#
node_list = ["tinker-0","tinker-1"] 	#tinker-1 is where the code is being run
exp_run(measure_spawn_on,dummy(),100,10,node_list,4, "output1.dat")
#exp_run(measure_spawn_on,fib(20),100,10,node_list,4, "output2.dat")
#exp_run(measure_spawn_at_on,dummy(),100,10,node_list,4, "output3.dat")
#exp_run(measure_spawn_at_on,fib(20),100,10,node_list,4, "output4.dat")
