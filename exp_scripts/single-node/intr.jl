#
# This experiment measure the latency to deliver
# an interrupt signal (exception) to a remote worker process
# on another core. It is assumed that addprocs will stripe
# workers across cores, or at least that Linux will be doing
# the right thing if fork()/clone() is involved under the covers.
#

addprocs(1)


# holds the number of iterations to wait
const work = RemoteChannel(()->Channel{Int}(1))

# holds the remote wakeup timestamps
const res  = RemoteChannel(()->Channel{Int64}(1))


# 
# Worker function which sleeps, waiting for interrupts
# to wake it. This is considered as a strange alternative
# to a blocking take!() on a remote channel for condition notification
# (we cannot apparently use Julia's condition variables (Condition()) 
# across processes). 
#
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


#
# This measures the overhead of invoking an interrupt,
# via the interrupt(n) function call. We will use this
# to calibrate our other interrupt measurements.
#
function calib_int_call(throwout, iters)

    lats = Array{Int64}(iters)

    for i=1:throwout
        s = time_ns()
        interrupt()
        e = time_ns()
    end

    for i=1:iters
        s = time_ns()
        interrupt()
        e = time_ns()
        lats[i] = e - s
    end

    lats

end


#
# Measure the time it takes between right before
# raising an interrupt and right after a remote worker
# receives the interrupt. The assumption here is
# that the timers used in both processes are relatively
# in sync. We need to subtract out the overhead of the actual
# interrupt call on the local node to approximate event delivery
# latency.
#
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

