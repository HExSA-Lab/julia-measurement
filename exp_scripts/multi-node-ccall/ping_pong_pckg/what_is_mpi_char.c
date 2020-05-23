#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>

int main (int argc, char ** argv)
{
	MPI_Init(&argc, &argv);
	printf("Char is %d\n", MPI_STATUS);
	MPI_Finalize();
}
