#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include <string.h>
#include <pthread.h>

#include "pcq.h"


pcq_t *
pcq_create (unsigned num_elms)
{
    pcq_t * q = NULL;

    if (num_elms == 0) {
        return NULL;
    }

    q = malloc(sizeof(pcq_t));

    if (!q) {
        return NULL;
    }

    memset(q, 0, sizeof(pcq_t));

    pthread_mutex_init(&q->lock, NULL);
    pthread_cond_init(&q->empty, NULL);
    pthread_cond_init(&q->full, NULL);

    q->entries = 0;
    q->head    = 0;
    q->tail    = 0;
    q->size    = num_elms;

    q->q = malloc(num_elms*sizeof(void*));
    
    if (!q->q) {
        goto out_err;
    }

    memset(q->q, 0, num_elms*sizeof(void*));
    
    return q;

out_err:
    free(q);
    return NULL;
}

void
pcq_destroy (pcq_t * q)
{
    pthread_mutex_destroy(&q->lock);
    pthread_cond_destroy(&q->empty);
    pthread_cond_destroy(&q->full);
    free(q->q);
    free(q);
}

void *
pcq_get (pcq_t * q)
{
    void * elm = NULL;

    pthread_mutex_lock(&q->lock);

    if (q->entries == 0) {
        pthread_cond_wait(&q->empty, &q->lock);
    }

    elm = q->q[q->head];

    q->q[q->head] = NULL;

    q->head = (q->head + 1) % q->size;

    if (q->entries == q->size) {
        pthread_cond_signal(&q->full);
    }

    q->entries--;

    pthread_mutex_unlock(&q->lock);

    return elm;
}


void
pcq_put (pcq_t * q, void * elm)
{
    pthread_mutex_lock(&q->lock);

    if (q->entries == q->size) {
        pthread_cond_wait(&q->full, &q->lock);
    }

    q->q[q->tail] = elm;

    q->tail = (q->tail + 1) % q->size;

    if (q->entries == 0) {
        pthread_cond_signal(&q->empty);
    }

    q->entries++;

    pthread_mutex_unlock(&q->lock);
}
