# measure Base.Thread.Atomic functions 
# TODO: Ideally we'd fac_or out a lot of this measurement code
# but we need to be careful with (1) the different semantics among
# the measured primitives_and (2) proper timing placement, esp. if 
# we're going to switch to RDTSC later on.

#
# measure Base.Thread.Atomic functions :  set 
#
# @params
# @throwout : number of iterations to throw out 
# @iters : number of iterations 
#
function measure_atomic_set(iters, throwout)
    
    x = Base.Threads.Atomic{Int}(0)
    lats = Array{Int64}(iters)

    for i=1:throwout
        s = time_ns()
        x[] = 1
        e = time_ns()
        x[] = 0
        lats[i] = e - s
    end

    for i=1:iters
        s = time_ns()
        x[] = 1
        e = time_ns()
        x[] = 0
        lats[i] = e - s
    end

    lats

end


#
# measure Base.Thread.Atomic functions : compare_and set 
#
# @params
# @throwout : number of iterations to throw out 
# @iters : number of iterations 
# @def	:  initial value
# @compare : value to compare with initial value
# @set  : value to set if  @def equals @compare
#
function measure_atomic_cas(throwout, iters, def, compare, set)

	macas =  Array{Int64}(iters)
	x = Threads.Atomic{Int}(def)

	for i = 1: throwout
	
		s = time_ns()
		Threads.atomic_cas!(x,compare,set)
		e = time_ns()
		macas[i] = e - s
	
	end
	
	for i = 1: iters
	
		s = time_ns()
		Threads.atomic_cas!(x,compare,set)
		e = time_ns()
		macas[i] = e - s
	
	end
	macas
end

#
# measure Base.Thread.Atomic functions : exchange 
#
# @params
# @throwout : number of iterations to throw out 
# @iters : number of iterations 
# @def	:  initial value
# @newval: value to exchange initial value with 
#


function measure_atomic_xchng(throwout, iters, def , newval)

	m_xchng =  Array{Int64}(iters)
	x = Threads.Atomic{Int}(def)

	for i = 1: throwout
	
		s = time_ns()
		Threads.atomic_xchg!(x,newval)
		e = time_ns()
		m_xchng[i] = e - s
	
	end
	
	for i = 1: iters
	
		s = time_ns()
		Threads.atomic_xchg!(x,newval)
		e = time_ns()
		m_xchng[i] = e - s
	
	end
	m_xchng
end

##
# measure Base.Thread.Atomic functions :_add 
#
# @params
# @throwout : number of iterations to throw out 
# @iters : number of iterations 
# @def	:  initial value
# @newval: value to_add to  initial value  
#
function measure_atomic_add(throwout, iters, def , newval)

	lat =  Array{Int64}(iters)
	x = Threads.Atomic{Int}(def)

	for i = 1: throwout
	
		s = time_ns()
		Threads.atomic_add!(x,newval)
		e = time_ns()
		lat[i] = e - s
	
	end
	
	for i = 1: iters
	
		s = time_ns()
		Threads.atomic_add!(x,newval)
		e = time_ns()
		lat[i] = e - s
	
	end
	lat
end


#
# measure Base.Thread.Atomic functions :_subtract 
#
# @params
# @throwout : number of iterations to throw out 
# @iters : number of iterations 
# @def	:  initial value
# @newval: value to_subtarct from  initial value  
#
function measure_atomic_subtract(throwout, iters, def , newval)

	lat =  Array{Int64}(iters)
	x = Threads.Atomic{Int}(def)

	for i = 1: throwout
	
		s = time_ns()
		Threads.atomic_sub!(x,newval)
		e = time_ns()
		lat[i] = e - s
	
	end
	
	for i = 1: iters
	
		s = time_ns()
		Threads.atomic_sub!(x,newval)
		e = time_ns()
		lat[i] = e - s
	
	end
	lat
end

