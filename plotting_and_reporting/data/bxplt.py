import matplotlib.pyplot as plt
import csv
import numpy as np
import sys
data = []
#generalize this for a file . Use sys.argv[1]  for 1st argument put in 
#geenralize to take as many files as user likes 
# generalize to take xaxis label and yaxis
# for i = 1 : len(sys.argv)
# data[i] = np.loadtxt(sysargv[i]
# python bxplt.py filename.dat
#
def boxplot_files(filenames, xlabels,  yaxis):
    nfiles = len(filenames)
    xdef = np.arange(1,len(xlabels)+1,1)
#    print(nfiles)
    data = []
    for i in range(0,nfiles):
        temp_data = np.loadtxt(filenames[i])
 #       print(temp_data)
        data.append(temp_data)
  #      print(i)
   # print(data)
    plt.boxplot(data, showfliers = False)
    plt.xticks(xdef,xlabels)
    plt.ylabel(yaxis)
    plt.show()
#    print(data)

def hello(lex):
    print(lex)

tasknames = ["julia_task_crt.dat","baseline_pt_create.dat"]
#channames = ["julia_channel_put.dat","julia_channel_take.dat","julia_channel_fetch.dat","baseline_channels_put.dat","baseline_channels_get.dat"]
#condnames = ["julia_notify_condition.dat", "baseline_cond.dat"]
#parnames = ["julia_parallel_for.dat", "julia_pmap.dat", "baseline_pt_parallel_for.dat", "baseline_omp_parfor.dat"] 

yname = "latencies(in ns)"
boxplot_files(tasknames, ["julia", "pthreads"],  yname)
#boxplot_files(channames, ["julia put", "julia take", "julia fetch", "pthreads put", "pthreads get"],  yname)
#boxplot_files(condnames, ["julia", "pthreads"],  yname)
#boxplot_files(parnames, ["julia parallel for", "julia pmap", "pthreads", "omp"],  yname)

