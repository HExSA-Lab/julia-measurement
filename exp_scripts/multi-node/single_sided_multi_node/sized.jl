using MPI
using Statistics

mutable struct wintype
	rank::Int64
	N::Int64
	iters::Int64
	gets::Int64
	puts::Int64
	comm
end

function put_size(a)
    	min = 8
    	max = 1024*1024
	rank = a.rank
	N = a.N
	comm = a.comm
	win = MPI.Win()
	gets = a.gets
	received = fill(-1,N)
    	i = min
    	while i <= max
        	buf=Array{Int8,1}(undef,i)
		MPI.Win_create(buf, MPI.INFO_NULL, comm, win)
		MPI.Win_fence(0, win)
		lat  = Array{Float64}(undef,gets) 

		for j = 1:gets
        		if a.rank == 1
        	      		start = time_ns()
	        	end
			if rank==N-1
				MPI.Put(received, 0, win)
				MPI.Win_fence(0, win)
			else 
				MPI.Put(received, (rank+1), win)
				MPI.Win_fence(0, win)
			end	
		
        		if a.rank == 1
            		# end timer print out result
            			stop  = time_ns()
				lat[j] = start-stop
			end
		end
		MPI.Barrier(comm)

        	if a.rank == 1

			mean = Statistics.mean(lat)
            		file_suffix = "_"*string(i)*".dat"
            		open("win_put_size"*file_suffix, "a") do fs
				write(fs, "$mean\n")
            			close(fs)
			end
       	 	end
    		i = i *2
    
   	 end
end

function get_size(a)
    	min = 8
    	max = 1024*1024
	rank = a.rank
	N = a.N
	comm = a.comm
	win = MPI.Win()
	gets = a.gets
	received = fill(-1,N)
    	i = min
    	while i <= max
        	buf=Array{Int8,1}(undef,i)
		MPI.Win_create(buf, MPI.INFO_NULL, comm, win)
		MPI.Win_fence(0, win)
		lat  = Array{Float64}(undef,gets) 

		for j = 1:gets
        		if a.rank == 1
        	      		start = time_ns()
	    		end
			if rank==N-1
				MPI.Get(received, 0, win)
				MPI.Win_fence(0, win)
			else 
				MPI.Get(received, (rank+1), win)
				MPI.Win_fence(0, win)
			end	
        		if a.rank == 1

            			# end timer print out result
            			stop  = time_ns()
				lat[j]  = stop-start
       	 		end
		end
		if a.rank == 1
			mean = Statistics.mean(lat)
            		file_suffix = "_"*string(i)*".dat"
            		open("win_get_size"*file_suffix, "a") do fs
	        		write(fs,"$mean\n")
            			close(fs)
   			end
		end
		MPI.Barrier(comm)

    		i = i *2
    
   	 end
end


function driver(iters, gets, puts)
	MPI.Init()
	rank = MPI.Comm_rank(MPI.COMM_WORLD)
	N  = MPI.Comm_size(MPI.COMM_WORLD)
	comm = MPI.COMM_WORLD
	a = wintype(rank, N, iters, gets, puts, comm)
	for i = 1:iters
		put_size(a)
		get_size(a)
	end
	MPI.Finalize()
end

driver(100, 50000, 50000)
