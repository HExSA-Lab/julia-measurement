using Distributed


mutable struct rem_obj
	throwout::Int64
	puts::Int64
	gets::Int64
	my_id::Int64
	chan_size::Int64
	master::Int64
	last::Int64
end


# measure Channels
# time taken to put an object into a channel
#	@iters : number of iterations 
# 	@throwout : number of iterations to throwout 
#
function measure_put_channel(a::rem_obj)

	chan_size = a.chan_size
	iters     = a.puts
	throwout  = a.throwout
	master    = a.master
	last      = a.last
	println(a.my_id)
	my_id     = a.my_id
	if my_id == last
		ch = RemoteChannel(()->Channel{Int8}(chan_size), master)
	else
		ch = RemoteChannel(()->Channel{Int8}(chan_size), my_id)
	end
	println("allocated")
	lat = Array{Int64,1}(undef, iters+throwout)

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
	if my_id == 1
		fs  = open("rem_size_"*string(chan_size)*".dat", "a")
		Distributed.remotecall_fetch(println, 1,fs, Statistics.mean(lat[throwout+1:throwout+iters]))
	end
end





# TODO: may want to consider having another worker put on the channel
# We may be eliding locking by doing this from one process.
#
function measure_take_channel(a::rem_obj)

	chan_size = a.chan_size
	iters     = a.puts
	throwout  = a.throwout
	master    = a.master
	last      = a.last
	my_id     = a.my_id
	if my_id == last
		ch = RemoteChannel(()->Channel{Int8}(chan_size), master)
	else
		ch = RemoteChannel(()->Channel{Int8}(chan_size), my_id)
	end
	println("allocated")
	lat = Array{Int64,1}(undef, iters+throwout)

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
	if my_id == 1
		fs  = open("rem_size_"*string(chan_size)*".dat", "a")
		Distributed.remotecall_fetch(println, 1,fs, Statistics.mean(lat[throwout+1:throwout+iters]))
		close(fs)
	end

end


function doit(throwout, nprocs, iters, puts, gets)

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
    master = 1
    Distributed.@everywhere include("/home/cc/julia-measurement/exp_scripts/multi-node/single_sided_multi_node/rem_channel.jl")
    min = 8
    max = 1024*1024
    i = min
    while (i<max)
   
   	for p in Distributed.procs()
		my_id = Distributed.remotecall_fetch(()->myid(),p)
    		a = rem_obj(throwout,puts,gets,my_id,i, master, size)
    		println("Starting experiment")

    		for i=1:iters
            		@sync Distributed.remote_do(measure_take_channel, p,a)
#	    		@sync Distributed.remote_do(measure_put_channel, p, a)
            	#println("iteration ---->", i)
        	end



    	end
    i = i*2
    end
    Distributed.rmprocs(Distributed.workers())
end
