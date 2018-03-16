
CC:=gcc
LD:=ld
AR:=ar
CFLAGS:=-Wall -O2 -pthread
LDFLAGS:=
OMPCFLAGS:=-Wall -O2 -fopenmp


all: pt_ctx_switch pt_create pt_synch omp_parfor

pt_synch: pt_synch.c common.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $<

pt_ctx_switch: pt_ctx_switch.c common.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $<

pt_create: pt_create.c common.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $<

omp_parfor: omp_parfor.c common.h
	$(CC) $(OMPCFLAGS) $(LDFLAGS) -o $@ $<

clean:
	@rm -f pt_ctx_switch pt_create pt_synch omp_parfor *.o


.PHONY: clean
