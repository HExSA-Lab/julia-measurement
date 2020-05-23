import matplotlib.pyplot as plt
import numpy as np
import sys
import seaborn as sns

BIGGER_SIZE = 18
plt.rc('font', size=BIGGER_SIZE)          # controls default text sizes
plt.rc('axes', titlesize=BIGGER_SIZE)     # fontsize of the axes title
plt.rc('axes', labelsize=BIGGER_SIZE)     # fontsize of the x and y labels
plt.rc('xtick', labelsize=BIGGER_SIZE)    # fontsize of the tick labels
plt.rc('ytick', labelsize=BIGGER_SIZE)    # fontsize of the tick labels
plt.rc('legend', fontsize=BIGGER_SIZE)

def boxplot_files(fnames, xlabels,  yaxis):

    xdef   = np.arange(1,len(xlabels)+1,1)
    data   = [np.loadtxt(f) for f in fnames]

    plt.figure(1, figsize=(8,8))
    ax = sns.boxplot(x=xdef, y=data, showfliers = False, palette='inferno', width=0.5)
    ax.set(xticklabels=xlabels)
    plt.xticks(rotation=30)
    plt.ylabel(yaxis)
    plt.tight_layout()
    plt.savefig("channels.pdf")



exps        = ["c_put", "c_get", "julia_put", "julia_take", "julia_fetch"]
filenames   = ["data/channels/" + x + ".dat" for x in exps]
yaxis_title = "Latency (ns)"

boxplot_files(filenames, ["pthreads put", "pthreads get", "Julia put", "Julia take", "Julia fetch"],  yaxis_title)

