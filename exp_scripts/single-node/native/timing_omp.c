#define _GNU_SOURCE
#include <stdlib.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <time.h>
#include <unistd.h>
#include <sched.h>
#include <pthread.h>
#include <getopt.h>
#include <string.h>
#include "omp.h"

#include "common.h"

#define VERSION_STRING "0.0.1"

#define DEFAULT_TRIALS   100
#define DEFAULT_THROWOUT 10
#define DEFAULT_SIZE     50000000


static void
measure_omp_timing (unsigned throwout, 
                    unsigned trials, 
{
    struct timespec start;
    struct timespec end;


    for (i = 0; i < throwout + trials; i++) {

	clock_gettime(CLOCK_REALTIME, &start);
        clock_gettime(CLOCK_REALTIME, &end);
	}
        long s_ns = start.tv_sec*1000000000 + start.tv_nsec;
        long e_ns = end.tv_sec*1000000000 + end.tv_nsec;

        if (i >= throwout) {
            printf("%lu\n", e_ns - s_ns);
        }



}


int 
main (int argc, char ** argv)
{
    unsigned trials =   DEFAULT_TRIALS;
    unsigned throwout = DEFAULT_THROWOUT;
    int exp_id =        DEFAULT_EXP;


   measure_omp_timing(10,100)
    // run the experiment

    return 0;
}
