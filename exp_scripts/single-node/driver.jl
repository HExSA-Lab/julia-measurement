# 
# performs spawn/fetch experiments 
# for various proc counts
#
#sing StatsBase
using GR
using StatPlots
#using Plots

@everywhere include("spawn_fetch.jl")
@everywhere include("../../funcs_and_tasks/tunable_funcs.jl")

clear_workers() = rmprocs(workers())

# @exp_f:     the experiment function to run
# @f:         the function to spawn
# @iters:     number of iterations
# @throwout:  number of cold calls
# @max_count: we perform the experiment for 
#             1,2,4,...,max_count workers
#             (on this node)
# @pn       : file name for the plot
#
function exp_run(exp_f, f, iters, throwout, max_count, pn)

    lats = Any[]
    exp_num = 0
    i = 1

    while i <= max_count

        addprocs(i - 1)
    
        @everywhere include("../../funcs_and_tasks/tunable_funcs.jl")
        push!(lats, exp_f(f, iters, throwout))

        i *= 2
        exp_num += 1

        clear_workers()

    end

    p = boxplot!([ "$(2^i)" for i = 0:exp_num-1 ], lats[1], ylabel="latency (ns)", xlabel="Process count", outliers=true, marker=(0.5, :blue, stroke(3)), key=false)
    StatPlots.savefig(p, pn)

end
