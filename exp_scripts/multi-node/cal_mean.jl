using Statistics
using DelimitedFiles
index_file 	= open("filenames.txt", "r")
lines    	= countlines(index_file)

seekstart(index_file)
println("Parameters: Flops  :  Reads :  Writes :  Comms :  Iterations : ")
println("Filename\t\t Mean \t\t Median \t\t Std.Dev \t\t Maximum\n ")

for i=1:lines-1
      file_name = strip(readuntil(index_file, '\n'))
      each_file = open(file_name, "r")
      readings 	= DelimitedFiles.readdlm(each_file)
      mean_file = Statistics.mean(readings)
      med_file 	= Statistics.median(readings)
      std_file 	= Statistics.std(readings)
      maxs_file = Statistics.maximum(readings)
      println(file_name ,"\t",mean_file, "\t", med_file,"\t", std_file, "\t", maxs_file ,"\n") 
end 

    close(index_file)
