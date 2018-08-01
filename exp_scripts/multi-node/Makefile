CC:=gcc
MPICC:=mpicc
CFLAGS:=-O2 -Wall

all: bsp_mpi

bsp_mpi: bsp_mpi.c
	$(MPICC) $(CFLAGS) -o $! $< 

clean:
	@rm -f bsp_mpi

.PHONY: clean
