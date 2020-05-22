import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
def main():
    df1 = pd.read_csv('bsp_out')
    df = df1.sort_values(by=['procs', 'lang'])
    print(df)
    dict = {}
    class key:
        def __init__(self, lang, procs):
            self.lang = lang
            self.procs = procs
            # self.op = op
        def __hash__(self):
            return hash((self.lang, self.procs))
        def __eq__(self, other):
            return (self.lang, self.procs) == (other.lang, other.procs)
    for index, row in df.iterrows():
        lang = row['lang']
        procs = row['procs']
        k = key(lang, procs)
        if k in dict.keys():
            dict[k].append(row['median'])
        else:
            dict[k] = [row['median']]
    # checking keys (bar labels)
    barXticks = []
    barTopLabels = []
    p = []
    for k, v in dict.items():
        # print(key[lang],"=",k)
        barXticks.append(k.lang+str(k.procs))
        barTopLabels.append(k.lang)
        p.append(v)
    numLabels = len(barXticks)
    pNP = np.asarray(p)
    x = np.arange(pNP.shape[0])
    barPositions = []
    pos = -4
    for i in range(numLabels):
        if i % 2 == 0:
            pos += 4
            barPositions.append(pos)
        else:
            pos += 2
            barPositions.append(pos)
    print(f'bar positions are {barPositions}')
    fig, ax = plt.subplots()
    for i in range(pNP.shape[1]):
        bottom = np.sum(pNP[:, 0:i], axis=1)
        b= ax.bar(barPositions, pNP[:, i], bottom=bottom, label="label {}".format(i))

    ax.set_yscale('log')
    plt.ylabel('Latency')
    plt.title('Processes Per Node')
    # plt.xlabel(barTopLabels)
    # plt.legend((p1[0], p2[0], p3[0], p4[0])), ('comms', 'flops', 'reads', 'writes'))
    plt.legend(framealpha=1).draggable()
    plt.show()
if __name__ == "__main__":
    main()
