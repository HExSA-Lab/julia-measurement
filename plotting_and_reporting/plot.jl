#
# 	Plot_for_output plots output for .dat 
#	files recieved from driver.jl 
# 	@fn:  .dat output filename 
#  	@pn:  .pdf plot filename
#
#
using StatsBase
using Distributions
using Gadfly


#
# Input data assumptions:
# Row 1 is experiment labels
# Each column has values for a single experiment. 
# Row k contains trials k for all experiments
#
function box_from_2d_data(fn, pn, pw, ph, xlabel, ylabel)

    (a, b) = readdlm(fn, header=true)
    p = Gadfly.plot(x = vec(b), y = transpose(a), Geom.boxplot, Guide.xlabel(xlabel), Guide.ylabel(ylabel))
    Gadfly.draw(PDF(pn, pw, ph), p)

end

#
# Row 1 is experiment labels
# Each column has values for a single experiment. 
# Row k contains trials k for all experiments
#
function line_wbars_from_2d_data(fn, pn, pw, ph, xlabel, ylabel)

    (a, b) = readdlm(fn, header=true)
    ys = [mean(a[:, i]) for i=1:size(a, 2)]
    stds = [std(a[:, i]) for i=1:size(a, 2)]
    top_bars = ys .+ (stds / sqrt(length(ys)))
    bot_bars = ys .- (stds / sqrt(length(ys)))

    p = Gadfly.plot(x = vec(b), y = vec(ys), ymin=bot_bars, ymax=top_bars, Geom.line, Geom.errorbar, Guide.xlabel(xlabel), Guide.ylabel(ylabel))
    Gadfly.draw(PDF(pn, pw, ph), p)
end

# 
# Assumes 2 rows in data file. First is header values. Second is y values
#
function line_from_1d_data(fn, pn, pw, ph, xlabel, ylabel)

	(yvals, xvals) = readdlm(fn, header=true)
    
    # Gadfly expects a column vector, hence the calls to vec()
    Gadfly.plot(x = vec(xvals), y = vec(yvals), Guide.xlabel(xlabel), Guide.ylabel(ylabel), Geom.line)
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
