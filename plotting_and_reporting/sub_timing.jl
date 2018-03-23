#Make a temporary directory called temp in your pwd and copy all pthreads dat files into it 
b = readdlm("timing.dat")
for (root, dirs, files) in walkdir("temp")
 for file in files
	file = "temp/"*file
	println(file)
	a = readdlm(file)
	println(size(a)," dimensions of file : ")
	a[:,1] = a[:,1] .- mean(b)
	println(a)
	writedlm(file, a)
 end
end
