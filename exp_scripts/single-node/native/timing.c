#define _GNU_SOURCE

#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <time.h>
#include <unistd.h>
#include <getopt.h>

#include "common.h"

#define VERSION_STRING "0.0.1"

#define DEFAULT_TRIALS    100
#define DEFAULT_THROWOUT  10
#define DEFAULT_EXP       SET

#define ARGTYPE_TO_ENUM(x) ((x) - 10)


static void 
measure_timing (unsigned throwout, unsigned trials)
{
    struct timespec start;
    struct timespec end;
    int i;
    int a;
    int val = 1;

    for (i = 0; i < throwout + trials; i++) {


        clock_gettime(CLOCK_REALTIME, &start);


        clock_gettime(CLOCK_REALTIME, &end);

        long s_ns = start.tv_sec*1000000000 + start.tv_nsec;
        long e_ns = end.tv_sec*1000000000 + end.tv_nsec;
        if (i >= throwout) {
            printf("%lu\n", e_ns - s_ns);
        }
}


static void
usage (char * prog)
{
    printf("Usage: %s [options]\n", prog);
    printf("\nOptions:\n");

    printf("  -t, --trials <trial count> : number of experiments to run (default=%d)\n", DEFAULT_TRIALS);
    printf("  -k, --throwout <throwout count> : number of iterations to throw away (default=%d)\n", DEFAULT_THROWOUT);
    printf("  -h, ---help : display this message\n");
    printf("  -v, --version : display the version number and exit\n");

}


static void
version ()
{
    printf("pthreads timing measurement code (HExSA Lab 2018)\n");
    printf("version %s\n\n", VERSION_STRING);
}

int 
main (int argc, char ** argv)
{
    unsigned trials =   DEFAULT_TRIALS;
    unsigned throwout = DEFAULT_THROWOUT;
    int exp_id =        DEFAULT_EXP;


   measure_timing(10,100)
    // run the experiment

    return 0;
}
