import matplotlib
import numpy as np
import pandas as pd
matplotlib.use("TkAgg")  # Do this before importing pyplot!
import matplotlib.pyplot as plt


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

# Read from csv

df1 = pd.read_csv('bsp_out.csv')
df1.set_index('procs')
df2 = df1.groupby(['procs', 'lang']).sum().unstack()

# Plot

ax = df2.plot.bar(rot=0)

# Hatches

bars = ax.patches
hatches = ['/////','/////','/////','/////','/////','.....','.....','.....','.....','.....']
for bar, hatch in zip(bars, hatches):
    bar.set_hatch(hatch)

# Legend

ax.legend(["CPP", "Julia"])

# Label

plt.xlabel('Ranks Per Node')
plt.ylabel('Latencies(s)')


#Show Figure

plt.show()

# Save Figure

plt.savefig("bsp_execution_time.pdf")
