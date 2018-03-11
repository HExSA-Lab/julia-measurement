#TODO : Cannot figure out what condition to apply
# the condition doesn't matter, the issue here is we need to
# coordinate between the tasks using a shared variable. Still
# figuring out how to do this


addprocs(1)


@everywhere mutable struct Condargs
    wait_iters::Int
    cvar::Condition
    starttime::Int64
    endtime::Int64
end


const work = RemoteChannel(()->Channel{Condargs}(1))
const res = RemoteChannel(()->Channel{Int64}(1))

@everywhere const cvar = Condition()

@everywhere function waitonit(work, res, cond)
	
    println("waitonint starting")

    cargs = take!(work)

    println("started at ", cargs.starttime, " waiting on ", cargs.cvar)

    for i=1:cargs.wait_iters
        wait(cvar) 	
        println("notified")
        endtime = time_ns()
        put!(res, endtime)
    end

end

function measure_notify_condition(throwout, iters)

    c = Condition()
    cargs = Condargs(throwout, c, 0, 0)
    println("running the remote do")

    put!(work, cargs)
    # run it on a different core
    @async remote_do(waitonit, 2, work, res)
    println("back from remote do")
    
    # remote proc is now waiting 

    for i=1:throwout

        s = time_ns()

        notify(c)

        e = take!(res)
            
        println("Got difference: ", e - s)
        
    end
    
    
end


