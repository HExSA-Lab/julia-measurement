type bsptype_julia
    nprocs::Int64
    iters::Int64
end

function ping_pong(a)
    println("Ping pong experiment on native Julia")
    min = 8 
    max = 1024*1024
    i  =min
    while i<= max 
        file_suffix = "_"*string(i)*".dat"
        fs = open("ping_pong_native"*file_suffix, "a")
        arr = Array{Int8}(i)
        start = time_ns()
        @sync @spawnat(workers()[1], arr)
        @sync @spawnat(workers()[], @sync @spawnat(1, arr))
        i = i *2
        stop  = time_ns()
        write(fs,"$(stop- start)\n")
        close(fs)
    end
    println("Done :ping pong ")
end


function doit(nprocs, iters)
    hostfile = open("myhosts", "r")
    lines = 0
    for line in eachline(hostfile)
	lines = lines+1
    end
    seekstart(hostfile)
    for i=1:lines-1
	machine_name = strip(readuntil(hostfile, '\n'))
	addprocs([(machine_name, nprocs)])
    end 
    close(hostfile)
    @everywhere include("pp_julia.jl")
    a = bsptype_julia(nprocs, iters)
    for i=1:iters
        ping_pong(a)
    end
    rmprocs(workers())
end


