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
#include "pt_parallel_for.h"
#include "common.h"

#define VERSION_STRING "0.0.1"

#define DEFAULT_TRIALS 100
#define DEFAULT_THROWOUT 10
#define DEFAULT_SIZE 50000000



static void*
thread_array_func (void * in)
{
   thread_arr b = * (thread_arr *)in;
   b.arr[b.ind] = b.ind;
   printf("i can see thread start");
   return  NULL;
}
static void
measure_thread_parallel (unsigned throwout, 
						 unsigned trials, 
						 unsigned size)
{
	printf("see me now");
    pthread_t t[size]; //all threads share the same id 
	int * a = NULL;
    struct timespec start;
    struct timespec end;
    int i;
	

	a = malloc(size*sizeof(int));

	if  (a ==NULL) {
		fprintf(stderr, "Could not allocate test array");
		exit(EXIT_FAILURE);
	}	
		
	memset(a, 0, size*sizeof(int));

		printf("can you see me now?");
        cpu_set_t cpuset;
        pthread_attr_t attr;
        CPU_ZERO(&cpuset);
        CPU_SET(1, &cpuset);
        pthread_attr_init(&attr);
        pthread_attr_setaffinity_np(&attr, sizeof(cpuset), &cpuset);
		//create as many threads as the size of the array
		
		thread_arr *t_arr =  malloc( sizeof(*t_arr) + size*sizeof(int)); 
		t_arr->ind	= i ;
		t_arr->size	= size;
		for (int k = 0; k<size; k++){
				t_arr->arr[i] = 0;
		}
    for (i = 0; i < throwout + trials; i++) {
		
        clock_gettime(CLOCK_REALTIME, &start);
		for(int j = 0; j < size; j++)	{	
			pthread_create(&t[i], &attr, thread_array_func, &t_arr);
        }
		
        clock_gettime(CLOCK_REALTIME, &end);

        long s_ns = start.tv_sec*1000000000 + start.tv_nsec;
        long e_ns = end.tv_sec*1000000000 + end.tv_nsec;

        if (i >= throwout) {
            printf("%lu\n", e_ns - s_ns);
        }

        usleep(100);

        pthread_join(t[size], NULL);

    }
    
}


static void
usage (char * prog)
{
    printf("Usage: %s [options]\n", prog);
    printf("\nOptions:\n");

    printf("  -t, --trials <trial count> : number of experiments to run (default=%d)\n", DEFAULT_TRIALS);
    printf("  -k, --throwout <throwout count> : number of iterations to throw away (default=%d)\n", DEFAULT_THROWOUT);
    printf("  -s, --szie of array y (default=%d)\n", DEFAULT_SIZE);
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
    unsigned trials = DEFAULT_TRIALS;
    unsigned throwout = DEFAULT_THROWOUT;
	unsigned size = DEFAULT_SIZE;
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
    printf("# pthread parallel experiment config:\n");
    printf("# Clocksource = clock_gettime(CLOCK_REALTIME)\n");
    printf("# Output is in ns\n");
    printf("# %d trials\n", trials);
    printf("# %d throwout\n", throwout);
    printf("# %d size\n", size);
	measure_thread_parallel(10,100,10);
    return 0;
}

//iam not feeling so good
