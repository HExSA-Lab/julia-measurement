#define _GNU_SOURCE
#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <time.h>
#include <unistd.h>
#include <sched.h>
#include <pthread.h>
#include <getopt.h>
#include <string.h>

#include "common.h"

#define VERSION_STRING "0.0.1"

#define MAX_THREADS 64

#define DEFAULT_TRIALS 100
#define DEFAULT_THROWOUT 10
#define DEFAULT_SIZE 50000000
#define DEFAULT_THREADS 2


typedef struct thr_bounds {
    int * start;
    size_t count;
    int start_idx;
} thr_bounds_t;


static void*
worker (void * in)
{
    thr_bounds_t * bounds = (thr_bounds_t*)in;
    int i;

    for (i = 0; i < bounds->count; i++) {
        bounds->start[i] = bounds->start_idx + i;
    }

    return NULL;
}


/* 
 * note that nthreads should be less than the 
 * number of cores in the system
 *
 */
static void
measure_thread_parallel (unsigned throwout, 
						 unsigned trials, 
						 unsigned size,
                         unsigned nthreads)
{
    pthread_t t[MAX_THREADS]; 
    thr_bounds_t b[MAX_THREADS]; // args to threads
	int * a = NULL;
    struct timespec start;
    struct timespec end;
    int i, j;

    if (nthreads > MAX_THREADS) {
        fprintf(stderr, "Too many threads (max=%d)\n", MAX_THREADS);
        exit(EXIT_FAILURE);
    }
	
	a = malloc(size*sizeof(int));

	if  (a == NULL) {
		fprintf(stderr, "Could not allocate test array");
		exit(EXIT_FAILURE);
	}	
		
	memset(a, 0, size*sizeof(int));

    for (i = 0; i < throwout + trials; i++) {

        clock_gettime(CLOCK_REALTIME, &start);

        unsigned size_per_thread = size/nthreads;
        int extra = size % nthreads != 0;

        for (j = 0; j < nthreads; j++) {
		
            /* last guy gets the leftovers (this is a naive, unbalanced allocation) */
            b[j].count = (extra && j == nthreads-1) ? 
                (size_per_thread + (size % nthreads)) : 
                size_per_thread;

            b[j].start     = &a[size_per_thread * j];
            b[j].start_idx = size_per_thread * j;

            pthread_create(&t[j], NULL, worker, &b[j]);

        }
    
        /* wait for them to finish */
        for (j = 0; j < nthreads; j++) {
            pthread_join(t[j], NULL);
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
    printf("  -s, --size : size of array to set (default=%d)\n", DEFAULT_SIZE);
    printf("  -r, --threads : number of threads to split work among (default=%d)\n", DEFAULT_THREADS);
    printf("  -h, ---help : display this message\n");
    printf("  -v, --version : display the version number and exit\n");

    printf("\n");
}


static void
version ()
{
    printf("pthread parallel for measurement code (HExSA Lab 2018)\n");
    printf("version %s\n\n", VERSION_STRING);
}



int 
main (int argc, char ** argv)
{
    unsigned trials   = DEFAULT_TRIALS;
    unsigned throwout = DEFAULT_THROWOUT;
	unsigned size     = DEFAULT_SIZE;
    unsigned threads  = DEFAULT_THREADS;

    int c;

    while (1) {

        int optidx = 0;

        static struct option lopts[] = {
            {"trials", required_argument, 0, 't'},
            {"throwout", required_argument, 0, 'k'},
            {"size", required_argument, 0, 's'},
            {"threads", required_argument, 0, 'r'},
            {"help", no_argument, 0, 'h'},
            {"version", no_argument, 0, 'v'},
            {0, 0, 0, 0}
        };

        c = getopt_long(argc, argv, "t:k:s:r:hv", lopts, &optidx);

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
            case 'r':
                threads = atoi(optarg);
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

    printf("# pthread parallel experiment config:\n");
    printf("# Clocksource = clock_gettime(CLOCK_REALTIME)\n");
    printf("# Output is in ns\n");
    printf("# %d trials\n", trials);
    printf("# %d throwout\n", throwout);
    printf("# %d size\n", size);    
    printf("# %d threads\n", threads);

	measure_thread_parallel(throwout, trials, size, threads);

    return 0;
}
