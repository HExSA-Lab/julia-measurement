


# TODO: measure_atomic_cas
# TODO: measure_atomic_xchg
# TODO: measure_atomic_add
# TODO: measure_atomic_sub

function measure_atomic_set(iters, throwout)
    
    x = Base.Threads.Atomic{Int}(0)
    lats = Array{Int64}(iters)

    for i=1:throwout
        s = time_ns()
        x[] = 1
        e = time_ns()
        x[] = 0
        lats[i] = e - s
    end

    for i=1:iters
        s = time_ns()
        x[] = 1
        e = time_ns()
        x[] = 0
        lats[i] = e - s
    end

    lats

end
