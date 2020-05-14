####################################
#
# ls *.dat >filenames.txt for input
#
#
####################################



using Statistics
using DelimitedFiles
index_file 	= open("filenames.txt", "r")
lines    	= countlines(index_file)

seekstart(index_file)
#=
dataframe 
lang, nproc, op, median
JULIA, 14, reads, 



=#

println("lang,procs,op,median")
for i=1:lines
      lang = String
      op   = String
      procs = Int64
      med_file = Float64
      filename = strip(readuntil(index_file, '\n'))
      if startswith(filename, r"comms_c|reads_c|writes_c|flops_c")
	  lang = "julia"
	  op   = filename[1:5]
	  if endswith(filename, "14.dat")
		procs = 1
	  elseif endswith(filename, "28.dat")
		procs = 2
	  elseif endswith(filename, "56.dat")
		procs = 4
	  elseif endswith(filename, "112.dat")
		procs = 8
	  elseif endswith(filename, "224.dat")
		procs = 16
          else
	        procs = 0
      	  end
      else
	  lang = "CPP"
	  op   = filename[1:5]
	  if endswith(filename, "14.dat")
		procs = 1
	  elseif endswith(filename, "28.dat")
		procs = 2
	  elseif endswith(filename, "56.dat")
		procs = 4
	  elseif endswith(filename, "112.dat")
		procs = 8
	  elseif endswith(filename, "224.dat")
		procs = 16
      	  else
	  	procs = 0
      	  end
      end
      each_file = open(filename, "r")
      readings 	= DelimitedFiles.readdlm(each_file)
      mean_file = Statistics.mean(readings)
      med_file 	= Statistics.median(readings)
      std_file 	= Statistics.std(readings)
      maxs_file = Statistics.maximum(readings)
      println(lang,",",procs,",",op,",",med_file) 
end 

    close(index_file)
