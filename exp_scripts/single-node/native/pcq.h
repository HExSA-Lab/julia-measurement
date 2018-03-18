#ifndef __PC_QUEUE_H__
#define __PC_QUEUE_H__

#include <pthread.h>
#include <stdint.h>

typedef struct pcq {
    pthread_mutex_t lock;
    pthread_cond_t empty;
    pthread_cond_t full;
    unsigned head;
    unsigned tail;
    size_t size;
    size_t entries;

    void ** q;
} pcq_t;

pcq_t * pcq_create(unsigned num_elms);
void pcq_destroy(pcq_t * q);
void * pcq_get(pcq_t * q);
void pcq_put(pcq_t * q);

#endif
