#include <stdio.h>
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

    sum=x;
    for (i=0;i<a->flops;i++) {
    	val=x;
	    mpy=x;
    	sum = sum + mpy*val;
    }
}

static void do_reads(struct bsp_type *a)
{
    int i;
    int *arr = malloc(a->reads*sizeof(int));
    double sum;

    for (i=0;i<a->reads;i++) {
	    sum = arr[i];
    }
}

static void do_writes(struct bsp_type *a)
{
    int i;
    int *arr = malloc(a->writes*sizeof(int));
    double sum;
    double x=93;

    sum = x;

    for (i=0;i<a->writes;i++) {
	arr[i] = sum;
    }
}


static void do_compute(struct bsp_type *a)
{
    int i;

    for (i=0;i<a->elements;i++) {
	do_flops(a);
	do_reads(a);
	do_writes(a);
    }
}
static void do_comms(struct bsp_type *a)
{
    int a;
    int i;
    int neighbor_fwd;
    int neighbor_bck;
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
        if ( MPI_Isend(a, sizeof(int), MPI_INT, neighbor_fwd, 10,a->comm_w, &req)!= MPI_SUCCESS)
            printf("MPI_Send not successful") ;
             
        if(MPI_Recv(a, sizeof(int), MPI_INT, neighbor_bck, 10,a->comm_w, MPI_STATUS_IGNORE)!=MPI_SUCCESS)
            printf("MPI_Recv not successful");
    }
//    printf("Complete\n");
   
}

static void do_it(int iters, int elements, int flops, int reads, int writes, int comms)
{
    
    int max_len;
    int rank;
    int size;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    int i;
    char processorname[MPI_MAX_PROCESSOR_NAME];
    MPI_Get_processor_name(processorname,&max_len);

    printf("Hello world!  I am process number: %d on processor %s\n", rank, processorname);
    struct bsp_type a = { size, rank, iters,elements,flops, reads, writes, comms, MPI_COMM_WORLD};
    for (i=0; i<iters;i++) {
        do_compute(&a);
//        printf("compute->%d\n", i);

        do_comms(&a);
  //      printf("comm->%d\n",i);
    }

}
int 
main (int argc, char ** argv)
{

    MPI_Init(&argc, &argv);
//    doit(iters, reads, writes, comms);
    do_it(100,100,100,100,100,100);

    MPI_Finalize();
    //printf("done with finalize\n");
    
    return 0;
}

