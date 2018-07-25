#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <mpi.h>
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

static void do_it(int iters, int elements, int flops, int reads, int writes, int comms);
static void do_flops(struct bsp_type *a);
static void do_reads(struct bsp_type *a);
static void do_writes(struct bsp_type *a);
static void do_compute(struct bsp_type *a);
static void do_comms(struct bsp_type *a);


static void do_flops(struct bsp_type *a)


{
    int i;
    double sum;
    double x=1995;

    double val;
    double mpy;

    FILE *fs;
    struct timespec start;
    struct timespec end;
    sum=x;
    for (i=0;i<a->flops;i++) {
        if (a->rank == 0){
	    char filename[sizeof "flops_c_128.dat"];
	    sprintf(filename, "flops_c%d.dat", a->size);
            fs = fopen(filename,"a");
            clock_gettime(CLOCK_REALTIME, &start);
        }
    	val=x;
	    mpy=x;
    	sum = sum + mpy*val;
        if (a->rank == 0){
            clock_gettime(CLOCK_REALTIME, &end);
            long s_ns = start.tv_sec*1000000000 + start.tv_nsec;
            long e_ns = end.tv_sec*1000000000 + end.tv_nsec;
            fprintf(fs,"%lu\n", e_ns - s_ns);
            fclose(fs);
        }
    }
}

static void do_reads(struct bsp_type *a)
{
    int i;
    int *arr = malloc(a->reads*sizeof(int));
    double sum;

    FILE *fs;
    struct timespec start;
    struct timespec end;
    for (i=0;i<a->reads;i++) {
        if (a->rank == 0){
	    char filename[sizeof "reads_c_128.dat"];
	    sprintf(filename, "reads_c%d.dat", a->size);
            fs = fopen(filename,"a");
            clock_gettime(CLOCK_REALTIME, &start);
        }
	    sum = arr[i];
        if (a->rank == 0){
            clock_gettime(CLOCK_REALTIME, &end);
            long s_ns = start.tv_sec*1000000000 + start.tv_nsec;
            long e_ns = end.tv_sec*1000000000 + end.tv_nsec;
            fprintf(fs,"%lu\n", e_ns - s_ns);
            fclose(fs);
        }
    }
}

static void do_writes(struct bsp_type *a)
{
    int i;
    int *arr = malloc(a->writes*sizeof(int));
    double sum;
    double x=93;

    sum = x;

    FILE *fs;
    struct timespec start;
    struct timespec end;
    for (i=0;i<a->writes;i++) {
        if (a->rank == 0){
	    char filename[sizeof "writes_c_128.dat"];
	    sprintf(filename, "writes_c%d.dat", a->size);
            fs = fopen(filename,"a");
            clock_gettime(CLOCK_REALTIME, &start);
        }
	    arr[i] = sum;
        if (a->rank == 0){
            clock_gettime(CLOCK_REALTIME, &end);
            long s_ns = start.tv_sec*1000000000 + start.tv_nsec;
            long e_ns = end.tv_sec*1000000000 + end.tv_nsec;
            fprintf(fs,"%lu\n", e_ns - s_ns);
            fclose(fs);
        }
    }
}


