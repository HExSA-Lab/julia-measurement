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


static void 
measure_timing (unsigned throwout, unsigned trials)
{
    struct timespec start;
    struct timespec end;
    int i;

    for (i = 0; i < throwout + trials; i++) {

        clock_gettime(CLOCK_REALTIME, &start);
        clock_gettime(CLOCK_REALTIME, &end);

        long s_ns = start.tv_sec*1000000000 + start.tv_nsec;
        long e_ns = end.tv_sec*1000000000 + end.tv_nsec;

        if (i >= throwout) {
            printf("%lu\n", e_ns - s_ns);
        }
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
    printf("\n");
}


static void
version ()
{
    printf("C timer calibration code (HExSA Lab 2018)\n");
    printf("version %s\n\n", VERSION_STRING);
}


int 
main (int argc, char ** argv)
{
    unsigned trials   = DEFAULT_TRIALS;
    unsigned throwout = DEFAULT_THROWOUT;

    int c;

    while (1) {

        int optidx = 0;

        static struct option lopts[] = {
            {"trials", required_argument, 0, 't'},
            {"throwout", required_argument, 0, 'k'},
            {"help", no_argument, 0, 'h'},
            {"version", no_argument, 0, 'v'},
            {0, 0, 0, 0}
        };

        c = getopt_long(argc, argv, "t:k:hv", lopts, &optidx);

        if (c == -1) {
            break;
        }


        switch (c) {
            case 't':
                trials = atoi(optarg);
                break;
            case 'k':
                throwout = atoi(optarg);
                break;
            case 'h':
                usage(argv[0]);
                exit(EXIT_SUCCESS);
            case 'v':
                version();
                exit(EXIT_SUCCESS);
            case '?':
                break;
            default:
                printf("?? getopt returned character code 0%o ??\n", c);
        }
    }

    printf("# C timer calibration experiment config:\n");
    printf("# Clocksource = clock_gettime(CLOCK_REALTIME)\n");
    printf("# Output is in ns\n");
    printf("# %d trials\n", trials);
    printf("# %d throwout\n", throwout);

    measure_timing(throwout, trials);

    return 0;
}
