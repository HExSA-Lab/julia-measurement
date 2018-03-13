
function measure_proc_create_lat(iters, throwout)

    lats = Array{Float64}(iters)

    for i = 1:throwout

        s = time_ns()

        addprocs(1)

        e = time_ns()

        rmprocs(workers())

    end

    for i = 1:iters

        s = time_ns()

        addprocs(1)

        e = time_ns()

        rmprocs(workers())

        lats = e - s

    end

end


function measure_proc_create_tput(iters, throwout, creations)

    # array of proc creations per second
    tpcl = Array{Float64}(iters)

    for i = 1:throwout

        s = time_ns()

        for j = 1: creations
        	addprocs(1)
        end

        e = time_ns()

        rmprocs(workers())

    end

    for i = 1:iters

        s = time_ns()

        for j = 1: creations
        	addprocs(1)
        end

        e = time_ns()

        rmprocs(workers())

        tpcl[i] = creations*1000000000 / ((e - s))

    end

    tpcl

end
