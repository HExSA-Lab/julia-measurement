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
#define DEFAULT_REMOTE_CPU 1

static struct cv {
    struct timespec start;
    struct timespec end;
} cond_time;


static void*
wakeme (void * in)
{
    pthread_cond_t * c = (pthread_cond_t*)in;
    usleep(100);
    pthread_cond_signal(c);
    clock_gettime(CLOCK_REALTIME, &(cond_time.start));
    return NULL;
}


static void
measure_cond (unsigned throwout, unsigned trials, unsigned remote_cpu)
{
    pthread_cond_t c;
    pthread_t t;
    pthread_mutex_t l;
    int i;

    pthread_mutex_init(&l, NULL);
    pthread_cond_init(&c, NULL);

    for (i = 0; i < throwout + trials; i++) {

        cpu_set_t cpuset;
        pthread_attr_t attr;
        CPU_ZERO(&cpuset);
        CPU_SET(remote_cpu, &cpuset);
        pthread_attr_init(&attr);

        // pin it to the remote core
        pthread_attr_setaffinity_np(&attr, sizeof(cpuset), &cpuset);
        pthread_create(&t, &attr, wakeme, &c);

        pthread_mutex_lock(&l);

        pthread_cond_wait(&c, &l);

        clock_gettime(CLOCK_REALTIME, &(cond_time.end));

        pthread_mutex_unlock(&l);

        pthread_join(t, NULL);

        long s_ns = cond_time.start.tv_sec*1000000000 + cond_time.start.tv_nsec;
        long e_ns = cond_time.end.tv_sec*1000000000 + cond_time.end.tv_nsec;

        if (i >= throwout) {
            printf("%lu\n", e_ns - s_ns);
        }

    }

    pthread_mutex_destroy(&l);
    pthread_cond_destroy(&c);
}


static void
usage (char * prog)
{
    printf("Usage: %s [options]\n", prog);
    printf("\nOptions:\n");

    printf("  -t, --trials <trial count> : number of experiments to run (default=%d)\n", DEFAULT_TRIALS);
    printf("  -k, --throwout <throwout count> : number of iterations to throw away (default=%d)\n", DEFAULT_THROWOUT);
    printf("  -c, ---remote-core <core-num> : remote core to participate in experiment (default=%d)\n", DEFAULT_REMOTE_CPU);
    printf("  -h, ---help : display this message\n");
    printf("  -v, --version : display the version number and exit\n");

    printf("\n");
}


static void
version ()
{
    printf("pthread condition variable measurement code (HExSA Lab 2018)\n");
    printf("version %s\n\n", VERSION_STRING);
}


int 
main (int argc, char ** argv)
{
    unsigned trials   = DEFAULT_TRIALS;
    unsigned throwout = DEFAULT_THROWOUT;
    unsigned remote   = DEFAULT_REMOTE_CPU;

    int c;

    while (1) {

        int optidx = 0;

        static struct option lopts[] = {
            {"trials", required_argument, 0, 't'},
            {"throwout", required_argument, 0, 'k'},
            {"remote-cpu", required_argument, 0, 'c'},
            {"help", no_argument, 0, 'h'},
            {"version", no_argument, 0, 'v'},
            {0, 0, 0, 0}
        };

        c = getopt_long(argc, argv, "t:k:c:hv", lopts, &optidx);

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
            case 'c':
                remote = atoi(optarg);
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

    printf("# pthread condition variable experiment config:\n");
    printf("# Clocksource = clock_gettime(CLOCK_REALTIME)\n");
    printf("# Output is in ns\n");
    printf("# %d trials\n", trials);
    printf("# %d throwout\n", throwout);
    printf("# %d remote core\n", remote);

    measure_cond(throwout, trials, remote);
    
    return 0;
}


