
# synchronization



# Reentrant locks


function measure_relock_lock(iters, throwout)

    
    lk = Base.Threads.ReursiveSpinlock()
    lats = Array{Int64}(iters)

    for i=1:throwout
        s = time_ns()
        Base.lock(lk)
        e = time_ns()
        Base.unlock(lk)
        lats[i] = e - s
    end

    for i=1:iters
        s = time_ns()
        Base.lock(lk)
        e = time_ns()
        Base.unlock(lk)
        lats[i] = e - s
    end

    lats

end

# TODO
function measure_relock_trylock(iters, throwout)
    
    lk = Base.Threads.RecursiveSpinLock()
    lats = Array{Int64}(iters)

    for i=1:throwout
        s = time_ns()
        Base.trylock(lk)
        e = time_ns()
        Base.unlock(lk)
        lats[i] = e - s
    end

    for i=1:iters
        s = time_ns()
        Base.trylock(lk)
        e = time_ns()
        Base.unlock(lk)
        lats[i] = e - s
    end

    lats

end

# TODO
function measure_relock_unlock(iters, throwout)
    
    lk = Base.Threads.RecuursiveSpinLock()
    lats = Array{Int64}(iters)

    for i=1:throwout
        Base.lock(lk)
        s = time_ns()
        Base.unlock(lk)
        e = time_ns()
        lats[i] = e - s
    end

    for i=1:iters
        Base.lock(lk)
        s = time_ns()
        Base.unlock(lk)
        e = time_ns()
        lats[i] = e - s
    end

    lats

end


# Mutexes

# TODO
function measure_mutex_lock(iters, throwout)

    
    lk = Base.Threads.Mutex()
    lats = Array{Int64}(iters)

    for i=1:throwout
        s = time_ns()
        Base.lock(lk)
        e = time_ns()
        Base.unlock(lk)
        lats[i] = e - s
    end

    for i=1:iters
        s = time_ns()
        Base.lock(lk)
        e = time_ns()
        Base.unlock(lk)
        lats[i] = e - s
    end

    lats

end

# TODO
function measure_mutex_trylock(iters, throwout)
    
    lk = Base.Threads.Mutex()
    lats = Array{Int64}(iters)

    for i=1:throwout
        s = time_ns()
        Base.trylock(lk)
        e = time_ns()
        Base.unlock(lk)
        lats[i] = e - s
    end

    for i=1:iters
        s = time_ns()
        Base.trylock(lk)
        e = time_ns()
        Base.unlock(lk)
        lats[i] = e - s
    end

    lats

end

# TODO
function measure_mutex_unlock(iters, throwout)
    
    lk = Base.Threads.Mutex()
    lats = Array{Int64}(iters)

    for i=1:throwout
        Base.lock(lk)
        s = time_ns()
        Base.unlock(lk)
        e = time_ns()
        lats[i] = e - s
    end

    for i=1:iters
        Base.lock(lk)
        s = time_ns()
        Base.unlock(lk)
        e = time_ns()
        lats[i] = e - s
    end

    lats

end

function measure_spinlock_lock(iters, throwout)
    
    lk = Base.Threads.SpinLock()
    lats = Array{Int64}(iters)

    for i=1:throwout
        s = time_ns()
        Base.lock(lk)
        e = time_ns()
        Base.unlock(lk)
        lats[i] = e - s
    end

    for i=1:iters
        s = time_ns()
        Base.lock(lk)
        e = time_ns()
        Base.unlock(lk)
        lats[i] = e - s
    end

    lats

end

function measure_spinlock_trylock(iters, throwout)
    
    lk = Base.Threads.SpinLock()
    lats = Array{Int64}(iters)

    for i=1:throwout
        s = time_ns()
        Base.trylock(lk)
        e = time_ns()
        Base.unlock(lk)
        lats[i] = e - s
    end

    for i=1:iters
        s = time_ns()
        Base.trylock(lk)
        e = time_ns()
        Base.unlock(lk)
        lats[i] = e - s
    end

    lats

end

function measure_spinlock_unlock(iters, throwout)
    
    lk = Base.Threads.SpinLock()
    lats = Array{Int64}(iters)

    for i=1:throwout
        Base.lock(lk)
        s = time_ns()
        Base.unlock(lk)
        e = time_ns()
        lats[i] = e - s
    end

    for i=1:iters
        Base.lock(lk)
        s = time_ns()
        Base.unlock(lk)
        e = time_ns()
        lats[i] = e - s
    end

    lats

end


# Semaphores

# TODO: 
function measure_sem_acquire(size, iters, throwout)

	sem = Base.Semaphore(size)
    	lats = Array{Int64}(iters)
	for  i = 1:throwout
		s = time_ns()
		Base.acquire(sem)
		e = time_ns()
		Base.release(sem)
	end
	for  i = 1:iters
		s = time_ns()
		Base.acquire(sem)
		e = time_ns()
		Base.release(sem)
		lats[i] = e-s
	end
	lats
end

# TODO: 
function measure_sem_release(iters, throwout)

	sem = Base.Semaphore(size)
    	lats = Array{Int64}(iters)
	for  i = 1:throwout
		Base.acquire(sem)
		s = time_ns()
		Base.release(sem)
		e = time_ns()
	end
	for  i = 1:iters
		Base.acquire(sem)
		s = time_ns()
		Base.release(sem)
		e = time_ns()
		lats[i] = e-s
	end
	lats
end

