/*
 * This set of experiments measures the overheads of 
 * several atomic builtins.
 *
 * HExSA Lab (c) 2018
 * Kyle C. Hale <khale@cs.iit.edu>
 *
 *
 * Generally we use acquire/release semantics
 * for memory ordering (just like Julia's internal implementation
 * does)
 *
 */

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
measure_atomic_set (unsigned throwout, unsigned trials)
{
    struct timespec start;
    struct timespec end;
    int i;
    int a;
    int val = 1;

    for (i = 0; i < throwout + trials; i++) {

        long s_ns = start.tv_sec*1000000000 + start.tv_nsec;
        long e_ns = end.tv_sec*1000000000 + end.tv_nsec;

        clock_gettime(CLOCK_REALTIME, &start);

        __atomic_store(&a, &val, __ATOMIC_RELEASE);

        clock_gettime(CLOCK_REALTIME, &end);

        if (i >= throwout) {
            printf("%lu\n", e_ns - s_ns);
        }

    }
}


static void 
measure_atomic_cas (unsigned throwout, unsigned trials)
{
    struct timespec start;
    struct timespec end;
    int i;
    int a;
    int compare = 0;
    int val = 1;

    for (i = 0; i < throwout + trials; i++) {


        clock_gettime(CLOCK_REALTIME, &start);

        __atomic_compare_exchange(&a,               // what we're comparing
                                  &compare,         // value to compare against
                                  &val,             // value to write to a if compare succeeds
                                  1,                // strong variant
                                  __ATOMIC_ACQ_REL, // success mem consistency
                                  __ATOMIC_ACQUIRE);// failure mem consistency

        clock_gettime(CLOCK_REALTIME, &end);

        long s_ns = start.tv_sec*1000000000 + start.tv_nsec;
        long e_ns = end.tv_sec*1000000000 + end.tv_nsec;

        if (i >= throwout) {
            printf("%lu\n", e_ns - s_ns);
        }

    }
}

#define GEN_ATOMIC_FUNC(func) \
    static void \
    measure_atomic_##func (unsigned throwout, unsigned trials) \
    { \
        struct timespec start; \
        struct timespec end; \
        int i; \
        int a = 0; \
        int val = 1; \
        for (i = 0; i < throwout + trials; i++) { \
            clock_gettime(CLOCK_REALTIME, &start); \
            __atomic_fetch_##func(&a, val, __ATOMIC_ACQ_REL); \
            clock_gettime(CLOCK_REALTIME, &end); \
            long s_ns = start.tv_sec*1000000000 + start.tv_nsec; \
            long e_ns = end.tv_sec*1000000000 + end.tv_nsec; \
            if (i >= throwout) { \
                printf("%lu\n", e_ns - s_ns); \
            } \
        } \
    } 


GEN_ATOMIC_FUNC(add)
GEN_ATOMIC_FUNC(sub)
GEN_ATOMIC_FUNC(or)
GEN_ATOMIC_FUNC(and)
GEN_ATOMIC_FUNC(nand)


/* NOTE: we don't have max/min here */


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
    printf("  --set\n");
    printf("  --cas\n");
    printf("  --add\n");
    printf("  --sub\n");
    printf("  --or\n");
    printf("  --and\n");
    printf("  --nand\n");

    printf("\n");
}


static void
version ()
{
    printf("atomic primitive measurement code (HExSA Lab 2018)\n");
    printf("version %s\n\n", VERSION_STRING);
}


typedef enum exp_type {
    SET,
    CAS,
    ADD,
    SUB,
    OR,
    AND,
    NAND,
} exp_type_t;


static const char * type_to_str[8] = {
    "atomic-set",
    "atomic-cas",
    "atomic-add",
    "atomic-sub",
    "atomic-or",
    "atomic-and",
    "atomic-nand",
};


typedef void (*exp_func_t)(unsigned, unsigned);

exp_func_t type_to_func_map[7] = {
    measure_atomic_set,
    measure_atomic_cas,
    measure_atomic_add,
    measure_atomic_sub,
    measure_atomic_or,
    measure_atomic_and,
    measure_atomic_nand,
};


static void
print_exp_hdr (const char * exp, unsigned trials, unsigned throwout)
{
    printf("# atomic primitive experiment config:\n");
    printf("# Experiment = %s\n", exp);
    printf("# Clocksource = clock_gettime(CLOCK_REALTIME)\n");
    printf("# Output is in ns\n");
    printf("# %d trials\n", trials);
    printf("# %d throwout\n", throwout);
}


static void
parse_args (int argc, 
            char ** argv, 
            unsigned * trials,
            unsigned * throwout,
            int * exp_id)
{
    int c;

    while (1) {

        int optidx = 0;

        static struct option lopts[] = {
            {"trials", required_argument, 0, 't'},
            {"throwout", required_argument, 0, 'k'},
            {"help", no_argument, 0, 'h'},
            {"version", no_argument, 0, 'v'},
            {"set", no_argument, 0, 10},
            {"cas", no_argument, 0, 11},
            {"add", no_argument, 0, 12},
            {"sub", no_argument, 0, 13},
            {"or", no_argument, 0, 14},
            {"and", no_argument, 0, 15},
            {"nand", no_argument, 0, 16},
            {0, 0, 0, 0}
        };

        c = getopt_long(argc, argv, "t:k:hv", lopts, &optidx);

        if (c == -1) {
            break;
        }

        switch (c) {
            case 't':
                *trials = atoi(optarg);
                break;
            case 'k':
                *throwout = atoi(optarg);
                break;
            case 'h':
                usage(argv[0]);
                exit(EXIT_SUCCESS);
            case 'v':
                version();
                exit(EXIT_SUCCESS);
            /* experiments are denoted by codes (see the longopts struct above) */
            case 10:
            case 11:
            case 12:
            case 13:
            case 14:
            case 15:
            case 16:
                *exp_id = ARGTYPE_TO_ENUM(c);
                break;
            case '?':
                break;
            default:
                printf("?? getopt returned character code 0%o ??\n", c);
                usage(argv[0]);
                exit(EXIT_SUCCESS);
        }

    }

}


int 
main (int argc, char ** argv)
{
    unsigned trials =   DEFAULT_TRIALS;
    unsigned throwout = DEFAULT_THROWOUT;
    int exp_id =        DEFAULT_EXP;

    parse_args(argc, argv, &trials, &throwout, &exp_id);

    print_exp_hdr(type_to_str[exp_id], trials, throwout);

    // run the experiment
    type_to_func_map[exp_id](throwout, trials);

    return 0;
}
