include("driver.jl") 

function overhead_spawn(tune, max_proc, iterations, throwout, filename)
    fn = "/projects/amal/julia-measurement/plotting_and_reporting/data/"*filename 
    a = Array{Array{Float64}}(tune)
	for i = 1:tune
		a[i]=exp_run(measure_spawn_on, fib(i),iterations,throwout, max_proc)
        println(i, " = tune     DONE!")
	end
    writedlm(fn, a)

end

function overhead_fetch(tune, max_proc, iterations, throwout, filename)
    a = Array{Array{Float64}}(tune)
	for i = 1:tune
		a[i]=exp_run(measure_fetch_on, fib(i),iterations,throwout, max_proc)
        println(i," = tune ", "\t DONE!")
	end
    writedlm(filename, a)
end
# comment out this section if not using sf_script.sh
println(ARGS[1])
tune = parse(Int, ARGS[2])
max_proc = parse(Int, ARGS[3])
iteration = parse(Int, ARGS[4])
throwout = parse(Int, ARGS[5])
filename = ARGS[6]
if ARGS[1]=="1"
    overhead_spawn(tune,max_proc,iteration,throwout, filename)
elseif ARGS[1]=="2"
    overhead_fetch(tune,max_proc,iteration,throwout, filename)
else
    println("wrong choice, Ctrl+c to try again")
end

