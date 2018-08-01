#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <unistd.h>
#include <getopt.h>
#include <stdarg.h>
#include <mpi.h>

#define DEFAULT_ITER 100
#define DEFAULT_ELM 100
#define DEFAULT_FLOPS 1000000
#define DEFAULT_READS 5000
#define DEFAULT_WRITES 5000
#define DEFAULT_COMMS 100

#define VERSION_STRING "0.0.1"

#define MIN_PING_PONG_SIZE 8 // in bytes
#define MAX_PING_PONG_SIZE (1024*1024) // up to 1MB

#define DEBUG_PRINT(rank, fmt, args...) \
    if (global_debug_enable) {    \
        logit("R%03d-DEBUG: " fmt, rank, ##args);         \
    }

static int global_debug_enable = 0;

struct bsp_type {
    int size;
    int rank;
    int iters;
    int elements;
    int flops;
    int reads;
    int writes;
    int comms;
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
do_flops (struct bsp_type * a)
{
    int i;
    double x   = 1995.0;
    double sum = x;

    double val;
    double mpy;

    FILE *fs;
    struct timespec start;
    struct timespec end;

    if (a->rank == 0){
	    char filename[sizeof "flops_c_128.dat"];
	    sprintf(filename, "flops_c_%d.dat", a->size);

	    fs = fopen(filename,"a");

        if (fs == NULL) {
            fprintf(stderr, "Could not open file %s\n", filename);
            return;
        }

	    clock_gettime(CLOCK_REALTIME, &start);

    }

    // do the actual floating point math
    for (i = 0; i < a->flops; i++) {
    	val = x;
	    mpy = x;
    	sum = sum + mpy*val;
    }

    if (a->rank == 0){
	    clock_gettime(CLOCK_REALTIME, &end);
	    long s_ns = start.tv_sec*1000000000 + start.tv_nsec;
	    long e_ns = end.tv_sec*1000000000 + end.tv_nsec;
	    fprintf(fs,"%lu\n", e_ns - s_ns);
	    fclose(fs);
    }
}


static void 
do_reads (struct bsp_type * a)
{
    int i;
    double sum;
    FILE *fs;
    struct timespec start;
    struct timespec end;
    int * arr = NULL;

    arr = malloc(a->reads*sizeof(int));
    if (!arr) {
        fprintf(stderr, "Could not allocate array\n");
        return;
    }
    
    if (a->rank == 0){
	    char filename[sizeof "reads_c_128.dat"];
	    sprintf(filename, "reads_c_%d.dat", a->size);
	    fs = fopen(filename, "a");
        if (!fs) {
            fprintf(stderr, "Could not open file %s in %s\n", filename, __func__);
            return;
        }

	    clock_gettime(CLOCK_REALTIME, &start);
    }

    // do the actual reads
    for (i = 0; i < a->reads; i++) {
	    sum += arr[i];
    }

    if (a->rank == 0) {
	    clock_gettime(CLOCK_REALTIME, &end);
	    long s_ns = start.tv_sec*1000000000 + start.tv_nsec;
	    long e_ns = end.tv_sec*1000000000 + end.tv_nsec;
	    fprintf(fs,"%lu\n", e_ns - s_ns);
	    fclose(fs);
    }
}


static void 
do_writes (struct bsp_type * a)
{
    int i;
    FILE *fs;
    struct timespec start;
    struct timespec end;
    int * arr  = NULL;
    double x   = 93;
    double sum = x;

    arr = malloc(a->writes*sizeof(int));
    if (!arr) {
        fprintf(stderr, "Could not allocate array in %s\n", __func__);
        return;
    }

    if (a->rank == 0) {
	    char filename[sizeof "writes_c_128.dat"];
	    sprintf(filename, "writes_c_%d.dat", a->size);
	    fs = fopen(filename, "a");
	    clock_gettime(CLOCK_REALTIME, &start);
    }

    // do the actual writes
    for (i = 0; i < a->writes; i++) {
	    arr[i] = sum;
    }

    if (a->rank == 0) {
	    clock_gettime(CLOCK_REALTIME, &end);
	    long s_ns = start.tv_sec*1000000000 + start.tv_nsec;
	    long e_ns = end.tv_sec*1000000000 + end.tv_nsec;
	    fprintf(fs,"%lu\n", e_ns - s_ns);
	    fclose(fs);
    }
}


static void 
do_comms (struct bsp_type * a)
{
    int a1;
    int b;
    int i;
    int neighbor_fwd;
    int neighbor_bck;
    FILE *fs;
    struct timespec start;
    struct timespec end;

    DEBUG_PRINT(a->rank, "In do_comms size=%d, rank=%d, comms=%d, comm_w=0x%08x\n",
                a->size,
                a->rank,
                a->comms,
                a->comm_w);

    if (a->rank == 0)
        neighbor_bck = a->size-1;
    else
        neighbor_bck = a->rank-1;

    if (a->rank== a->size-1)
         neighbor_fwd = 0;
    else
         neighbor_fwd = a->rank+1;

    if (a->rank == 0){
        char filename[sizeof "comms_c_128.dat"];
        sprintf(filename, "comms_c_%d.dat", a->size);
        fs = fopen(filename,"a");
        clock_gettime(CLOCK_REALTIME, &start);
    }

    for (i = 0; i < a->comms; i++) {

        MPI_Request req;

        if (MPI_Isend(&a1, sizeof(int), MPI_INT, neighbor_fwd, 10,a->comm_w, &req) != MPI_SUCCESS) {
            fprintf(stderr, "MPI_Send not successful\n");
            return;
        }

        if (MPI_Recv(&a1, sizeof(int), MPI_INT, neighbor_bck, 10,a->comm_w, MPI_STATUS_IGNORE) !=MPI_SUCCESS) {
            fprintf(stderr, "MPI_Recv not successful\n");
            return;
        }

    	MPI_Barrier(a->comm_w);

    }

    if (a->rank == 0) {
        clock_gettime(CLOCK_REALTIME, &end);
        long s_ns = start.tv_sec*1000000000 + start.tv_nsec;
        long e_ns = end.tv_sec*1000000000 + end.tv_nsec;
        fprintf(fs, "%lu\n", e_ns - s_ns);
        fclose(fs);
    }
   
    DEBUG_PRINT(a->rank, "Out of do_comms\n");
}


static void 
do_compute (struct bsp_type * a)
{
    int i;
    FILE * fs = NULL;
    struct timespec start;
    struct timespec end;

    DEBUG_PRINT(a->rank, "In compute\n");

    for (i = 0; i < a->elements; i++) {
    	do_flops(a);
	    do_reads(a);
    	do_writes(a);
    }

    DEBUG_PRINT(a->rank, "Out of compute\n");
}


static void 
do_ping_pong (struct bsp_type * a)
{
    int i;
    FILE *fs = NULL;
    struct timespec start;
    struct timespec end;
    int tag = 10;

    /* bi-directional test, only two ranks supported */
    int ping = 0;
    int pong = 1;

    DEBUG_PRINT(a->rank, "in ping pong %d\n", a->rank);

    for (i = MIN_PING_PONG_SIZE; i <= MAX_PING_PONG_SIZE; i *= 2) {

        unsigned char *arr = malloc(i);
        if (!arr) {
            fprintf(stderr, "Could not allocate array in %s\n", __func__);
            return;
        }

        /* start timer */
        if (a->rank == ping) {
            char filename[sizeof "comm_size_c_16.dat"];
            sprintf(filename,"comm_size_c_%d.dat", i);
            fs = fopen(filename,"a");
            clock_gettime(CLOCK_REALTIME, &start);
        }

        /* PING */
        if (a->rank == ping) {
            if (MPI_Send(arr, i, MPI_BYTE, pong, tag, a->comm_w) != MPI_SUCCESS) {
                fprintf(stderr, "MPI_Send (ping stage) unsuccessful\n");
                return;
            }
        } else if (a->rank == pong) {
            if (MPI_Recv(arr, i, MPI_BYTE, ping, tag, a->comm_w, MPI_STATUS_IGNORE) != MPI_SUCCESS) {
                fprintf(stderr, "MPI_Recv (ping stage) unsuccessful\n");
                return;
            }
           
        }

        DEBUG_PRINT(a->rank, "ping done\n");

        /* PONG */
        if (a->rank == pong) {
            if (MPI_Send(arr, i, MPI_BYTE, ping, tag, a->comm_w) != MPI_SUCCESS) {
                fprintf(stderr, "MPI_Send (pong stage) unsuccessful\n");
                return;
            }
        } else if (a->rank == ping) {
            if (MPI_Recv(arr, i, MPI_BYTE, pong, tag, a->comm_w, MPI_STATUS_IGNORE) != MPI_SUCCESS) {
                fprintf(stderr, "MPI_Recv (pong stage) unsuccessful\n");
                return;
            }
        }

        DEBUG_PRINT(a->rank, "pong done\n");

        if (a->rank == ping) {
              clock_gettime(CLOCK_REALTIME, &end);
              long s_ns = start.tv_sec*1000000000 + start.tv_nsec;
              long e_ns = end.tv_sec*1000000000 + end.tv_nsec;
              fprintf(fs,"%lu\n", e_ns - s_ns);
              fclose(fs);
          }

        /* synch up before trial for next buffer size */
        MPI_Barrier(a->comm_w);
    }

    MPI_Barrier(a->comm_w);

    DEBUG_PRINT(a->rank, "out of ping pong\n");
}


static void 
do_it (int iters, 
       int elements, 
       int flops, 
       int reads, 
       int writes, 
       int comms,
       int rank,
       int size)
{
    int max_len;
    int j;
    char processorname[MPI_MAX_PROCESSOR_NAME];

    MPI_Get_processor_name(processorname, &max_len);

    DEBUG_PRINT(rank, "Hello world! I am process number: %d on processor %s\n", rank, processorname);

    struct bsp_type a = {size, rank, iters, elements, flops, reads, writes, comms, MPI_COMM_WORLD};

    for (j = 0; j < iters; j++) {

        do_compute(&a);
        do_comms(&a);

        DEBUG_PRINT(rank, "Communication done in %s\n", __func__);

    }

}


static void
usage (char * prog)
{
    printf("Usage: %s [options]\n", prog);
    printf("\nOptions:\n");

    printf("  -i, --iterations <n> : number of iterations per loop (default=%d)\n", DEFAULT_ITER);
    printf("  -e, --elements <n> : number of elements in array for reads/writes (default=%d)\n", DEFAULT_ELM);
    printf("  -f, --flops <n> : number of floating point ops (default=%d)\n", DEFAULT_FLOPS);
    printf("  -r, --reads <n> : number of reads (default=%d)\n", DEFAULT_READS);
    printf("  -w, --writes <n> : number of writes (default=%d)\n", DEFAULT_WRITES);
    printf("  -c, --comms <n> : number of communications (default=%d)\n", DEFAULT_COMMS);
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
    int elm    = DEFAULT_ELM;
    int flops  = DEFAULT_FLOPS;
    int reads  = DEFAULT_READS;
    int writes = DEFAULT_WRITES;
    int comms  = DEFAULT_COMMS;

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
            {"elements", required_argument, 0, 'e'},
            {"flops", required_argument, 0, 'f'},
            {"reads", required_argument, 0, 'r'},
            {"writes", required_argument, 0, 'w'},
            {"comms", required_argument, 0, 'c'},
            {"help", no_argument, 0, 'h'},
            {"debug", no_argument, 0, 'd'},
            {"version", no_argument, 0, 'v'},
            {0, 0, 0, 0}
        };

        c = getopt_long(argc, argv, "i:e:f:r:w:c:dhv", lopts, &optidx);

        if (c == -1) {
            break;
        }

        switch (c) {
            case 'i':
                iter = atoi(optarg);
                break;
            case 'e':
                elm = atoi(optarg);
                break;
            case 'f':
                flops = atoi(optarg);
                break;
            case 'r':
                reads = atoi(optarg);
                break;
            case 'w':
                writes = atoi(optarg);
                break;
            case 'c':
                comms = atoi(optarg);
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
		DEBUG_PRINT(0, "  elements: %08d\n", elm);
		DEBUG_PRINT(0, "  flops: %08d\n", flops);
		DEBUG_PRINT(0, "  reads: %08d\n", reads);
		DEBUG_PRINT(0, "  writes: %08d\n", writes);
		DEBUG_PRINT(0, "  comms: %08d\n", comms);
		DEBUG_PRINT(0, "  debug_enable?: %s\n", global_debug_enable ? "yes" : "no");
	}

    do_it(iter, elm, flops, reads, writes, comms, rank, size);

    MPI_Finalize();

    return 0;
}
