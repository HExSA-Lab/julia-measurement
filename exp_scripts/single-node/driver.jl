# 
# performs spawn/fetch experiments 
# for various proc counts
#

using Distributed
using Revise 
using DelimitedFiles
@everywhere includet("spawn_fetch.jl")
@everywhere includet("../../funcs_and_tasks/tunable_funcs.jl")

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
function exp_run(exp_f, f, iters, throwout, max_count)
        addprocs(max_count- 1)
        lats = exp_f(f, iters, throwout)

        clear_workers()
	writedlm("16_proc.txt", lats)
	return lats
end
exp_run(measure_spawn_on, dummy(),100, 10, 16)

