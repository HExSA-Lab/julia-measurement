
CC:=gcc
LD:=ld
AR:=ar
CFLAGS:=-Wall -O2 -pthread
LDFLAGS:=
OMPCFLAGS:=-Wall -O2 -fopenmp


all: pt_ctx_switch pt_create omp_parfor


pt_ctx_switch: pt_ctx_switch.c common.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $<

pt_create: pt_create.c common.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $<

omp_parfor: omp_parfor.c common.h
	$(CC) $(OMPCFLAGS) $(LDFLAGS) -o $@ $<

clean:
	@rm -f pt_ctx_switch pt_create omp_parfor *.o


.PHONY: clean
