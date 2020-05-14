#define _GNU_SOURCE
#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <sched.h>
#include <pthread.h>
#include <getopt.h>

#include "common.h"

#define VERSION_STRING "0.0.1"

#define DEFAULT_TRIALS   100
#define DEFAULT_THROWOUT 10

#define DEFAULT_EXP        EXP_CREATE
#define DEFAULT_EXP_STR    "create"
#define DEFAULT_FETCH_TYPE TYPE_NULL
#define DEFAULT_FETCH_STR  "null"
#define DEFAULT_FIB_ARG    20
#define DEFAULT_CREATIONS  100 

static void*
thread_create_func (void * in)
{
    return NULL;
}

static void *
fib (void * in)
{
    long n = (long)in;

    if (n <= 0) {
        return (void*)0;
    } else if (n == 1) {
        return (void*)1;
    } else {
        return (void*)(n + (long)fib((void*)(n-1)));
    }
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
measure_thread_create (unsigned throwout, unsigned trials, unsigned creations)
{
    pthread_t t;
    struct timespec start;
    struct timespec end;
    int i;
    int j;

    for (i = 0; i < throwout + trials; i++) {

        cpu_set_t cpuset;
        pthread_attr_t attr;
        CPU_ZERO(&cpuset);
        CPU_SET(1, &cpuset);
        pthread_attr_init(&attr);

        // pin it to another core
        pthread_attr_setaffinity_np(&attr, sizeof(cpuset), &cpuset);

        clock_gettime(CLOCK_REALTIME, &start);
	for (j=0; j< creations; j++)
		pthread_create(&t, &attr, thread_create_func, NULL);

        clock_gettime(CLOCK_REALTIME, &end);

        long s_ns = start.tv_sec*1000000000 + start.tv_nsec;
        long e_ns = end.tv_sec*1000000000 + end.tv_nsec;
        double denom = 	e_ns- s_ns;

        if (i >= throwout) {
            printf("%f\n", creations*1000000000/denom);
        }

        usleep(100);

        pthread_join(t, NULL);

    }
    
}


/* 
 * Baseline for a fetch on a future.
 */
static void
measure_thread_fetch (unsigned throwout, 
                      unsigned trials,
                      void*(*func)(void*),
                      void * arg)
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

        pthread_join(t, NULL);

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
    printf("  -p, --creations <creations count> : number of creations to run (default=%d)\n", DEFAULT_CREATIONS);
    printf("  -h, ---help : display this message\n");
    printf("  -v, --version : display the version number and exit\n");

    printf("\nExperiments (default=%s):\n", "create");
    printf("  --create\n");
    printf("  --fetch\n");
    printf("       -e, --fetch-type <type string> : either use \"null\" or \"fib\", default=\"%s\"\n", DEFAULT_FETCH_STR);
    printf("       -b, --fib-arg <arg> : if using \"fib\" function, pass this arg to it (default=%d)\n", DEFAULT_FIB_ARG);

    printf("\n");
}


static void
version ()
{
    printf("pthread create/fetch measurement code (HExSA Lab 2018)\n");
    printf("version %s\n\n", VERSION_STRING);
}

typedef enum exp_id {
    EXP_CREATE,
    EXP_FETCH
} exp_id_t;

typedef enum fetch_type {
    TYPE_NULL,
    TYPE_FIB,
} fetch_type_t;

int 
main (int argc, char ** argv)
{
    unsigned trials   = DEFAULT_TRIALS;
    unsigned throwout = DEFAULT_THROWOUT;
    unsigned creations= DEFAULT_CREATIONS;
    int exp_id        = DEFAULT_EXP;
    int fetch_type    = DEFAULT_FETCH_TYPE;
    long fibarg       = DEFAULT_FIB_ARG;
    char * exp_str    = DEFAULT_EXP_STR;

    int c;

    while (1) {

        int optidx = 0;

        static struct option lopts[] = {
            {"trials", required_argument, 0, 't'},
            {"throwout", required_argument, 0, 'k'},
	    {"creations", required_argument, 0, 'p'},
            {"create", no_argument, 0, 'c'},
            {"fetch", no_argument, 0, 'f'},
            {"fetch-type", required_argument, 0, 'e'},
            {"fib-arg", required_argument, 0, 'b'},
            {"help", no_argument, 0, 'h'},
            {"version", no_argument, 0, 'v'},
            {0, 0, 0, 0}
        };

        c = getopt_long(argc, argv, "t:k:p:ce:b:fhv", lopts, &optidx);

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
            case 'p':
                creations = atoi(optarg);
                break;
            case 'c':
                exp_id = EXP_CREATE;
                exp_str = "create";
                break;
            case 'f':
                exp_id = EXP_FETCH;
                exp_str = "fetch";
                break;
            case 'e':
                if (strcmp(optarg, "null") == 0) {
                    fetch_type = TYPE_NULL;
                } else if (strcmp(optarg, "fib") == 0) {
                    fetch_type = TYPE_FIB;
                }
                break;
            case 'b':
                fibarg = strtol(optarg, NULL, 10);
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
    printf("# Experiment = %s\n", exp_str);
    printf("# Output is in ns\n");
    printf("# %d trials\n", trials);
    printf("# %d throwout\n", throwout);
    printf("# %d creations\n", creations);

    if (exp_id == EXP_CREATE) {
        measure_thread_create(throwout, trials, creations);
    } else if (exp_id == EXP_FETCH) {

        if (fetch_type == TYPE_NULL) {
            printf("# fetch-type: null\n");
            measure_thread_fetch(throwout, trials, thread_create_func, NULL);
        } else if (fetch_type == TYPE_FIB) {
            printf("# fetch-type: fib(%ld)\n", fibarg);
            measure_thread_fetch(throwout, trials, fib, (void*)fibarg);
        }
    }
    
    return 0;
}


