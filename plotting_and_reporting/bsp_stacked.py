import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import itertools as it
from cycler import cycler
import logging 
import os
import sys


logging.basicConfig(level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')

CACHEFILE=".expframe.cached.h5"

# This generates a clustered, stacked bar for two sets of scaling
# experiments.
# Command-line arguments:
#  (1) the path to the .dat files
#  (2) the name of the output file
# 
# The first run of this script will take a while, as it's not particularly efficient.
# However, subsequent runs will use a cached hdf5 dataframe, making things faster (at least
# if you're not rerunning the experiment often)
#
# KCH NOTE: This code assumes the following:
# * There are two and only two comparison points (here C and Julia mislabeled 'mpi')
# * .dat files are of the form OP_LANG_PROCCOUNT.dat


class ExperimentFrame:

    langs       = []
    ops         = []
    proc_counts = []

    # Find which languages, operations, and proc counts
    def discover_params(self):

        for fname in os.listdir(self.dat_dir):
            basename, ext = os.path.splitext(fname)

            # only count the .dat files
            if not ext == ".dat":
                continue

            op, lang, proc_count = basename.split('_')

            if op not in self.ops:
                self.ops.append(op)
            if lang not in self.langs:
                self.langs.append(lang)
            if proc_count not in self.proc_counts:
                self.proc_counts.append(proc_count)


    # Is this even a valid experiment combination?
    def check_cfg(self, lang, proc_count):
        if lang not in self.langs or proc_count not in self.proc_counts:
            logging.error(f"No such experimental configuration {lang}:{proc_count}")
            return False
        return True

    def check_cfg_with_op(self, lang, proc_count, op):
        if lang not in self.langs or proc_count not in self.proc_counts or op not in self.ops:
            logging.error(f"No such experimental configuration {lang}:{proc_count}")
            return False
        return True


    # Return the mean of all measurements of a particular operation for a
    # particular language/proc_count experiment. This will correspond to the
    # mean of recorded values in one .dat file
    def op_mean(self, lang, proc_count, op):
        self.check_cfg_with_op(lang, proc_count, op)
        rows = self.df.loc[(self.df['op'] == op) & (self.df['lang'] == lang) & (self.df['proc_count'] == proc_count)]
        return np.mean(rows['measurement'].values)


    # Return the number of trials for a given experimental configuration
    def op_trials(self, lang, proc_count, op):
        self.check_cfg_with_op(lang, proc_count, op)
        rows = self.df.loc[(self.df['lang'] == lang) & (self.df['proc_count'] == proc_count) & (self.df['op'] == op)]
        return rows.shape[0]


    # The total of an experiment is calculated as the sum of the means of all ops
    # for that experimental configuration
    def exp_total(self, lang, proc_count):
        total = 0
        for op in self.ops:
            total += self.op_mean(lang, proc_count, op)
        return total


    def __init__(self, path=os.getcwd()):

        self.dat_dir = path

        self.discover_params()

        logging.debug("Languages: {}".format(self.langs))
        logging.debug("Operations: {}".format(self.ops))
        logging.debug("Process Counts: {}".format(self.proc_counts))

        # Processing this into a DataFrame takes some time, so we cache the
        # generated frame in a CSV file
        if not os.path.exists(f"{self.dat_dir}/{CACHEFILE}"):

            logging.debug("No cached DataFrame found, processing .dat files")

            self.df = pd.DataFrame(data = {'op': [], 'lang': [], 'proc_count': [], 'measurement-num': [], 'measurement': []})

            i = 0

            for cnt in sorted(self.proc_counts):
                for lang in sorted(self.langs):
                    for op in sorted(self.ops):
                        # Note this assumes a specific file naming convention...
                        logging.debug(f"Processing {lang}:{op}:{cnt}")
                        with open(f"{self.dat_dir}/{op}_{lang}_{cnt}.dat", "r") as f:
                            for j, line in enumerate(f.readlines()):
                                row = pd.Series(data=[op, lang, cnt, j, int(line)], index=self.df.columns, name=i)
                                self.df = self.df.append(row)
                                i += 1


            self.df.to_hdf(f"{self.dat_dir}/{CACHEFILE}", key='df', mode='w')

        else:
            logging.debug(f"Discovered cached DataFrame {self.dat_dir}/{CACHEFILE} (delete it to generate new results)")
            self.df = pd.read_hdf(f"{self.dat_dir}/{CACHEFILE}", key='df')


    # Sources
    # * https://stackoverflow.com/a/43567145
    # * https://python-graph-gallery.com/11-grouped-barplot/
    # * https://gist.github.com/ctokheim/6435202a1a880cfecd71
    def plot_stacked(self, barwidth=0.25, of=None):

        cm    = plt.get_cmap('nipy_spectral')
        f, ax = plt.subplots(1, figsize=(10,8))

        # Set up the color map 
        ax.set_prop_cycle(cycler('color', [cm(1.*i/(2*len(self.ops))) for i in range(len(self.ops)*2)]))

        # we have one cluster of bars for each proc count
        bars  = self.proc_counts
        bar_l = range(len(bars))

        # these should not be hard-coded, ideally passed in via command-line as list
        seriesa = {'comms': [], 'flops': [], 'reads': [], 'writes': []}
        seriesb = {'comms': [], 'flops': [], 'reads': [], 'writes': []}

        # bar X coords on the graph. The second set is just offset from the first bars by the bar width
        pos1 = np.arange(len(bars))
        pos2 = [x + barwidth for x in pos1]

        # These are the y coords for the bottoms of each component of a bar stack.
        # We'll update them as we go
        bottoma = np.zeros_like(bar_l).astype('float')
        bottomb = np.zeros_like(bar_l).astype('float')

        for c in self.proc_counts:
            for op in self.ops:
                meana  = self.op_mean('c', c, op)
                totala = self.exp_total('c', c)
                seriesa[op].append(meana/totala)
                meanb  = self.op_mean('mpi', c, op)
                totalb = self.exp_total('mpi', c)
                seriesb[op].append(meanb/totalb)

        for op in self.ops:
            ax.bar(pos1, seriesa[op], bottom=bottoma, label=f"{op}-C", width=barwidth, edgecolor='white')
            # "MPI" actually means "Julia" I believe
            ax.bar(pos2, seriesb[op], bottom=bottomb, label=f"{op}-Julia", width=barwidth, edgecolor='white')
            bottoma += seriesa[op]
            bottomb += seriesb[op]

        ax.set_xticks([r + barwidth for r in range(len(bars))])
        ax.set_xticklabels(self.proc_counts, rotation=45, size='medium')
        ax.set_xlabel("Total MPI Ranks", fontsize=12)
        ax.set_ylabel("Execution Time Breakdown", fontsize=12)

        ax.legend(loc="best", bbox_to_anchor=(1,1), ncol=1, fontsize='medium')
        #f.subplots_adjust(right=0.5, bottom=0.4)

        if of is None:
            plt.show()
        else:
            f.savefig(of)


dat_path    = sys.argv[1]
output_file = sys.argv[2]

ef = ExperimentFrame(dat_path)
ef.plot_stacked(of=output_file)
