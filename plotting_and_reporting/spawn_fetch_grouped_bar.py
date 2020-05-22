import matplotlib as mpl
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
from matplotlib import cm

barwidth = 0.1


# make hatches less annoyingly thick
mpl.rcParams['hatch.linewidth'] = 0.25

# er
mpl.rcParams["errorbar.capsize"] = 2

df = pd.read_csv('spawn_fetch_new_out.csv', comment='#')

procs      = df.proc.unique()
task_sizes = df.leg_obj.unique()



medians       = {}
stddevs       = {}
bar_positions = {}

pos_base = np.arange(len(procs))
color = cm.inferno(np.linspace(0.1, 0.9, len(task_sizes)))

for i, t in enumerate(task_sizes):
    medians[t]       = df[df.leg_obj == t]['median'].values
    stddevs[t]       = df[df.leg_obj == t]['err'].values
    bar_positions[t] = [x + i*barwidth for x in pos_base]


f, ax = plt.subplots(1, figsize=(10,8))

hatches = ['/', '.', '+' , '*', 'o', '#', '-', 'O']

for i,t in enumerate(task_sizes):
    ax.bar(bar_positions[t], medians[t], label=t, hatch=3*hatches[i], width=barwidth, yerr=stddevs[t], color=color[i], edgecolor='black', linewidth=0.25)

ax.set_xticks([r + (barwidth*len(task_sizes)/2) - barwidth/2 for r in range(len(procs))])
ax.set_xticklabels(procs, size='large')
ax.set_xlabel("Processes", fontsize=14)
ax.set_ylabel("Execution time (ns)", fontsize=14)
ax.legend(loc='best', fontsize='large')
ax.grid(axis='y', zorder=-1, alpha=0.5)
ax.set_axisbelow(True)
plt.tight_layout()
plt.savefig("spawn-fetch.pdf")



