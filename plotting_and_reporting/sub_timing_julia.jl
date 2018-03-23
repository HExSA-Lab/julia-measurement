b = readdlm("sub_julia.dat")
#println(size(b),"dims of timing.dat")
for (root, dirs, files) in walkdir("temp")
 for file in files
	file = "temp/"*file
#	println(file)
	a = readdlm(file)
#	println(size(a)," dimensions of file : ")
	a[:,1] = a[:,1] .- b[:,1]
#	println(a)
	writedlm(file, a)
 end
end
