CC:=gcc
MPICC:=mpicc
CFLAGS:=-O2 -Wall

all: bsp_mpi

bsp_mpi: bsp_mpi.c
	$(MPICC) $(CFLAGS) -o $! $< 

run:
	@./test_all.sh

clean:
	@rm -f bsp_mpi

.PHONY: clean run
