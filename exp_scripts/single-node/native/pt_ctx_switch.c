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
#define DEFAULT_YIELDS 100
#define DEFAULT_THROWOUT 10


typedef struct switch_cont {
    pthread_barrier_t * b;
    unsigned char id; /* 0 or 1 */
    unsigned int yield_count;
} switch_cont_t;


static volatile int done[2];
static volatile int ready[2];
static volatile int go;

static void*
thread_switch_func (void * in)
{
    switch_cont_t * t = (switch_cont_t*)in;
    int i;

    ready[t->id] = 1;
        
    pthread_yield();
        
    while (!go) { pthread_yield(); }

    for (i = 0; i < t->yield_count; i++) {
        pthread_yield();
    }

    done[t->id] = 1;

    return NULL;
}


static void
measure_ctx_switch (unsigned throwout, unsigned trials, unsigned yield_count)
{
    pthread_t t[2];
    pthread_barrier_t * b = malloc(sizeof(pthread_barrier_t));
    switch_cont_t * cont1 = malloc(sizeof(switch_cont_t));
    switch_cont_t * cont2 = malloc(sizeof(switch_cont_t));
    //uint64_t start = 0;
    //uint64_t end = 0;
    struct timespec start;
    struct timespec end;
    int i;


    cont1->b   = b;
    cont1->id  = 0;
    cont2->b   = b;
    cont2->id = 1;
    cont1->yield_count = yield_count;
    cont2->yield_count = yield_count;

    for (i = 0; i < throwout + trials; i++) {
        pthread_barrier_init(b, NULL, 3);

        cpu_set_t cpuset;
        CPU_ZERO(&cpuset);
        CPU_SET(1, &cpuset);

        // must explicitly pin them to separate cores
        pthread_create(&t[0], NULL, thread_switch_func, cont1);
        pthread_setaffinity_np(t[0], sizeof(cpu_set_t), &cpuset);

        pthread_create(&t[1], NULL, thread_switch_func, cont2);
        pthread_setaffinity_np(t[1], sizeof(cpu_set_t), &cpuset);

        // give some time to the scheduler to pin them
        usleep(10000);

        // wait for them to be ready
        while ( !(ready[0] && ready[1]) );

        // fire the gun
        go = 1;

        //rdtscll(start);
        clock_gettime(CLOCK_REALTIME, &start);

        // wait for them to finish yielding to one another
        while ( !(done[0] && done[1]) );

        //rdtscll(end);
        clock_gettime(CLOCK_REALTIME, &end);

        long s_ns = start.tv_sec*1000000000 + start.tv_nsec;
        long e_ns = end.tv_sec*1000000000 + end.tv_nsec;

        if (i >= throwout) {
            printf("%lu\n", (e_ns - s_ns)/yield_count*2);
        }

        pthread_join(t[0], NULL);
        pthread_join(t[1], NULL);

        pthread_barrier_destroy(b);

        done[0] = 0;
        done[1] = 0;
        ready[0] = 0;
        ready[1] = 0;
        go = 0;
    }
    
}


static void
usage (char * prog)
{
    printf("Usage: %s [options]\n", prog);
    printf("\nOptions:\n");

    printf("  -t, --trials <trial count> : number of experiments to run (default=%d)\n", DEFAULT_TRIALS);
    printf("  -y, --yields <yield count> : number of times threads yield to each other (default=%d)\n", DEFAULT_YIELDS);
    printf("  -k, --throwout <throwout count> : number of iterations to throw away (default=%d)\n", DEFAULT_THROWOUT);
    printf("  -h, ---help : display this message\n");
    printf("  -v, --version : display the version number and exit\n");

    printf("\n");
}


static void
version ()
{
    printf("pthread context switch measurement code (HExSA Lab 2018)\n");
    printf("version %s\n\n", VERSION_STRING);
}


int 
main (int argc, char ** argv)
{
    unsigned trials = DEFAULT_TRIALS;
    unsigned yield_count = DEFAULT_YIELDS;
    unsigned throwout = DEFAULT_THROWOUT;

    int c;

    while (1) {

        int optidx = 0;

        static struct option lopts[] = {
            {"trials", required_argument, 0, 't'},
            {"yields", required_argument, 0, 'y'},
            {"throwout", required_argument, 0, 'k'},
            {"help", no_argument, 0, 'h'},
            {"version", no_argument, 0, 'v'},
            {0, 0, 0, 0}
        };

        c = getopt_long(argc, argv, "t:y:hv", lopts, &optidx);

        if (c == -1) {
            break;
        }

        switch (c) {
            case 'y':
                yield_count = atoi(optarg);
                break;
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

    printf("# pthread context switch experiment config:\n");
    printf("# Clocksource = clock_gettime(CLOCK_REALTIME)\n");
    printf("# Output is in ns\n");
    printf("# 2 threads\n");
    printf("# %d yields\n", yield_count);
    printf("# %d trials\n", trials);
    printf("# %d throwout\n", throwout);

    measure_ctx_switch(throwout, trials, yield_count);
    
    return 0;
}


