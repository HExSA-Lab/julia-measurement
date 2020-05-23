import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

BIGGER_SIZE = 18
plt.rc('font', size=BIGGER_SIZE)          # controls default text sizes
plt.rc('axes', titlesize=BIGGER_SIZE)     # fontsize of the axes title
plt.rc('axes', labelsize=BIGGER_SIZE)     # fontsize of the x and y labels
plt.rc('xtick', labelsize=BIGGER_SIZE)    # fontsize of the tick labels
plt.rc('ytick', labelsize=BIGGER_SIZE)    # fontsize of the tick labels
plt.rc('legend', fontsize=BIGGER_SIZE)

def violin_plot_files(fnames, xlabels,  yaxis):
    nfiles = len(fnames)
    xdef = np.arange(1,len(xlabels)+1,1)
    data = []
    for i in range(0, nfiles):
        temp_data = np.loadtxt(fnames[i])
        data.append(temp_data)

    plt.figure(figsize=(5,5))
    ax = sns.violinplot(data=data)
    ax.set(xticklabels=xlabels)
    plt.xticks(rotation=30)
    plt.ylabel(yaxis)
    plt.tight_layout()
    plt.savefig("condvars.pdf")


filenames = ["data/condvar/c_cond.dat","data/condvar/julia_cond.dat"]

yaxis_title = "Notification latency (ns)"
violin_plot_files(filenames, ["C (pthreads)", "Julia"],  yaxis_title)
