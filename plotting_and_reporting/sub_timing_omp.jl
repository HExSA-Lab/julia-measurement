 #Create a directory called temp in your pwd and copy all omp dat files into it 
 a = readdlm("timing_omp.dat")
 b = readdlm("baseline_omp_parfor.dat")
 a  = b .- a
 writedlm("baseline_omp_parfor.dat",a)
