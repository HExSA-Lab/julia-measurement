#
# 	Plot_for_output plots output for .dat 
#	files recieved from driver.jl 
# 	@fn:  .dat output filename 
#  	@pn:  .pdf plot filename
#
#
using StatsBase
using GR
using Distributions
using StatPlots
#using Plots
#using Winston
using Gadfly
#gr()

function box_from_2d_data(fn, pn)

	lats = readdlm(fn, '\t' , UInt64 )
    count  = size(lats)[1]
    xlabels = Array{String}(count)
	aoa = Any[] 
        
	for i = 0:count-1
        
		el  = 2^i
        xlabels[i+1] = "$el"
        
	end
	
	for i = 1:count
		push!(aoa, lats[i,:])
    end

	p = boxplot!(xlabels, lats[1], ylabel="latency (ns)", xlabel="Process count", outliers=false, marker=(0.5, :blue, stroke(3)), key=false)
	StatPlots.savefig(p, pn)
end

# assumed to be for the spawn experiments
function line_from_2d_data(fn, pn, pw, ph, xlabel, ylabel)

	lats = readdlm(fn)
    count  = size(lats)[1]
    xlabels = Array{String}(count)
	aoa = Any[] 
        
	for i = 0:count-1
        
		el  = 2^i
                xlabels[i+1] = "$el"
        
	end
        
	
	for i = 1:count
		push!(aoa, lats[i,:])
    end
    
    p = Gadfly.plot(x = [0:count-1], y = lats[1], Guide.xlabel(xlabel), Guide.ylabel(ylabel), Geom.line, Guide.xticks(ticks=xlabels))
    Gadfly.draw(PDF(pn, pw, ph), p)
    
end

# 
# Creates a CDF plot based on a 1-D array of data
# points. 
#
# @fn: the file containing the data
# @pn: the plot file to output. use false to immediately show a graph
# @pw: width of the PDF plot (if generating)
# @ph: height of the PDF plot (if generating)
# xlabel: string for x axis label
# ylabel: string for y axis label
#
# example:
# cdf_from_array_data("lock.dat", "lock.pdf", 4inch, 3inch, "Latency", "CDF")
#
# TODO: option for log axis for x
# TODO: comment arguments here
#
function cdf_from_array_data(fn, pn, pw, ph, xlabel, ylabel)

    tmp = readdlm(fn)
    data = tmp[:, 1]
    p = Gadfly.plot(ecdf(data), minimum(data), maximum(data), Guide.xlabel(xlabel), Guide.ylabel(ylabel))
    if pn == false
        display(p)
    else
        Gadfly.draw(PDF(pn, pw, ph), p)
    end

end



#
# Create a QQ plot comparing sampled data against a Normal distribution with
# mean = mean of the data and stddev = 1
#
# @fn: the file containing the data
# @pn: the plot file to output. use false to immediately show a graph
# @pw: width of the PDF plot (if generating)
# @ph: height of the PDF plot (if generating)
# xlabel: string for x axis label
# ylabel: string for y axis label

# example:
# qq_from_array_data("lock.dat", "lock.pdf", 4inch, 4inch, "Normal", "Data")
#
# TODO: make the comparison distribution a parameter: e.g. Exponential, Log-norm, Norm, etc
# TODO: shouldn't always assume unit stddev 
#
function qq_from_array_data(fn, pn, pw, ph, xlabel, ylabel)

    tmp = readdlm(fn)
    data = tmp[:, 1]
    p = Gadfly.plot(x = rand(Normal(mean(data), 1), length(data)), y = data, Stat.qq, Geom.point, Guide.xlabel(xlabel), Guide.ylabel(ylabel))

    if pn == false
        display(p)
    else
        Gadfly.draw(PDF(pn, pw, ph), p)
    end

end


#	Before replotting make sure the names of plot files 
#	are different or the previous ones are deleted.
#plot_for_output("output1.dat","plot1.pdf")

#plot_for_output("output2.dat","plot2.pdf")
~
