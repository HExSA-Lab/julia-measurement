import matplotlib as mpl
import matplotlib.pyplot as plt
from matplotlib import cm
import numpy as np
from scipy import stats as st

BIGGER_SIZE = 18
plt.rc('font', size=BIGGER_SIZE)          # controls default text sizes
plt.rc('axes', titlesize=BIGGER_SIZE)     # fontsize of the axes title
plt.rc('axes', labelsize=BIGGER_SIZE)     # fontsize of the x and y labels
plt.rc('xtick', labelsize=BIGGER_SIZE)    # fontsize of the tick labels
plt.rc('ytick', labelsize=BIGGER_SIZE)    # fontsize of the tick labels
plt.rc('legend', fontsize=BIGGER_SIZE)

def lineplot_files(fnames, xlabels,  yaxis):

    color = cm.inferno(np.linspace(0.1, 0.4, len(fnames)))

    nfiles = len(fnames)

    data_means = []
    data_stds  = []
    data_pos   = np.arange(nfiles)

    for i in range(0,nfiles):
        temp_data = np.loadtxt("data/task-creations/" + fnames[i])
        temp_mean = st.hmean(temp_data)
        temp_std  = np.std(temp_data) 

        data_means.append(temp_mean)
        data_stds.append(temp_std)

    ax, fig = plt.subplots(1, figsize=(3.5,6))
    ax = plt.bar(data_pos, data_means, yerr=data_stds, align='edge',capsize=10, width=0.2, color=color)

    plt.xticks(data_pos, xlabels, rotation=30)
    plt.ylabel(yaxis)
    plt.yscale('log')

    # Save figure
    plt.tight_layout()
    plt.savefig("task_create_tput.pdf")


tasknames  = [x + "_task_create_tput.dat" for x in ['c', 'julia']]
y_axis_title = "Creations per second"

lineplot_files(tasknames, ["C [pthread]",  "Julia [native Task()]"],  y_axis_title)
