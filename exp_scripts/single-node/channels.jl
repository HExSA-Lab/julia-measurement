

# measure Channels
# time taken to put an object into a channel
#	@iters : number of iterations 
# 	@throwout : number of iterations to throwout 
#
function measure_put_channel(throwout, iters, chan_size)

	ch = Channel(chan_size)
	lat = Array{Int64}(iters)

	for i = 1:throwout
		s = time_ns()
		put!(ch, 1)
		e = time_ns()
		take!(ch)
		lat[i] = e - s
	end
	for i = 1:iters
		s = time_ns()
		put!(ch, 1)
		e = time_ns()
		take!(ch)
		lat[i] = e - s
	end
	lat
end


# TODO: may want to consider having another worker put on the channel
# We may be eliding locking by doing this from one process.
#
function measure_take_channel(throwout, iters, chan_size)

	ch = Channel(chan_size)
	lat = Array{Int64}(iters)

	for i = 1:throwout
		put!(ch, 1)
		s = time_ns()
		take!(ch)
		e = time_ns()
		lat[i] = e - s
	end

	for i = 1:iters
		put!(ch, 1)
		s = time_ns()
		take!(ch)
		e = time_ns()
		lat[i] = e - s
	end

	lat

end


function measure_fetch_channel(throwout, iters)
	ch = Channel(32)
	lat = Array{Int64}(iters)
	for i = 1:throwout
		put!(ch, 1)
		s = time_ns()
		fetch(ch)
		e = time_ns()
		take!(ch)
		lat[i] = e - s
	end
	for i = 1:iters
		put!(ch, 1)
		s = time_ns()
		fetch(ch)
		e = time_ns()
		take!(ch)
		lat[i] = e - s
	end
	lat
end
