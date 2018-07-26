c_file_id = "c_"
native_file_id = "native_"
dat_suffix = ".dat"
common_names =["flops_", "reads_", "writes_", "comms_"]
cs = "comms_size_"
ccs= "comm_size_"
pp = "ping_pong_"

# files to store mean

min = 8
max = 1024*1024
i = min
c = 1
proc_count = [2,4,8,16]
julia_proc_count = [1,2,4,8]
pp_size = Array{Int64}(Int(log2(max)-log2(min)+1))
while i<max+1
    pp_size[c] = i
    c = c+1
    i = i*2
end

all_bsp_files = (3*length(proc_count)*length(common_names))
all_pp_files = (3*length(pp_size))
all_files = all_bsp_files + all_pp_files

len_bsp = Int64(all_bsp_files/3)
c_bsp_means= Array{String}(len_bsp)
julia_bsp_means =  Array{String}(len_bsp)
jmpi_bsp_means  = Array{String}(len_bsp)
f_c = 1
for j in common_names
    for k in proc_count
        filename_c = j*c_file_id*string(k)*dat_suffix
        filename_jm = j*string(k)*dat_suffix
        c_bsp_means[f_c] = filename_c
        jmpi_bsp_means[f_c] = filename_jm
        f_c = f_c +1
    end
    f_c = f_c - 4
    for l in julia_proc_count
        filename_jn = j*native_file_id*string(l)*dat_suffix
        julia_bsp_means[f_c] = filename_jn
        f_c = f_c +1
    end
end

len_pp = Int64(all_pp_files/3)
c_pp_means= Array{String}(len_pp)
julia_pp_means =  Array{String}(len_pp)
jmpi_pp_means  = Array{String}(len_pp)
f_c  = 1
for size in pp_size
    filename_n = pp*native_file_id*string(size)*dat_suffix
    filename_jm = cs*string(size)*dat_suffix
    filename_c = ccs*c_file_id*string(size)*dat_suffix
    c_pp_means[f_c] = filename_n
    julia_pp_means[f_c] = filename_jm
    jmpi_pp_means[f_c] = filename_c
    f_c = f_c+1
end
files = [c_bsp_means, julia_bsp_means, jmpi_bsp_means, c_pp_means, julia_pp_means, jmpi_pp_means]
filenames = ["c_bsp_means.dat", "julia_bsp_means.dat", "jmpi_bsp_means.dat", "c_pp_means.dat", "julia_pp_means.dat", "jmpi_pp_means.dat"]
f_c  = 1
println("========================================================")
for each_group in files
    len = length(each_group)
    temp_arr= Array{Float64}(len)
    i = 1
    for f in each_group
        if isfile(f) == false
            println("=======================================================")
            println("============Files dont exist!==========================")
            println("=======================================================")
            println(f)
            println("========================================================")
            println("========================================================")
        end
        os = readdlm(f)
        temp =mean(os)
        temp_arr[i] =temp
        i = i+1
    end
    ws = open(filenames[f_c], "a")
    writedlm(ws, temp_arr)
    f_c = f_c+1
    println("========================================================")
    println("========================================================")
end





















#=

min = 8
max = 1024*1024
i = min
j = min
c_plotfile = "c_ping_pong_mean.dat"
j_plotfile = "j_ping_pong_mean.dat"
cs = open(c_plotfile,"a")
ct = open("c_ping_pong_tput.dat","a")
js = open(j_plotfile,"a")
jt = open("j_ping_pong_tput.dat","a")
while (i<=max)
    cmpi_fn= "comm_size_c_"*"$i"*".dat"
    a =     readdlm(cmpi_fn)
    println(i,"------>", mean(a))
    temp = mean(a)
    thp = temp/2*i
    write(cs,"$temp\n")
    write(ct,"$thp\n")
    i = i*2
end

println("==================================================")
println("==================================================")
println("==================================================")

while (j<=max)
    julia_fn = "comms_size_"*"$j"*".dat"
    b = readdlm(julia_fn)
    println(j,"------>", mean(b))
    temp = mean(b)
    thp = temp/2*j
    write(js,"$temp\n")
    write(jt,"$thp\n")
    j = j*2
end


println("==================================================")
println("==================================================")
println("==================================================")
o = open("all_means.dat", "w")
i = 2
s = ["reads_c_", "writes_c_","flops_c_", "reads_", "writes_", "flops_"]
dat = ".dat"
 ### reads
while i<17
        filename = "reads_c_2.dat"
        c =  readdlm(filename)
        print("a")
        temp = mean(c)
        write(o, filename )
        write(o,"$temp\n")
    i = i*2
end 

=#
