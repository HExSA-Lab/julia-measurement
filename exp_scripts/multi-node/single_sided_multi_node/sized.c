
#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <unistd.h>
#include <getopt.h>
#include <stdarg.h>
#include <mpi.h>

#define DEFAULT_ITER 100
#define DEFAULT_PUTS 100
#define DEFAULT_GETS 1000000

#define VERSION_STRING "0.0.1"

#define MIN_SIZE 8 // in bytes
#define MAX_SIZE (1024*1024) // up to 1MB

#define DEBUG_PRINT(rank, fmt, args...) \
    if (global_debug_enable) {    \
        logit("R%03d-DEBUG: " fmt, rank, ##args);         \
    }

static int global_debug_enable = 0;

struct bsp_type {
    int size;
    int rank;
    int iters;
    int gets;
    int puts;
    MPI_Comm comm_w;
};


static void
logit (const char * fmt, ...)
{
    va_list ap;
    va_start(ap, fmt);
    vprintf(fmt, ap);
    va_end(ap);
}




static void 
do_sized_gets (struct bsp_type * a)
{
    int a1;
    int i, j;
    int fwd;
    FILE *fs;
    struct timespec start;
    struct timespec end;
    MPI_Win win;
    unsigned char *rcv_arr = malloc(i);
    if (a->rank== a->size-1)
        fwd = 0;
    else
        fwd = a->rank+1;
    
    for (i = MIN_SIZE; i <= MAX_SIZE; i *= 2) {

    	unsigned char *buf_arr = malloc(i);
    	MPI_Win_create(buf_arr, a->size, 1, MPI_INFO_NULL, MPI_COMM_WORLD, &win);
    	MPI_Win_fence(0,win);


    	if (a->rank == 0){
        	char filename[sizeof "get_c_size_655360.dat"];
	        sprintf(filename, "get_c_size_%d.dat", i);
        	fs = fopen(filename,"a");
        	clock_gettime(CLOCK_REALTIME, &start);
    	}

    	for (j = 0; j < a->gets; j++) {
        	MPI_Get(rcv_arr,i, MPI_CHAR, fwd, 0, i, MPI_CHAR, win);
		MPI_Win_fence(0,win);

   	}	

    	MPI_Barrier(a->comm_w);


    	if (a->rank == 0) {
        	clock_gettime(CLOCK_REALTIME, &end);
        	long s_ns = start.tv_sec*1000000000 + start.tv_nsec;
        	long e_ns = end.tv_sec*1000000000 + end.tv_nsec;
	        fprintf(fs, "%lu\n", e_ns - s_ns);
	        fclose(fs);
    	}
    } 
    rcv_arr;
   
}


static void 
do_sized_puts (struct bsp_type * a)
{
    int a1;
    int i, j;
    int fwd;
    FILE *fs;
    struct timespec start;
    struct timespec end;
    MPI_Win win;
    unsigned char *rcv_arr = malloc(i);
    if (a->rank== a->size-1)
        fwd = 0;
    else
        fwd = a->rank+1;
    
    for (i = MIN_SIZE; i <= MAX_SIZE; i *= 2) {

    	unsigned char *buf_arr = malloc(i);
    	MPI_Win_create(buf_arr, a->size, 1, MPI_INFO_NULL, MPI_COMM_WORLD, &win);
    	MPI_Win_fence(0,win);


    	if (a->rank == 0){
        	char filename[sizeof "get_c_size_655360.dat"];
	        sprintf(filename, "put_c_size_%d.dat", i);
        	fs = fopen(filename,"a");
        	clock_gettime(CLOCK_REALTIME, &start);
    	}

    	for (j = 0; j < a->puts; j++) {
        	MPI_Put(rcv_arr,i, MPI_CHAR, fwd, 0, i, MPI_CHAR, win);
		MPI_Win_fence(0,win);

   	}	

    	MPI_Barrier(a->comm_w);


    	if (a->rank == 0) {
        	clock_gettime(CLOCK_REALTIME, &end);
        	long s_ns = start.tv_sec*1000000000 + start.tv_nsec;
        	long e_ns = end.tv_sec*1000000000 + end.tv_nsec;
	        fprintf(fs, "%lu\n", e_ns - s_ns);
	        fclose(fs);
    	}
    } 
    rcv_arr;
   
}


static void 
do_it (int iters, 
       int gets, 
       int puts, 
       int rank,
       int size)
{
    int max_len;
    int j;
    char processorname[MPI_MAX_PROCESSOR_NAME];

    MPI_Get_processor_name(processorname, &max_len);

    DEBUG_PRINT(rank, "Hello world! I am process number: %d on processor %s\n", rank, processorname);

    struct bsp_type a = {size, rank, iters, gets, puts,  MPI_COMM_WORLD};

    for (j = 0; j < iters; j++) {
	do_sized_puts(&a);
	do_sized_gets(&a);

        DEBUG_PRINT(rank, "Communication done in %s\n", __func__);

    }

}


static void
usage (char * prog)
{
    printf("Usage: %s [options]\n", prog);
    printf("\nOptions:\n");

    printf("  -i, --iterations <n> : number of iterations per loop (default=%d)\n", DEFAULT_ITER);
    printf("  -g, --gets <n> : number of GET ops (default=%d)\n", DEFAULT_GETS);
    printf("  -p, --puts <n> : number of PUT ops (default=%d)\n", DEFAULT_PUTS);
    printf("  -d, --debug     : enable debugging prints\n");
    printf("  -h, ---help : display this message\n");
    printf("  -v, --version : display the version number and exit\n");

    printf("\n");
}


static void
version ()
{
    printf("MPI BSP multi-node synthetic benchmark (HExSA Lab 2018)\n");
    printf("version %s\n\n", VERSION_STRING);
}


int 
main (int argc, char ** argv)
{
    int iter   = DEFAULT_ITER;
    int gets    = DEFAULT_GETS;
    int puts  = DEFAULT_PUTS;

    int rank;
    int size;
    
    int c;

    MPI_Init(&argc, &argv);

    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    if (argc < 2 && rank == 0) {
        usage(argv[0]);
        exit(EXIT_SUCCESS);
    }

    while (1) {

        int optidx = 0;

        static struct option lopts[] = {
            {"iterations", required_argument, 0, 'i'},
            {"gets", required_argument, 0, 'g'},
            {"puts", required_argument, 0, 'p'},
            {"help", no_argument, 0, 'h'},
            {"debug", no_argument, 0, 'd'},
            {"version", no_argument, 0, 'v'},
            {0, 0, 0, 0}
        };

        c = getopt_long(argc, argv, "i:g:p:dhv", lopts, &optidx);

        if (c == -1) {
            break;
        }

        switch (c) {
            case 'i':
                iter = atoi(optarg);
                break;
            case 'g':
                gets = atoi(optarg);
                break;
            case 'p':
                puts = atoi(optarg);
                break;
            case 'd':
                global_debug_enable = 1;
                break;
            case 'h':
				if (rank == 0) {
					usage(argv[0]);
					exit(EXIT_SUCCESS);
				}
				break;
            case 'v':
				if (rank == 0) {
					version();
					exit(EXIT_SUCCESS);
				}
				break;
            case '?':
                break;
            default:
                printf("?? getopt returned character code 0%o ??\n", c);
        }
    }

	if (rank == 0) {
		DEBUG_PRINT(0, "Using the following experiment config:\n");
		DEBUG_PRINT(0, "  iterations: %08d\n", iter);
		DEBUG_PRINT(0, "  gets: %08d\n", gets);
		DEBUG_PRINT(0, "  puts: %08d\n", puts);
		DEBUG_PRINT(0, "  debug_enable?: %s\n", global_debug_enable ? "yes" : "no");
	}

    do_it(iter, gets, puts, rank, size);

    MPI_Abort(MPI_COMM_WORLD, 1);

    return 0;
}
