#
# This file includes a set of functions which
# will be used for measuring Julia task/future/parallel
# primitives. The main idea is that these functions (excepting
# dummy(), which is the null function) perform a tunable amount
# of work
#


#
# This is a function that does no work.
# It will be used to measure the overhead of
# fine-grained tasks.
# 
function dummy()

end


# 
# recursive implementation of
# sum of first n fibonacci numbers
#
function fib(n)

	n >= 0 || return 0
	n == 1 && return 1
	n + fib(n-1)

end


#
# recursive implementation of 
# factorial(n)
#
function fac(n)

	n >= 0 || return 0
	n == 1 && return 1
	n * fac(n-1)

end


#
# Sleep-based tunable function
# @exec_time: the time this worker function 
#             will work (go to sleep)
#
function sleep_work (exec_time)

	sleep(exec_time)

end

