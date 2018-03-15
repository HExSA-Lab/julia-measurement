using StatsBase
using Gadfly
using Distributions 
using ColorBrewer


# Creates a CDF plot based on a array of data files with 1-d arrays 


# @params 
# @files : Array with a list of file names
#	eg.  files = ["mutex_lock.dat", "spinlock_lock.dat", "relock_lock.dat"]
# @pn : the plot file to outpit 
# @pw : width of the pdf plot(if generating)
# @ph : height of the PDF plot (if generating)
# @xlabel : string for x axis label 
# @ylabel : string for y axis label 


function draw_cdf_multiple_files(files, pn, pw, ph, xl, yl)
	
	nfiles = length(files)
	ar  = Array{Array{Float64}}(nfiles)
	
	for i = 1: nfiles
		temp = readdlm(files[i])
		ar[i] = temp[:,1]
	end
	
	if nfiles < 3
		colors = palette("Set1", 3);
	else 
		colors = palette("Set1",nfiles);
	end
	
	# pattern set
	 pset = [:solid, :dash, :dot, :dashdot, :dashdotdot, :dashdotdash, :dotdashdash, :gapdash, :gapdot]
	
	# layer set
	layers = [layer(
		ecdf(ar[i]),
		minimum(ar[i]),
		maximum(ar[i]),
		Theme(line_style = pset[i], default_color = colors[i], line_width = 1mm))
		for i in  1:nfiles];
	p = Gadfly.plot(layers... , Guide.xlabel(xl), Guide.ylabel(yl))

	if pn == false
		display(p)
	else
		Gadfly.draw(PDF(pn,pw,ph),p)
	end

end

# Creates a Line with error bars plot 
# based on a 2-D array of multiple data files
#
# @params 
# @files : Array with a list of file names
#  eg.  files = ["mutex_lock.dat", "spinlock_lock.dat", "relock_lock.dat"]
# @pn : the plot file to outpit 
# @pw : width of the pdf plot(if generating)
# @ph : height of the PDF plot (if generating)
# @xaxis :  array of x-axis
# @xlabel : string for x axis label 
# @ylabel : string for y axis label 
#

function line_wbars_from_2d_multiple_files(files, pn, pw , ph, xaxis, xlabel , ylabel)


	nfiles  = length(files)
	
	# Add array of means of all columns from each file
	#  into a array. This array will be an array of arrays.
	
	plot_means = Array{Array{Float64}}(nfiles)

	# Add arrays of std devs of all columns from each file
	#  into an array. This array will also be an array of arrays.

	plot_stdvs = Array{Array{Float64}}(nfiles)

	# Add arrays of top and bottom bars of all columns from each file
	#  into an array. This array will also be an array of arrays.

	top_bars = Array{Array{Float64}}(nfiles)
	bot_bars = Array{Array{Float64}}(nfiles)


	for i = 1:nfiles

		# Take out multi-array data from multiple files

		arrays_in_file =  readdlm(files[i])
		arrays_in_file = transpose(arrays_in_file)
		rows_x_cols = size(arrays_in_file)
		rows = rows_x_cols[1]
		cols = rows_x_cols[2]
		mean_per_col = Array{Float64}(cols)
		std_per_col = Array{Float64}(cols)
		for j = 1 :cols
			a = arrays_in_file[:,j]
			mean_per_col[j] = mean(a)
			std_per_col[j] = std(a)
		end
		plot_means[i] = mean_per_col
		plot_stdvs[i] = std_per_col
		top_bars[i] = plot_means[i] .+ (plot_stdvs[i]/ sqrt(cols))
		bot_bars[i] = plot_means[i] .- (plot_stdvs[i]/ sqrt(cols))
	end
	#set patterns set
	#set layers set 
	#plot
	if nfiles < 3
		colors = palette("Set1", 3);
	else 
		colors = palette("Set1",nfiles);
	end

	# pattern set
	 pset = [:solid, :dash, :dot, :dashdot, :dashdotdot, :dashdotdash, :dotdashdash, :gapdash, :gapdot]
	
	# layer set
	layers = [layer(
		x = xaxis,
		y = plot_means[i],
		ymin = top_bars[i],
		ymax = bot_bars[i],
		Geom.point,
		Geom.line,
		Geom.errorbar,
		Theme(line_style = pset[i], default_color = colors[i], line_width = 1mm))
	        for i in  1:nfiles];
	p = Gadfly.plot(layers... , Guide.xlabel(xlabel), Guide.ylabel(ylabel))

	if pn == false
		display(p)
	else
		Gadfly.draw(PDF(pn,pw,ph),p)
	end
	
end


# Creates a boxplot 
# based on a 2-D array of multiple data files
#
# @params 
# @files : Array with a list of file names
#  eg.  files = ["mutex_lock.dat", "spinlock_lock.dat", "relock_lock.dat"]
# @pn : the plot file to outpit 
# @pw : width of the pdf plot(if generating)
# @ph : height of the PDF plot (if generating)
# @xaxis :  array of x-axis
# @xlabel : string for x axis label 
# @ylabel : string for y axis label 
#
function box_plot_from_2d_data_multiple_files(files, pn, pw, ph, xaxis, xlabel, ylabel)

	# Take out multi-array data from multiple files
	nfiles  = length(files)
	plot_file = Array{Array{Float64}}(nfiles)
	for i = 1:nfiles
		arrays_in_files =  readdlm(files[i])
		arrays_in_files = transpose(arrays_in_files)
		rows_x_cols = size(arrays_in_files)
		rows = rows_x_cols[1]
		cols = rows_x_cols[2]
		temp = Array{Float64}(rows)
		for j = 1 : cols
			temp   = arrays_in_files[:,j]
		end
		plot_file[i] =temp
	end

	#set patterns set
	#set layers set 
	#plot
	if nfiles < 3
		colors = palette("Set1", 3);
	else 
		colors = palette("Set1",nfiles);
	end
	
	# pattern set
	 pset = [:solid, :dash, :dot, :dashdot, :dashdotdot, :dashdotdash, :dotdashdash, :gapdash, :gapdot]
	
	# layer set
	layers = [layer(
		x = xaxis,
		y = plot_file[i],
		Geom.boxplot,
		Theme(line_style = pset[i], default_color = colors[i], line_width = 1mm))
	        for i in  1:nfiles];
	p = Gadfly.plot(layers... , Guide.xlabel(xlabel), Guide.ylabel(ylabel))

	if pn == false
		display(p)
	else
		Gadfly.draw(PDF(pn,pw,ph),p)
	end
	

end

