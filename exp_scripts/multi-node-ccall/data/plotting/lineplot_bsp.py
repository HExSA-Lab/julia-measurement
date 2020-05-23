import matplotlib.pyplot as plt
import numpy as np

def plot_lineplot(files, xaxis, xlabel, ylabel1, ylabel2):
#define an array of arrays
    nfiles  = len(files)
    all_data = []
    i = 0 
    for f in files:
         # open and store data in each element of array of arrays
        fs = open(f,'r')
        all_data.append(fs.readlines())
        
        i = i+1
    points =np.arange(0,10,1)
    ax1 = plt.subplot(211)
    ax1.xaxis.set_tick_params(labelsize=13)
    ax1.xaxis.label.set_size(13)
    ax1.yaxis.label.set_size(13)
    a1 = plt.plot(all_data[0], 'r--', label = "C/MPI")
    a2 = plt.plot(all_data[1], '-', label = "Julia/MPI")
    a3 = plt.plot(all_data[2], ':', label = "Julia native")
    #plot each element of array of arrays with differnt marker 
    plt.xticks(points, xaxis)
    plt.xlabel(xlabel)
    plt.ylabel(ylabel2)
    plt.legend(loc=0)

    ax2 = plt.subplot(212)

    a4 = plt.plot(all_data[3], 'r--', label = "C/MPI")
    a5 = plt.plot(all_data[4], '-', label = "Julia/MPI")
    a6 = plt.plot(all_data[5], ':', label = "Julia native")
    plt.xticks(points, xaxis)
    plt.xlabel(xlabel)
    plt.ylabel(ylabel1)
    ax2.xaxis.set_tick_params(labelsize=13)
    ax2.xaxis.label.set_size(13)
    ax2.yaxis.label.set_size(13)
    plt.legend(loc=0)
    plt.show()

xaxis=[]
min = 8
ytick = 0
while min<= 1024*1024: 
    if ytick%2==0:
        if min >=1024:
            if min == 1024*1024:
                xaxis.append('1MB')
            else:
                b = 'KB'
                y = min
                y = int(y/1024)
                b = str(y)+b
                xaxis.append(b)
        else:
            b = 'B'
            b = str(min)+b
            xaxis.append(b)
        min = min*2*2
    ytick = ytick+1
files = ["c_pp_means.dat", "julia_pp_means.dat", "jmpi_pp_means.dat", "c_tput.dat", "julia_tput.dat", "jmpi_tput.dat"]
plot_lineplot(files, xaxis, "message size", "latencies(in ns)", "throughput(in bytes/ns)")
