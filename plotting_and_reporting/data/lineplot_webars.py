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
def lineplot_files(filenames, xlabels,  yaxis):

# FontSize

    SMALL_SIZE  = 10
    MEDIUM_SIZE = 12
    BIGGER_SIZE = 14
    plt.rc('font', size=MEDIUM_SIZE)          # controls default text sizes
    plt.rc('axes', titlesize=MEDIUM_SIZE)     # fontsize of the axes title
    plt.rc('axes', labelsize=MEDIUM_SIZE)     # fontsize of the x and y labels
    plt.rc('xtick', labelsize=MEDIUM_SIZE)    # fontsize of the tick labels
    plt.rc('ytick', labelsize=MEDIUM_SIZE)    # fontsize of the tick labels
    plt.rc('legend', fontsize=MEDIUM_SIZE)

    nfiles = len(filenames)
    xdef = np.arange(1,len(xlabels)+1,1)
#    print(nfiles)
    data       = []
    data_means = []
    data_stds  = []
    for i in range(0,nfiles):
        temp_data = np.loadtxt(filenames[i])
 #       print(temp_data)
        temp_mean = np.mean(temp_data)
        temp_std  = np.std(temp_data) 
        data.append(temp_data)
        data_means.append(temp_mean)
        data_stds.append(temp_stds)
  #      print(i)
    print(data)
    ax.bar(data, data_means, yerr=temp_stds, align='center', alpha=0.5, ecolor=black, capsize=10) 
#    plt.boxplot(data, showfliers = False)
    plt.xticks(xdef,xlabels)
    plt.ylabel(yaxis)
#    plt.show()
    plt.savefig(filenames[0][6:-3]+'.pdf')
#    print(data)
    del data[:]

def hello(lex):
    print(lex)

'''
tasknames = ["julia_task_create_throughput.dat","native_pt_create_f.txt"]
channames = ["julia_channel_put.dat","julia_channel_take.dat","julia_channel_fetch.dat","baseline_channels_put.dat","baseline_channels_get.dat"]
