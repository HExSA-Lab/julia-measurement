from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pyplot as plt
from matplotlib import cm
from matplotlib.ticker import LinearLocator, FormatStrFormatter
import numpy as np
import sys
'''
surface_plot plots a surface plot from a 2D data file
FOR NOW: This is specifically for spawn/fecth measurements
with increasing workload 
    @params
    @filename :name of data file
once done function is called. Plot can be checked and saved.
NOTE:
matplotlib will not plot unless 
some display is available.
ssh into machine with XQuartz ssh -Y username@server.address.edu
run command: python -c 'from surface_python import surface_plot;
surface_plot(filename)'
'''
def surface_plot(filename): 
    data = []

    values = open(filename, "r")
    for line in values:
        number_strings = line.split()
        numbers = [float(n) for n in number_strings]
        data.append(numbers)
    fig = plt.figure()
    ax = fig.gca(projection='3d')
    rows = len(data)
    cols = len(data[0])
    print(rows)
    print(cols)
    X1 = np.arange(1,rows+1,1)
    Y1 = np.arange(1,cols+1,1)
    Y2 = [1,2,4,8,16]
    Z = data

    X, Y = np.meshgrid(Y1,X1)
    print(np.shape(X))
    print(np.shape(Y))
    print("and")
    print(np.shape(Z))
    surf  = ax.plot_surface(X,Y,Z,cmap=cm.coolwarm,
        linewidth=0, antialiased=False)
    plt.xticks(Y1, Y2)
    ax.set_ylabel("task granularity")
    ax.set_xlabel("processes")
    ax.set_zlabel("latencies")
    # Customize the z axis.
    #ax.zaxis.set_major_locator(LinearLocator(10))
    #ax.izaxis.set_major_formatter(FormatStrFormatter('%.02f'))

    # Add a color bar which maps values to colors.
    fig.colorbar(surf, shrink=0.5, aspect=5)

    plt.show()

surface_plot("spawn_trial.dat")
surface_plot("spawn_triali1.dat")


