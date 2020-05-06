
function measure_proc_create_lat(iters, throwout)

    lats = Array{Float64,1}(undef,iters+throwout)

    for i = 1:throwout+iters

        s = time_ns()

        addprocs(1)

        e = time_ns()

        rmprocs(workers())

        lats[i] = e - s

    end

    lats[throwout+1:iters+throwout]
end


function measure_proc_create_tput(iters, throwout, creations)

    # array of proc creations per second
    tpcl = Array{Float64,1}(undef,iters+throwout)

    for i = 1:throwout+iters

        s = time_ns()

        for j = 1: creations
        	addprocs(1)
        end

        e = time_ns()

        rmprocs(workers())

        tpcl[i] = creations*1000000000 / ((e - s))

    end

    tpcl[throwout+1: throwout+iters]

end