#
# measure Base.Thread.Atomic functions : or 
#
# @params
# @throwout : number of iterations to throw out 
# @iters : number of iterations 
# @def	:  initial value
# @newval: value to_or initial value with 
#
function measure_atomic_or(throwout, iters, def , newval)

	lat =  Array{Int64}(iters)
	x = Threads.Atomic{Int}(def)

	for i = 1: throwout
	
		s = time_ns()
		Threads.atomic_or!(x,newval)
		e = time_ns()
		lat[i] = e - s
	
	end
	
	for i = 1: iters
	
		s = time_ns()
		Threads.atomic_or!(x,newval)
		e = time_ns()
		lat[i] = e - s
	
	end
	lat
end

#
# measure Base.Thread.Atomic functions : and 
#
# @params
# @throwout : number of iterations to throw out 
# @iters : number of iterations 
# @def	:  initial value
# @newval: value to_and initial value with 
#
function measure_atomic_and(throwout, iters, def , newval)

	lat =  Array{Int64}(iters)
	x = Threads.Atomic{Int}(def)

	for i = 1: throwout
	
		s = time_ns()
		Threads.atomic_and!(x,newval)
		e = time_ns()
		lat[i] = e - s
	
	end
	
	for i = 1: iters
	
		s = time_ns()
		Threads.atomic_and!(x,newval)
		e = time_ns()
		lat[i] = e - s
	
	end
	lat
end

#
# measure Base.Thread.Atomic functions : xor 
#
# @params
# @throwout : number of iterations to throw out 
# @iters : number of iterations 
# @def	:  initial value
# @newval: value to _or initial value with 
#
function measure_atomic_xor(throwout, iters, def , newval)

	lat =  Array{Int64}(iters)
	x = Threads.Atomic{Int}(def)

	for i = 1: throwout
	
		s = time_ns()
		Threads.atomic_xor!(x,newval)
		e = time_ns()
		lat[i] = e - s
	
	end
	
	for i = 1: iters
	
		s = time_ns()
		Threads.atomic_xor!(x,newval)
		e = time_ns()
		lat[i] = e - s
	
	end
	lat
end

#
# measure Base.Thread.Atomic functions : nand 
#
# @params
# @throwout : number of iterations to throw out 
# @iters : number of iterations 
# @def	:  initial value
# @newval: value to nand initial value with 
#
function measure_atomic_nand(throwout, iters, def , newval)

	lat =  Array{Int64}(iters)
	x = Threads.Atomic{Int}(def)

	for i = 1: throwout
	
		s = time_ns()
		Threads.atomic_nand!(x,newval)
		e = time_ns()
		lat[i] = e - s
	
	end
	
	for i = 1: iters
	
		s = time_ns()
		Threads.atomic_nand!(x,newval)
		e = time_ns()
		lat[i] = e - s
	
	end
	lat
end

#
# measure Base.Thread.Atomic functions : max 
#
# @params
# @throwout : number of iterations to throw out 
# @iters : number of iterations 
# @def	:  initial value
# @newval: value to compare maximum initial value with 
#
function measure_atomic_max(throwout, iters, def , newval)

	lat =  Array{Int64}(iters)
	x = Threads.Atomic{Int}(def)

	for i = 1: throwout
	
		s = time_ns()
		Threads.atomic_max!(x,newval)
		e = time_ns()
		lat[i] = e - s
	
	end
	
	for i = 1: iters
	
		s = time_ns()
		Threads.atomic_max!(x,newval)
		e = time_ns()
		lat[i] = e - s
	
	end
	lat
end

#
# measure Base.Thread.Atomic functions : min 
#
# @params
# @throwout : number of iterations to throw out 
# @iters : number of iterations 
# @def	:  initial value
# @newval: value to compare minimum initial value with 
#
function measure_atomic_min(throwout, iters, def , newval)

	lat =  Array{Int64}(iters)
	x = Threads.Atomic{Int}(def)

	for i = 1: throwout
	
		s = time_ns()
		Threads.atomic_min!(x,newval)
		e = time_ns()
		lat[i] = e - s
	
	end
	
	for i = 1: iters
	
		s = time_ns()
		Threads.atomic_min!(x,newval)
		e = time_ns()
		lat[i] = e - s
	
	end
	lat
end
