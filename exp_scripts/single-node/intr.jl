
addprocs(1)


# holds the number of iterations to wait
const work = RemoteChannel(()->Channel{Int}(1))

# holds the remote wakeup timestamps
const res  = RemoteChannel(()->Channel{Int64}(1))


@everywhere function wait_for_excp(work, res)
    
    wait_iters = take!(work)

    while wait_iters > 0
        try
            while true
                sleep(1)    
            end
        catch e
            endtime = time_ns()
            put!(res, endtime)
            wait_iters -= 1
        end
    end
            
end

function measure_int_latency(throwout, iters)

    lats = Array{Int64}(iters)

    put!(work, throwout)

    # run it on a different core
    @async remotecall_fetch(wait_for_excp, 2, work, res)

    # remote proc is now sleeping waiting for an InterruptException

    for i=1:throwout

        # this sleep is necessary to give the remotefetch time to launc
        # the remote worker. If we interrupt the remote worker too early,
        # it won't be able to catch the exception and we'll crash
        sleep(1)

        s = time_ns()

        interrupt(2)

        e = take!(res)
            
        lats[i] = e - s
        
    end

    # remote worker is dead now, revive it

    put!(work, iters)

    @async remotecall_fetch(wait_for_excp, 2, work, res)
    
    for i=1:iters

        sleep(1)

        s = time_ns()

        interrupt(2)

        e = take!(res)
            
        lats[i] = e - s
        
    end

    lats

end


