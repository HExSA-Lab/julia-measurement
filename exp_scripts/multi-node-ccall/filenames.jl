c_id = "_c_"
julia_id = "_mpi_"

ops = ["writes", "reads", "flops", "comms"]

procs =["14", "28", "56", "112", "224"]

ext = ".dat"
for i= 1:4
	for j = 1:5
		filename =ops[i]*c_id*procs[j]*ext
		println(filename)
	end
end


for i= 1:4
	for j = 1:5
		filename =ops[i]*julia_id*procs[j]*ext
		println(filename)
	end
end
