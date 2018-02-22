#include <stdlib.h>
#include <stdint.h>



uint64_t rdtsc () {

}

uint64_t rdtscp () {

}


/* 
 * TODO: proper cpuid serialization here
 */
uint64_t rdtsc_asym_start () {
	return 0;
}


/*
 * asymmetric (no-cpuid) end point of rdtsc
 */
uint64_t rdtsc_asym_end () {

	return 0;
}
