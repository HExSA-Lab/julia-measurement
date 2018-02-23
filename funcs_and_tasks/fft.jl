#
# KCH: implementaiton of various FFT versions
#

using PyPlot
using Distributions


function siggen(f, n)
    x = Array{Complex{Float64}}(n)
    for i in 1:n
        x[i] = complex(sin(-2*pi*f*i/n), 0.0)
    end
    return x
end

function fft_slow(xs)
    n     = length(xs)
    fd    = zeros(Complex{Float64}, n)
    for k in 1:n
        for j in 1:n
            fd[k] += complex(xs[j], 0.0) * exp(-2*pi*(k-1)*im*(j-1)/n)
        end
    end
    return fd
end


function fft_mat(xs)
    n  = length(xs)
    A = [ exp(-2*pi*im*i*j/n) for i=0:(n-1), j=0:(n-1) ]
    return A * complex(xs)
end

function fft_bfly(xs)
    ns = length(xs)

    if ns % 2 > 0
        error("array must be power of 2")
    elseif ns <= 32
        return fft_mat(xs)
    else 
        xeven = fft_bfly(xs[1:2:ns]) 
        xodd  = fft_bfly(xs[2:2:ns])
        F = [ exp(-2*pi*im*k/ns) for k=0:ns-1 ]
        # note the point-wise multiplications
        return [xeven + (F[1:div(ns,2)]    .* xodd) ; 
                xeven + (F[div(ns,2)+1:ns] .* xodd)]
    end
end

function fft_bfly_par(xs)
    ns = length(xs)

    if ns % 2 > 0
        error("array must be power of 2")
    elseif ns <= 32
        return fft_mat(xs)
    else 
        xeven = @spawn fft_bfly(xs[1:2:ns]) 
        xodd  = @spawn fft_bfly(xs[2:2:ns])
        F = [ exp(-2*pi*im*k/ns) for k=0:ns-1 ]
        # note the point-wise multiplications
        return [fetch(xeven) + (F[1:div(ns,2)]    .* fetch(xodd)) ; 
                fetch(xeven) + (F[div(ns,2)+1:ns] .* fetch(xodd))]
    end
end
    


    

    

