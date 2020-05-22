#!/usr/bin/python3

""" BSP Plot: Plot results from HPCG experiments

Usage:
    stacked_barplot.py [options] 

Options:
    -h --help            Show this screen
    -V --version         Show version
    -i --input=<file>    Input file (defaults to stdin)
    -o --output=<file>   Output file [default: plot.pdf]
    -t --type=<type>     Measurement to plot [default: total-time]

"""

import pandas as pd
import matplotlib.pyplot as plt
from docopt import docopt
import sys


# KCH: Use this one as a template. Add a dispatch line in main as well
def plot_bsp(output, df):

    print("Producing figure for bsp")
    plt.title("BSP Experiment [14 nodes]")
    plt.xlabel("Processes on each node")
    plt.ylabel("Running Time (ns)")

    for i, row in df.iterrows():
        if row['lang'] == 'julia':
            df.loc[i,'median'] = df.loc[i,'median']
    df2 = df.groupby(['procs', 'lang']).size().unstack().plot(kind='bar',stacked=True)
    b = df2[['op' , 'median']]
    
"""
    for i, row in df.iterrows():
        if row['lang'] == 'julia':
            df.loc[i,'total-time'] = df.loc[i,'total-time']

    # take a slice with only the Index column (procs), the series column (language), 
    # and the values (total-time)
    b = df[['lang', 'procs',  'op', 'median']]

    # we have to pivot it so that total-procs is the index before plotting it
    ax = b.pivot(index='total-procs', columns='lang', values='total-time').plot.bar(rot=0)

    ax.set_title("HPCG Experiment [Running time] (14 nodes)")
    ax.set_ylabel("Execution time (s)")
    ax.set_xlabel("Total number of MPI Ranks")
    plt.axis('tight')
    plt.tight_layout()
    print(f"OK: output graph saved in: {output}")
    plt.savefig(output)
"""



if __name__ ==  '__main__':

    args = docopt(__doc__, version='BSPPlot 0.1 (c) Amal Rizvi')

    output  = args['--output']
    exptype = args['--type']
    infile  = sys.stdin

    if args['--input']:
        infile = args['--input']

    frame = pd.read_csv(infile)

    frame.set_index('procs')

    plot_bsp(output, frame)