static void do_compute(struct bsp_type *a)
{
    printf("In compute");
    int i;

    FILE *fs;
    struct timespec start;
    struct timespec end;
    for (i=0;i<a->elements;i++) {
        if (a->rank == 0){
	    char filename[sizeof "computes_c_128.dat"];
	    sprintf(filename, "computes_c%d.dat", a->size);
            fs = fopen(filename,"a");
            clock_gettime(CLOCK_REALTIME, &start);
        }
    	do_flops(a);
	    do_reads(a);
    	do_writes(a);

        if (a->rank == 0){
            clock_gettime(CLOCK_REALTIME, &end);
            long s_ns = start.tv_sec*1000000000 + start.tv_nsec;
            long e_ns = end.tv_sec*1000000000 + end.tv_nsec;
            fprintf(fs,"%lu\n", e_ns - s_ns);
            fclose(fs);
        }
    }
   printf("Out of compute");
}
static void do_comms(struct bsp_type *a)
{
    printf("In do_comms");
    int a1;
    int b;
    int i;
    int neighbor_fwd;
    int neighbor_bck;

    FILE *fs;
    struct timespec start;
    struct timespec end;
    if (a->rank ==0){
        neighbor_bck = a->size-1;
    }
    else{
        neighbor_bck = a->rank-1;
    }
    if (a->rank== a->size-1){
         neighbor_fwd = 0;
    }
    else{
         neighbor_fwd = a->rank+1;
    }
    for (i=0;i<a->comms;i++) {
        MPI_Request req;
        if (a->rank == 0){
	    char filename[sizeof "comms_c_128.dat"];
	    sprintf(filename, "comms_c%d.dat", a->size);
            fs = fopen(filename,"a");
            clock_gettime(CLOCK_REALTIME, &start);
        }
        if ( MPI_Isend(&a1, sizeof(int), MPI_INT, neighbor_fwd, 10,a->comm_w, &req)!= MPI_SUCCESS)
            printf("MPI_Send not successful") ;
        if(MPI_Recv(&a1, sizeof(int), MPI_INT, neighbor_bck, 10,a->comm_w, MPI_STATUS_IGNORE)!=MPI_SUCCESS)
            printf("MPI_Recv not successful");
        if (a->rank == 0){
            clock_gettime(CLOCK_REALTIME, &end);
            long s_ns = start.tv_sec*1000000000 + start.tv_nsec;
            long e_ns = end.tv_sec*1000000000 + end.tv_nsec;
            fprintf(fs,"%lu\n", e_ns - s_ns);
            fclose(fs);
        }
    }
    MPI_Barrier(a->comm_w);
   
}


#define MIN_PING_PONG_SIZE 8 // in bytes
#define MAX_PING_PONG_SIZE (1024*1024) // up to 1MB

static void do_ping_pong(struct bsp_type *a)
{
    printf("in ping pong %d", a->rank);
    int i;
    FILE *fs = NULL;
    struct timespec start;
    struct timespec end;
    int tag = 10;

    /* bi-directional test, only two ranks supported */
    int ping = 0;
    int pong = 1;

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
            }
        } else if (a->rank == pong) {
            if (MPI_Recv(arr, i, MPI_BYTE, ping, tag, a->comm_w, MPI_STATUS_IGNORE) != MPI_SUCCESS) {
                fprintf(stderr, "MPI_Recv (ping stage) unsuccessful\n");
            }
           
        }
	printf("ping done");
        /* PONG */
        if (a->rank == pong) {
            if (MPI_Send(arr, i, MPI_BYTE, ping, tag, a->comm_w) != MPI_SUCCESS) {
                printf("MPI_Send (pong stage) unsuccessful\n");
            }
        } else if (a->rank == ping) {
            if (MPI_Recv(arr, i, MPI_BYTE, pong, tag, a->comm_w, MPI_STATUS_IGNORE) != MPI_SUCCESS) {
                printf("MPI_Recv (pong stage) unsuccessful\n");
            }
        }
        printf("pong done");
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
    printf("out of ping pong");

  }
static void do_it(int iters, int elements, int flops, int reads, int writes, int comms)
{
    
    int max_len;
    int rank;
    int size;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    int j;
    char processorname[MPI_MAX_PROCESSOR_NAME];
    MPI_Get_processor_name(processorname,&max_len);

    printf("Hello world!  I am process number: %d on processor %s\n", rank, processorname);
    printf("Damn");
    struct bsp_type a = { size, rank, iters,elements,flops, reads, writes, comms, MPI_COMM_WORLD};
    for (j =0; j<iters;j++) {
        do_compute(&a);
        do_comms(&a);
	printf("communication done");
      //  if (size==16){
       //     do_ping_pong(&a);
       // }
    }
}
int 
main (int argc, char ** argv)
{

    MPI_Init(&argc, &argv);
//    doit(iters, reads, writes, comms);
    do_it(100,100,1000000,5000,5000,100);

    MPI_Finalize();
    //printf("done with finalize\n");
    
    return 0;
}

