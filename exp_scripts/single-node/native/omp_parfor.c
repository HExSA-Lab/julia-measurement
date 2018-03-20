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
measure_omp_parfor (unsigned throwout, 
                    unsigned trials, 
                    unsigned size)
{
    int * a = NULL;
    struct timespec start;
    struct timespec end;
    int i;

    a = malloc(size*sizeof(int));

	if (a == NULL) {
		fprintf(stderr, "Could not allocate test array\n");
		exit(EXIT_FAILURE);
	}
	
	memset(a, 0, size*sizeof(int));

    for (i = 0; i < throwout + trials; i++) {

		clock_gettime(CLOCK_REALTIME, &start);
                       
		#pragma omp parallel for
		for(int i = 0; i < size ; i++) {
			a[i] = i;
		}

        clock_gettime(CLOCK_REALTIME, &end);

        long s_ns = start.tv_sec*1000000000 + start.tv_nsec;
        long e_ns = end.tv_sec*1000000000 + end.tv_nsec;

        if (i >= throwout) {
            printf("%lu\n", e_ns - s_ns);
        }

    }

    free(a);
}


static void
usage (char * prog)
{
    printf("Usage: %s [options]\n", prog);
    printf("\nOptions:\n");

    printf("  -t, --trials <trial count> : number of experiments to run (default=%d)\n", DEFAULT_TRIALS);
    printf("  -k, --throwout <throwout count> : number of iterations to throw away (default=%d)\n", DEFAULT_THROWOUT);
    printf("  -s, --size <array size> : size of the array (in integers) to use (default=%d)\n", DEFAULT_SIZE);
    printf("  -h, ---help : display this message\n");
    printf("  -v, --version : display the version number and exit\n");

    printf("\n");
}


static void
version ()
{
    printf("omp parallel for measurement code (HExSA Lab 2018)\n");
    printf("version %s\n\n", VERSION_STRING);
}


int 
main (int argc, char ** argv)
{
    unsigned trials   = DEFAULT_TRIALS;
    unsigned throwout = DEFAULT_THROWOUT;
	unsigned size     = DEFAULT_SIZE;
    int c;

    while (1) {

        int optidx = 0;

        static struct option lopts[] = {
            {"trials", required_argument, 0, 't'},
            {"throwout", required_argument, 0, 'k'},
			{"size", required_argument, 0, 's'},
            {"help", no_argument, 0, 'h'},
            {"version", no_argument, 0, 'v'},
            {0, 0, 0, 0}
        };

        c = getopt_long(argc, argv, "t:k:s:hv", lopts, &optidx);

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
            case 's':
                size = atoi(optarg);
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
	
    printf("# omp parallel for experiment config:\n");
    printf("# Clocksource = clock_gettime(CLOCK_REALTIME)\n");
    printf("# Output is in ns\n");
    printf("# %d trials\n", trials);
    printf("# %d throwout\n", throwout);
    printf("# %d array size\n", size);

	measure_omp_parfor(throwout, trials, size);
}

