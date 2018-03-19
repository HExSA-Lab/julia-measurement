#ifndef __PT_PARALLEL_H__
#define __PT_PARALLEL_H__

#include <stdint.h>

typedef struct thread_arr {
    unsigned int ind ;
	unsigned int size;
	unsigned int arr[];	 

} thread_arr;


#endif
