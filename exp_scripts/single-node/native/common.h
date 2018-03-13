#ifndef __COMMON_H__
#define __COMMON_H__


#define rdtscll(val) \
    do {             \
        uint64_t tsc; \
        uint32_t a, d; \
        asm volatile("rdtsc" : "=a" (a), "=d" (d)); \
        *(uint32_t *)&(tsc) = a; \
        *(uint32_t *)(((unsigned char *)&tsc) + 4) = d; \
        val = tsc; \
    } while (0)


static inline void
bset (unsigned int nr, unsigned long * addr)
{
    asm volatile("lock bts %1, %0"
        : "+m" (*(volatile long*)(addr)) : "Ir" (nr) : "memory");
}


#endif
