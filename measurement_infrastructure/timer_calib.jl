


function timer_calib(throwout, iters)
    
    lats = Array{Int64}(iters)

    for i=1:throwout
        s = time_ns()
        e = time_ns()
        lats[i] = e - s
    end

    for i=1:iters
        s = time_ns()
        e = time_ns()
        lats[i] = e - s
    end

    lats
    
end
