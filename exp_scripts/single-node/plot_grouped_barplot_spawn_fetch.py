import matplotlib
import numpy as np
import pandas as pd
from matplotlib import cm

matplotlib.use("TkAgg")  # Do this before importing pyplot!
import matplotlib.pyplot as plt


# Font Size

SMALL_SIZE  = 11
MEDIUM_SIZE = 12
BIGGER_SIZE = 14
plt.rc('font', size=MEDIUM_SIZE)          # controls default text sizes
plt.rc('axes', titlesize=MEDIUM_SIZE)     # fontsize of the axes title
plt.rc('axes', labelsize=MEDIUM_SIZE)     # fontsize of the x and y labels
plt.rc('xtick', labelsize=MEDIUM_SIZE)    # fontsize of the tick labels
plt.rc('ytick', labelsize=MEDIUM_SIZE)    # fontsize of the tick labels
plt.rc('legend', fontsize=SMALL_SIZE)

# Colors for bars Palette warm

color = cm.coolwarm(np.linspace(0.1,0.9,7))


# Read csv

df1 = pd.read_csv('spawn_fetch_out.csv')

# Pivot for clustered bar plot

df1.set_index('proc')
b = df1[['leg_obj', 'median', 'proc']]
ax = b.pivot(index='proc', columns='leg_obj', values='median').plot.bar(rot=0, width=0.7, color=color)


#Labels

plt.xlabel("Processes")
plt.ylabel("Latencies(ns)")

# Hatches

bars = ax.patches
hatches = ['/////','/////','/////','/////','.....','.....','.....','.....', '++++', '++++','++++','++++','-----','-----','-----','-----',\
           'xxxxx','xxxxx','xxxxx','xxxxx', '','','','', 'OOOOO', 'OOOOO','OOOOO','OOOOO']
for bar, hatch in zip(bars, hatches):
    bar.set_hatch(hatch)

# Legend

plt.legend(title="")


# Save Figure

plt.savefig("spawn_fetch_grouped_bar.pdf")
