c_file_id = "c_"
dat_suffix = ".dat"
cs = "comms_size_"
ccs= "comm_size_"

# files to store mean
pp_size = Array{Int64, 1}(undef, 20)
pp_size[1] = 2
[pp_size[i] = 2^i for i = 2:length(pp_size)]
pp_size = pp_size[3:20]

len_pp = length(pp_size)
c_pp_means= Array{String,1}(undef,len_pp)
jmpi_pp_means  = Array{String,1}(undef,len_pp);
f_c  = 0
for i = 1:len_pp
    filename_jm = cs*string(pp_size[i])*dat_suffix
    filename_c = ccs*c_file_id*string(pp_size[i])*dat_suffix
#    println(filename_jm)
    println(filename_c)
    c_pp_means[i] = filename_c
    jmpi_pp_means[i] = filename_jm
end
#=
files = [julia_pp_means, jmpi_pp_means]
filenames = ["julia_pp_means.dat", "jmpi_pp_means.dat"]
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
	println(size(os))
	os = os[11:100,:]
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
=#




















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
