#TODO : Cannot figure out what condition to apply
# the condition doesn't matter, the issue here is we need to
# coordinate between the tasks using a shared variable. Still
# figuring out how to do this


addprocs(1)


# holds the number of iterations to wait
const work = RemoteChannel(()->Channel{Int}(1))

# holds the remote wakeup timestamps
const res  = RemoteChannel(()->Channel{Int64}(1))

# equiv of the condition var
const wait = RemoteChannel(()->Channel{Int}(1))

# worker function
@everywhere function waitonit(work, res, wait)

    wait_iters = take!(work)

    for i=1:wait_iters
        take!(wait)
        endtime = time_ns()
        put!(res, endtime)
    end

end

# TODO: need to factor out the notify overhead
# TODO: assumption is iters > throwout
function measure_notify_condition(throwout, iters)

    lats = Array{Int64}(iters)

    put!(work, throwout)

    # run it on a different core
    @async remote_do(waitonit, 2, work, res, wait)

    # remote proc is now waiting 

    for i=1:throwout

        s = time_ns()

        put!(wait, 1)

        e = take!(res)
            
        lats[i] = e - s
        
    end

    # remote worker is dead now, revive it

    put!(work, iters)

    @async remote_do(waitonit, 2, work, res, wait)
    
    for i=1:iters

        s = time_ns()

        put!(wait, 1)

        e = take!(res)
            
        lats[i] = e - s
        
    end

    lats
    
end


