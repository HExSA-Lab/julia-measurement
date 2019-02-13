using Distributed


mutable struct rem_obj
	puts::Int64
	my_id::Int64
	gets::Int64
	chan_size::Int64
end


# measure Channels
# time taken to put an object into a channel
#	@iters : number of iterations 
# 	@throwout : number of iterations to throwout 
#
function measure_put_channel(throwout, iters, chan_size)

	ch = RemoteChannel(()->Channel{Int8}(undef, chan_size))
	lat = Array{Int64,1}(undef, iters)

	for i = 1:throwout+iters
		if  a.my_id == 1
			s = time_ns()
		end
		put!(ch, 1)
		if  a.my_id == 1
			e = time_ns()
			lat[i] = e - s
		end
		take!(ch)
	end

	Distributed.remotecall_fetch(println, 1,lat[throwout+1:throwout+iters])

end





# TODO: may want to consider having another worker put on the channel
# We may be eliding locking by doing this from one process.
#
function measure_take_channel(throwout, iters, chan_size)

	ch = RemoteChannel(()->Channel{Int8}(undef, chan_size))
	lat = Array{Int64,1}(undef, iters)

	for i = 1:throwout+iters
		put!(ch, 1)
		if  a.my_id == 1
			s = time_ns()
		end
		take!(ch)
		if  a.my_id == 1
			e = time_ns()
			lat[i] = e - s
		end
	end

	Distributed.remotecall_fetch(println, 1,lat[throwout+1:throwout+iters])

end


function doit(nprocs, iters, puts, gets)

    hostfile = open("myhosts", "r")
    lines    = 0

    for line in eachline(hostfile)
        lines = lines+1
    end

    seekstart(hostfile)

    for i=1:lines
        machine_name = strip(readuntil(hostfile, '\n'))
	if machine_name=="mpi-instance-0"
		Distributed.addprocs(nprocs-1)
	else
        	Distributed.addprocs([(machine_name, nprocs)])
	end
    end 

    close(hostfile)
    size = Distributed.nworkers()+1
    println("Processes Done ---->",size)
    Distributed.@everywhere include("/home/cc/julia-measurement/exp_scripts/multi-node/single_sided_multi_node/rem_channel.jl")
    min = 8
    max = 1024*1024
    i = min
    while (i<max)
   
   	for p in Distributed.procs()
		my_id = Distributed.remotecall_fetch(()->myid(),p)
    		a = rem_obj(puts,gets,my_id,i)
    		println("Starting experiment")

    		for i=1:iters
            		@sync Distributed.remote_do(measure_get_channel, p, a)
	    		@sync Distributed.remote_do(measure_put_channel, p, a)
            	#println("iteration ---->", i)
        	end



    	end
    i = i*2
    end
    Distributed.rmprocs(Distributed.workers())
end
