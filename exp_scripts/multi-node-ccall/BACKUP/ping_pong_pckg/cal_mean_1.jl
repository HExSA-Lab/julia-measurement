using DelimitedFiles
using Statistics

pp_size = Array{Int64, 1}(undef, 20)
pp_size[1] = 2
[pp_size[i] = 2^i for i = 2:length(pp_size)]
pp_size = pp_size[3:20]

pp_len = length(pp_size)

j_mpi = open("j_mpi.txt","r")
c_mpi = open("c_mpi.txt", "r")

j = readdlm(j_mpi)
c = readdlm(c_mpi)

println(j)
println(c)
j_len = length(j)

j_median = Array{Float64,1}(undef,j_len)
c_median = Array{Float64,1}(undef,j_len)

if pp_len == j_len
	println("cool")
	j_tput = Array{Float64,1}(undef,j_len)
	c_tput = Array{Float64,1}(undef,j_len)
end
for i = 1:j_len
	js = j[i]
	cs = c[i]
	j_file = open(js, "r")
	c_file = open(cs, "r")
	j_arr  = DelimitedFiles.readdlm(j_file)
	c_arr  = DelimitedFiles.readdlm(c_file)
	j_median[i] = median(j_arr)
	c_median[i] = median(c_arr)
	if pp_len == j_len
		j_tput[i] = 2*pp_size[i]/mean(j_arr)
		c_tput[i] = 2*pp_size[i]/mean(c_arr)
	end
end


file_julia_median = "julia_pp_means.dat"
file_c_median     = "c_pp_means.dat"

if pp_len == j_len
	file_julia_tput = "julia_pp_tput.dat"
	file_c_tput     = "c_pp_tput.dat"
	writedlm(file_julia_tput, j_tput)
	writedlm(file_c_tput, c_tput)
end

DelimitedFiles.writedlm(file_julia_median, j_median)
DelimitedFiles.writedlm(file_c_median, c_median)
