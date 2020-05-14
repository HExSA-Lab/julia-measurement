
# synchronization



# Reentrant locks


function measure_relock_lock(iters, throwout)

    
    lk = Base.Threads.ReentrantLock()
    lats = Array{Int64,1}(undef,throwout+iters)

    for i=1:throwout+iters
        s = time_ns()
        Base.lock(lk)
        e = time_ns()
        Base.unlock(lk)
        lats[i] = e - s
    end

    lats[throwout+1:throwout+iters]

end


function measure_relock_trylock(iters, throwout)
    
    lk = Base.Threads.ReentrantLock()
    lats = Array{Int64,1}(undef,iters+ throwout)

    for i=1:throwout+iters
        s = time_ns()
        Base.trylock(lk)
        e = time_ns()
        Base.unlock(lk)
        lats[i] = e - s
    end

    lats[throwout+1:throwout+iters]

end


function measure_relock_unlock(iters, throwout)
    
    lk = Base.Threads.ReentrantLock()
    lats = Array{Int64,1}(undef,iters+throwout)

    for i=1:throwout+iters
        Base.lock(lk)
        s = time_ns()
        Base.unlock(lk)
        e = time_ns()
        lats[i] = e - s
    end

    lats[throwout+1:throwout+iters]

end


# Mutexes

function measure_mutex_lock(iters, throwout)

    
    lk = Base.Threads.Mutex()
    lats = Array{Int64,1}(undef,iters+throwout)

    for i=1:throwout+iters
        s = time_ns()
        Base.lock(lk)
        e = time_ns()
        Base.unlock(lk)
        lats[i] = e - s
    end

    lats[throwout+1: throwout+iters]

end


function measure_mutex_trylock(iters, throwout)
    
    lk = Base.Threads.Mutex()
    lats = Array{Int64,1}(undef,iters+throwout)

    for i=1:throwout+iters
        s = time_ns()
        Base.trylock(lk)
        e = time_ns()
        Base.unlock(lk)
        lats[i] = e - s
    end

    lats[throwout+1:throwout+iters]

end


function measure_mutex_unlock(iters, throwout)
    
    lk = Base.Threads.Mutex()
    lats = Array{Int64,1}(undef,iters+throwout)

    for i=1:throwout+iters
        Base.lock(lk)
        s = time_ns()
        Base.unlock(lk)
        e = time_ns()
        lats[i] = e - s
    end

    lats[throwout+1:throwout+iters]

end


function measure_spinlock_lock(iters, throwout)
    
    lk = Base.Threads.SpinLock()
    lats = Array{Int64,1}(undef,iters+throwout)

    for i=1:throwout+iters
        s = time_ns()
        Base.lock(lk)
        e = time_ns()
        Base.unlock(lk)
        lats[i] = e - s
    end

    lats[throwout+1:throwout+iters]

end

function measure_spinlock_trylock(iters, throwout)
    
    lk = Base.Threads.SpinLock()
    lats = Array{Int64,1}(undef,iters+ throwout)

    for i=1:throwout+iters
        s = time_ns()
        Base.trylock(lk)
        e = time_ns()
        Base.unlock(lk)
        lats[i] = e - s
    end

    lats[throwout+1:throwout+iters]

end

function measure_spinlock_unlock(iters, throwout)
    
    lk = Base.Threads.SpinLock()
    lats = Array{Int64,1}(undef,throwout+iters)

    for i=1:throwout+iters
        Base.lock(lk)
        s = time_ns()
        Base.unlock(lk)
        e = time_ns()
        lats[i] = e - s
    end

    lats[throwout+1:throwout+iters]

end


# Semaphores

function measure_sem_acquire(size, iters, throwout)

	sem = Base.Semaphore(size)
    	lats = Array{Int64,1}(undef,throwout+iters)

	for  i = 1:throwout+iters
		s = time_ns()
		Base.acquire(sem)
		e = time_ns()
		Base.release(sem)
		lats[i] = e-s
	end

	lats[throwout+1:throwout+iters]

end


function measure_sem_release(size, iters, throwout)

	sem = Base.Semaphore(size)
    	lats = Array{Int64,1}(undef,throwout+iters)

	for  i = 1:throwout+iters
		Base.acquire(sem)
		s = time_ns()
		Base.release(sem)
		e = time_ns()
		lats[i] = e-s
	end

	lats[throwout+1:throwout+iters]

end

