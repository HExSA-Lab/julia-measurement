import matplotlib.pyplot as plt
import numpy as np
import os
import sys
from scipy import stats

# Fontsize
SMALL_SIZE  = 10
MEDIUM_SIZE = 12
BIGGER_SIZE = 18

plt.rc('font',   size=BIGGER_SIZE) # controls default text sizes
plt.rc('axes',   titlesize=BIGGER_SIZE) # fontsize of the axes title
plt.rc('axes',   labelsize=BIGGER_SIZE) # fontsize of the x and y labels
plt.rc('xtick',  labelsize=BIGGER_SIZE) # fontsize of the tick labels
plt.rc('ytick',  labelsize=BIGGER_SIZE) # fontsize of the tick labels
plt.rc('legend', fontsize=BIGGER_SIZE)


def plot_pingpong_lineplot(xpos, dir, lang, lab, ls, marker, tp='lat'):

    stddev    = {}
    statistic = {}

    for fname in os.listdir(dir):
        basename, ext = os.path.splitext(fname)
        if ext != ".dat":
            continue

        junk1, junk2, language, msglen = basename.split('_')

        if lang != language:
            continue

        data = np.loadtxt(f"{dir}/{fname}")

        # outlier removal (Tukey, 1.5 param)
        d_25 = np.quantile(data, 0.25)
        iqr = stats.iqr(data)
        d_75 = np.quantile(data, 0.75)
        lower = d_25 - 1.5*iqr
        upper = d_75 + 1.5*iqr
        cdata = np.array([x for x in data if x > lower and x < upper])

        ml = int(msglen)

        if tp == 'lat':
            statistic[ml] = np.mean(cdata)/1e6 # convert to ms
            stddev[ml] = np.std(cdata)/1e6# stddev is in same units as data
        elif tp == 'tput':
            statistic[ml] = stats.hmean(2*ml/cdata) * 1e9# B/s
            stddev[ml] = np.std(2*ml/cdata) * 1e9
        else:
            print(f"Unknown measure: {tp}")
            exit()

    ys   = [float(statistic[k]) for k in sorted(statistic.keys())]
    stds = [float(stddev[k]) for k in sorted(stddev.keys())]

    plt.errorbar(xpos, ys, yerr=stds, xerr=None, label=lab, linestyle=ls, marker=marker)
    plt.legend(loc='best')



ax, fig = plt.subplots(1, figsize=(10,8))
XLABEL = "Message Size"

xlabels = ["8B", "16B", "32B", "64B", "128B", "256B", "512B", "1KB","2KB", "4KB","8KB", "16KB", "32KB","64KB", "128KB", "256KB", "512KB", "1MB"]
xpos    = np.arange(1, len(xlabels)+1, 1)

# Latency plot
plt.subplot(211)
plt.xticks(xpos, xlabels, rotation=30)
plt.xlabel(XLABEL)
plt.ylabel("Latency (ms)")

plot_pingpong_lineplot(xpos, "raw_dat_files", "c", 'C+MPI', '-', 'None', 'lat')
plot_pingpong_lineplot(xpos, "raw_dat_files", "julia", 'Julia+MPI', '-.', 'o', 'lat')
plot_pingpong_lineplot(xpos, "raw_dat_files_opt", "julia", 'Julia+MPI (opt)', '--', 'x', 'lat')

# Throughput plot
plt.subplot(212)
plt.xticks(xpos, xlabels, rotation=30)
plt.xlabel(XLABEL)
plt.ylabel("Throughput (Bytes/s)")

plot_pingpong_lineplot(xpos, "raw_dat_files", "c", 'C+MPI', '-', 'None', 'tput')
plot_pingpong_lineplot(xpos, "raw_dat_files", "julia", 'Julia+MPI', '-.', 'o', 'tput')
plot_pingpong_lineplot(xpos, "raw_dat_files_opt", "julia", 'Julia+MPI (opt)', '--', 'x', 'tput')

plt.tight_layout()
plt.savefig("pingpong.pdf")

