#define _GNU_SOURCE
#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <time.h>
#include <unistd.h>
#include <sched.h>
#include <pthread.h>
#include <getopt.h>

#include "common.h"

#define VERSION_STRING "0.0.1"

#define DEFAULT_TRIALS 100
#define DEFAULT_THROWOUT 10



static void*
thread_create_func (void * in)
{
    return NULL;
}


/*
 *
 * Measures the latency for a call to pthread_create(). Note that this does not
 * actually measure the end-to-end creation latency, i.e. the time it takes for
 * the thread to actually start *running*. This only will really account for
 * the creation of the appropriate scheduler structures, stack allocation, and
 * the clone() invocation.
 *
 */
static void
measure_thread_create (unsigned throwout, unsigned trials)
{
    pthread_t t;
    struct timespec start;
    struct timespec end;
    int i;

    for (i = 0; i < throwout + trials; i++) {

        cpu_set_t cpuset;
        pthread_attr_t attr;
        CPU_ZERO(&cpuset);
        CPU_SET(1, &cpuset);
        pthread_attr_init(&attr);

        // pin it to another core
        pthread_attr_setaffinity_np(&attr, sizeof(cpuset), &cpuset);

        clock_gettime(CLOCK_REALTIME, &start);

        pthread_create(&t, &attr, thread_create_func, NULL);

        clock_gettime(CLOCK_REALTIME, &end);

        long s_ns = start.tv_sec*1000000000 + start.tv_nsec;
        long e_ns = end.tv_sec*1000000000 + end.tv_nsec;

        if (i >= throwout) {
            printf("%lu\n", e_ns - s_ns);
        }

        usleep(100);

        pthread_join(t, NULL);

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
    printf("pthread create measurement code (HExSA Lab 2018)\n");
    printf("version %s\n\n", VERSION_STRING);
}


int 
main (int argc, char ** argv)
{
    unsigned trials = DEFAULT_TRIALS;
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

    printf("# pthread create experiment config:\n");
    printf("# Clocksource = clock_gettime(CLOCK_REALTIME)\n");
    printf("# Output is in ns\n");
    printf("# %d trials\n", trials);
    printf("# %d throwout\n", throwout);

    measure_thread_create(throwout, trials);
    
    return 0;
}


