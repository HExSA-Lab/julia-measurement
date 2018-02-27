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

clear_workers() = rmprocs(workers())

# @exp_f:     	the experiment function to run
# @f:         	the function to spawn
# @iters:     	number of iterations
# @throwout:  	number of cold calls
# @max_count: 	we perform the experiment for 
#             	1,2,4,...,max_count workers
#             	(on this node)
# @pn:       	file name for the plot
# @procs: 	number of processes to be divided evenly over nodes
# @node_list:	list of hosts/name of nodes that are added with parent 
#  		at the end of the list
#@fn:		name of output file
function exp_run(exp_f, f, iters, throwout, node_list,procs,pn,fn)
	
    lats = Any[]
    exp_num = 0
    i = 2
    nodes =length(node_list)
    procpernode = 1
    if procs%nodes==0
    	while procpernode!= procs/2
    		procpernode = ceil(Int,i/nodes)
		println(i," processes per node")
		for j=1:(nodes-1)
       			addprocs([node_list[j],procpernode])
			addprocs(procpernode)
    		end

        push!(lats, exp_f(f, iters, throwout))
        exp_num += 1
	i = i*2 
        clear_workers()

    	end
    	writedlm(fn, lats) #writes the output in .dat file forwarded in the function
#########################
#	Plot commands	#
#	Need work	#
#########################
#	gr() 
#	p = boxplot!([ "$(2^i)" for i = 0:exp_num-1 ], lats[1], ylabel="latency (ns)", xlabel="Process count", outliers=false, marker=(0.5, :blue, stroke(3)), key=false)
#	ip = plot(x=i,y=lats, lats[1], ylabel="latency (ns)", xlabel="Process count", outliers=false, marker=(0.5, :blue, stroke(3)), key=false)
#	StatPlots.savefig(p, pn)
#	StatsPlot.savefig(ip,"linepl")
#	plot([])
    else
	error("Number of processeses deployed must evenly divide the number of nodes in the nodelist\n")
    end
end
#
# main starts here 
#
#
node_list = ["tinker-0","tinker-1"] 	#tinker-1 is where the code is being run
exp_run(measure_spawn_on,dummy(),100,10,node_list,4,"plot1","output1.dat")
exp_run(measure_spawn_on,fib(20),100,10,node_list,4,"plot2","output2.dat")
#exp_run(measure_spawn_at_on,dummy(),100,10,node_list,4,"plot3","output3.dat")
#exp_run(measure_spawn_at_on,fib(20),100,10,node_list,4,"plot4","output4.dat")
