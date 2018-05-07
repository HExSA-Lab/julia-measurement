CC:=gcc
LD:=ld
AR:=ar
CFLAGS:=-Wall -O2 
OMPCFLAGS:=-Wall -O2 -fopenmp
LDFLAGS:=-pthread


all: pt_ctx_switch \
	 pt_create \
	 pt_synch \
	 omp_parfor \
	 pt_parfor \
	 atomics \
	 cond \
	 channel \
	 timing

pt_synch: pt_synch.c common.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $<

pt_ctx_switch: pt_ctx_switch.c common.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $<

pt_create: pt_create.c common.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $<

pt_parfor: pt_parallel_for.c common.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $<

omp_parfor: omp_parfor.c common.h
	$(CC) $(OMPCFLAGS) $(LDFLAGS) -o $@ $<

atomics: atomics.c common.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $<

cond: cond.c common.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $<

channel.o: channel.c common.h pcq.h
	$(CC) $(CFLAGS) -Wno-unused-but-set-variable -c -o $@ channel.c

pcq.o: pcq.c pcq.h
	$(CC) $(CFLAGS) -c -o $@ pcq.c

channel: channel.o pcq.o
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ channel.o pcq.o

timing: timing.c
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $<


clean:
	@rm -f pt_ctx_switch pt_create pt_synch omp_parfor atomics cond channel timing *.o


.PHONY: clean
