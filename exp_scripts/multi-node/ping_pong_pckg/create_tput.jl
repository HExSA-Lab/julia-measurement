files  = ["c_pp_means.dat", "julia_pp_means.dat", "jmpi_pp_means.dat"]
o_file = ["c_tput.dat", "julia_tput.dat", "jmpi_tput.dat"]
c = 1
 for f in files
        a = readdlm(f)
        i = 1
        min = 8
        max = 1024*1024
        while min<=max
            a[i] = 2*min/a[i]
            i = i+1
            min = min*2
        end
        writedlm(o_file[c], a)
        c = c+1
end
