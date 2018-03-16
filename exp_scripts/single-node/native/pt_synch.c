#define _GNU_SOURCE
#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <time.h>
#include <unistd.h>
#include <sched.h>
#include <pthread.h>
#include <getopt.h>
#include <semaphore.h>

#include "common.h"

#define VERSION_STRING "0.0.1"

#define DEFAULT_TRIALS 100
#define DEFAULT_THROWOUT 10



static void 
measure_mutex_lock (unsigned throwout, unsigned trials)
{
    struct timespec start;
    struct timespec end;
    pthread_mutex_t mutex;
    int i;

    pthread_mutex_init(&mutex, NULL);

    for (i = 0; i < throwout + trials; i++) {

        clock_gettime(CLOCK_REALTIME, &start);

        pthread_mutex_lock(&mutex);

        clock_gettime(CLOCK_REALTIME, &end);

        pthread_mutex_unlock(&mutex);

        long s_ns = start.tv_sec*1000000000 + start.tv_nsec;
        long e_ns = end.tv_sec*1000000000 + end.tv_nsec;

        if (i >= throwout) {
            printf("%lu\n", e_ns - s_ns);
        }

    }

    pthread_mutex_destroy(&mutex);
}

static void 
measure_mutex_trylock (unsigned throwout, unsigned trials)
{
    struct timespec start;
    struct timespec end;
    pthread_mutex_t mutex;
    int i;

    pthread_mutex_init(&mutex, NULL);

    for (i = 0; i < throwout + trials; i++) {

        clock_gettime(CLOCK_REALTIME, &start);

        int x = pthread_mutex_trylock(&mutex);

        clock_gettime(CLOCK_REALTIME, &end);

        if (!x) {
            pthread_mutex_unlock(&mutex);
        }

        long s_ns = start.tv_sec*1000000000 + start.tv_nsec;
        long e_ns = end.tv_sec*1000000000 + end.tv_nsec;

        if (i >= throwout) {
            printf("%lu\n", e_ns - s_ns);
        }

    }

    pthread_mutex_destroy(&mutex);
}
        


static void
measure_mutex_unlock (unsigned throwout, unsigned trials)
{
    struct timespec start;
    struct timespec end;
    pthread_mutex_t mutex;
    int i;

    pthread_mutex_init(&mutex, NULL);

    for (i = 0; i < throwout + trials; i++) {

        pthread_mutex_lock(&mutex);

        clock_gettime(CLOCK_REALTIME, &start);

        pthread_mutex_unlock(&mutex);

        clock_gettime(CLOCK_REALTIME, &end);

        long s_ns = start.tv_sec*1000000000 + start.tv_nsec;
        long e_ns = end.tv_sec*1000000000 + end.tv_nsec;

        if (i >= throwout) {
            printf("%lu\n", e_ns - s_ns);
        }

    }

    pthread_mutex_destroy(&mutex);
}


static void 
measure_spin_lock (unsigned throwout, unsigned trials)
{
    struct timespec start;
    struct timespec end;
    pthread_spinlock_t lock;
    int i;

    pthread_spin_init(&lock, 0);

    for (i = 0; i < throwout + trials; i++) {

        clock_gettime(CLOCK_REALTIME, &start);

        pthread_spin_lock(&lock);

        clock_gettime(CLOCK_REALTIME, &end);

        pthread_spin_unlock(&lock);

        long s_ns = start.tv_sec*1000000000 + start.tv_nsec;
        long e_ns = end.tv_sec*1000000000 + end.tv_nsec;

        if (i >= throwout) {
            printf("%lu\n", e_ns - s_ns);
        }

    }

    pthread_spin_destroy(&lock);
}

static void 
measure_spin_trylock (unsigned throwout, unsigned trials)
{
    struct timespec start;
    struct timespec end;
    pthread_spinlock_t lock;
    int i;

    pthread_spin_init(&lock, 0);

    for (i = 0; i < throwout + trials; i++) {

        clock_gettime(CLOCK_REALTIME, &start);

        int x = pthread_spin_trylock(&lock);

        clock_gettime(CLOCK_REALTIME, &end);

        if (!x) {
            pthread_spin_unlock(&lock);
        }

        long s_ns = start.tv_sec*1000000000 + start.tv_nsec;
        long e_ns = end.tv_sec*1000000000 + end.tv_nsec;

        if (i >= throwout) {
            printf("%lu\n", e_ns - s_ns);
        }

    }

    pthread_spin_destroy(&lock);
}

static void 
measure_spin_unlock (unsigned throwout, unsigned trials)
{
    struct timespec start;
    struct timespec end;
    pthread_spinlock_t lock;
    int i;

    pthread_spin_init(&lock, 0);

    for (i = 0; i < throwout + trials; i++) {

        pthread_spin_lock(&lock);

        clock_gettime(CLOCK_REALTIME, &start);

        pthread_spin_unlock(&lock);

        clock_gettime(CLOCK_REALTIME, &end);

        long s_ns = start.tv_sec*1000000000 + start.tv_nsec;
        long e_ns = end.tv_sec*1000000000 + end.tv_nsec;

        if (i >= throwout) {
            printf("%lu\n", e_ns - s_ns);
        }

    }

    pthread_spin_destroy(&lock);
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
    printf("  --spin-lock\n");
    printf("  --spin-trylock\n");
    printf("  --spin-unlock\n");
    printf("  --mutex-lock\n");
    printf("  --mutex-trylock\n");
    printf("  --mutex-unlock\n");
    printf("  --sem-up\n");
    printf("  --sem-down\n");

    printf("\n");
}


static void
version ()
{
    printf("pthread synchronization measurement code (HExSA Lab 2018)\n");
    printf("version %s\n\n", VERSION_STRING);
}


typedef enum exp_type {
    SPIN_LOCK,
    SPIN_TRYLOCK,
    SPIN_UNLOCK,
    MUTEX_LOCK,
    MUTEX_TRYLOCK,
    MUTEX_UNLOCK,
    SEM_UP,
    SEM_DOWN,
} exp_type_t;

static const char * type_to_str[8] = {
    "spin-lock",
    "spin-trylock",
    "spin-unlock",
    "mutex-lock",
    "mutex-trylock",
    "mutex-unlock",
    "sem-up",
    "sem-down",
};

void (*type_to_func_map)(unsigned throwout, unsigned trials)[8] = {
    measure_spin_lock,
    measure_spin_trylock,
    measure_spin_unlock,
    measure_mutex_lock,
    measure_mutex_trylock,
    measure_mutex_unlock,
    measure_sem_up,
    measure_sem_down,
};

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
            {"spin-lock", no_argument, 0, 0},
            {"spin-trylock", no_argument, 0, 0},
            {"spin-unlock", no_argument, 0, 0},
            {"mutex-lock", no_argument, 0, 0},
            {"mutex-trylock", no_argument, 0, 0},
            {"mutex-unlock", no_argument, 0, 0},
            {"sem-up", no_argument, 0, 0},
            {"sem-down", no_argument, 0, 0},
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

    printf("# pthread synchronization experiment config:\n");
    printf("# Clocksource = clock_gettime(CLOCK_REALTIME)\n");
    printf("# Output is in ns\n");
    printf("# %d trials\n", trials);
    printf("# %d throwout\n", throwout);

    return 0;
}


