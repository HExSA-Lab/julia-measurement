# docopt string for experiment driver cli

doc = """Julia BSP experiment driver.

Usage: bsp_julia.jl [options]

Options:
  -n <nprocs>, --nprocs <nprocs>    Number of processes to use (ignored on MPI version) [default: 1]
  -i <iters>, --iterations <iters>  Number of iterations [default: 10]
  -e <elms>, --elements <elms>      Number of elements in array [default: 10]
  -f <flops>, --flops <flops>       Number of floating point operations [default: 1000000]
  -r <reads>, --reads <reads>       Number of reads [default: 5000]
  -w <writes>, --writes <writes>    Number of writes [default: 5000]
  -c <comms>, --comms <comms>       Number of communications [default: 100]   -h, --help                       Show this message and exit
  -v, --version                     Show the version number


"""

