/*
 * Measures (uncontended) puts and gets on
 * a channel (producer-consumer) queue
 * using pthreads locks/cond vars
 *
 */
#define _GNU_SOURCE
#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <time.h>
#include <unistd.h>
#include <sched.h>
#include <pthread.h>
#include <getopt.h>

#include "pcq.h"

#define VERSION_STRING "0.0.1"

#define DEFAULT_TRIALS 100
#define DEFAULT_THROWOUT 10

#define DEFAULT_CHAN_SZ 10

static void
measure_pcq_get (unsigned throwout, unsigned trials)
{
    pcq_t * pcq = pcq_create(DEFAULT_CHAN_SZ);
    struct timespec s;
    struct timespec e;
    long int elm = 0xdeadbeef00000000;
    int i;

    if (!pcq) {
        fprintf(stderr, "Could not create channel\n");
        exit(EXIT_FAILURE);
    }


    for (i = 0; i < throwout + trials; i++) {

        void * x;

        pcq_put(pcq, (void*)elm);

        clock_gettime(CLOCK_REALTIME, &s);
            
        x = pcq_get(pcq);

        clock_gettime(CLOCK_REALTIME, &e);

        long s_ns = s.tv_sec*1000000000 + s.tv_nsec;
        long e_ns = e.tv_sec*1000000000 + e.tv_nsec;

        if (i >= throwout) {
            printf("%lu\n", e_ns - s_ns);
        }

    }

    pcq_destroy(pcq);
}

static void
measure_pcq_put (unsigned throwout, unsigned trials)
{
    pcq_t * pcq = pcq_create(DEFAULT_CHAN_SZ);
    struct timespec s;
    struct timespec e;
    long int elm = 0xdeadbeef00000000;
    int i;

    if (!pcq) {
        fprintf(stderr, "Could not create channel\n");
        exit(EXIT_FAILURE);
    }


    for (i = 0; i < throwout + trials; i++) {

        void * x;

        clock_gettime(CLOCK_REALTIME, &s);

        pcq_put(pcq, (void*)elm);

        clock_gettime(CLOCK_REALTIME, &e);

        x = pcq_get(pcq);

        long s_ns = s.tv_sec*1000000000 + s.tv_nsec;
        long e_ns = e.tv_sec*1000000000 + e.tv_nsec;

        if (i >= throwout) {
            printf("%lu\n", e_ns - s_ns);
        }

    }

    pcq_destroy(pcq);
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

    printf("\nExperiments:\n");
    printf("  --get\n");
    printf("  --put\n");

    printf("\n");
}


static void
version ()
{
    printf("channel (prod. consumer queue) measurement code (HExSA Lab 2018)\n");
    printf("version %s\n\n", VERSION_STRING);
}


int 
main (int argc, char ** argv)
{
    unsigned trials   = DEFAULT_TRIALS;
    unsigned throwout = DEFAULT_THROWOUT;
    int exp = 0; // default is get
    char * exp_str = "get";

    int c;

    while (1) {

        int optidx = 0;

        static struct option lopts[] = {
            {"trials", required_argument, 0, 't'},
            {"throwout", required_argument, 0, 'k'},
            {"help", no_argument, 0, 'h'},
            {"version", no_argument, 0, 'v'},
            {"get", no_argument, 0, 'g'},
            {"put", no_argument, 0, 'p'},
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
            case 'g':
                exp = 0;
                exp_str = "get";
                break;
            case 'p':
                exp = 1;
                exp_str = "put";
                break;
            case 'v':
                version();
                exit(EXIT_SUCCESS);
            case '?':
                break;
            default:
                printf("?? getopt returned character code 0%o ??\n", c);
        }

    }

    printf("# channel experiment config:\n");
    printf("# Clocksource = clock_gettime(CLOCK_REALTIME)\n");
    printf("# Experiment = %s\n", exp_str);
    printf("# Output is in ns\n");
    printf("# %d trials\n", trials);
    printf("# %d throwout\n", throwout);

    if (exp == 0) {
        measure_pcq_get(throwout, trials);
    } else {
        measure_pcq_put(throwout, trials);
    }
    
    return 0;
}
