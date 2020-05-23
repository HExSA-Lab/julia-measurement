import matplotlib.pyplot as plt
import numpy as np


def plot_lineplot(files, xaxis, xlabel, ylabel1, ylabel2):

    # Fontsize

    SMALL_SIZE = 10
    MEDIUM_SIZE = 12
    BIGGER_SIZE = 14
    plt.rc('font', size=MEDIUM_SIZE) # controls default text sizes
    plt.rc('axes', titlesize=MEDIUM_SIZE) # fontsize of the axes title
    plt.rc('axes', labelsize=MEDIUM_SIZE) # fontsize of the x and y labels
    plt.rc('xtick', labelsize=MEDIUM_SIZE) # fontsize of the tick labels
    plt.rc('ytick', labelsize=MEDIUM_SIZE) # fontsize of the tick labels
    plt.rc('legend', fontsize=MEDIUM_SIZE)

    # Read data from files

    nfiles = len(files)
    all_data = []

    for i in range(0, nfiles):
        temp_data = np.loadtxt(files[i])
        all_data.append(temp_data)

    # Xticks position on both plots

    points = np.arange(1, 19, 1)

    # Top plot

    plt.subplot(211)

    # Plot both lines one by one with different markers and labels

    plt.plot(points, all_data[0], 'r--', label="C/MPI")
    plt.plot(points, all_data[1], '-', label="Julia/MPI")

    # Xaxis and yaxis and their labels

    plt.xticks(points, xaxis)
    plt.xlabel(xlabel)
    plt.ylabel(ylabel1)

    # Legend and layout

    plt.legend(loc=0)
    plt.tight_layout()

    # Bottom Plot

    ax2 = plt.subplot(212)

    # Plot both lines one by one with different markers and labels

    plt.plot(points, all_data[2], 'r--', label="C/MPI")
    plt.plot(points, all_data[3], '-', label="Julia/MPI")

    # Xaxis and yaxis and their labels

    plt.xticks(points, xaxis)
    plt.xlabel(xlabel)
    plt.ylabel(ylabel2)

    # Legend and layout

    plt.legend(loc=0)
    plt.tight_layout()

    # Save figure

    plt.savefig("pp.pdf")



xaxis= ["8B", "16B", "32B", "64B", "128B", "256B", "512B", "1KB","2KB", "4KB","8KB", "16KB", "32KB","64KB", "128KB", "256KB", "512KB", "1MB"]


files = ["c_pp_means.dat", "julia_pp_means.dat", "c_pp_tput.dat", "julia_pp_tput.dat"]
plot_lineplot(files, xaxis, "message size", "latencies(in ns)", "throughput(in bytes/ns)")
