using StatsBase
using Gadfly
using Distributions 
using ColorBrewer

#Input data
#file 1 @f1
#file 2 @f2
#file 3(optional)@f3
#plotfile name @pn

function draw_splatted_layers(files, pn, pw, ph, xl, yl)
	#array of dat
	nfiles = length(files)
	ar  = Array{Array{Int64}}(nfiles)
	for i = 1: nfiles
		temp = readdlm(files[i])
		ar[i] = temp[:,1]
	end
	#color pallette
	colors = palette("Set1", nfiles);
	# pattern set
	 pset = [:solid, :dash, :dot, :dashdot, :dashdotdot, :dashdotdash, :dotdashdash, :gapdash, :gapdot]
	# layer set
	
	layers = [layer(
		ecdf(ar[i]),
		minimum(ar[i]),
		maximum(ar[i]),
		Theme(line_style = pset[i], default_color = colors[i], line_width = 1mm))
		for i in  1:nfiles	];
	p = Gadfly.plot(layers... , Guide.xlabel(xl), Guide.ylabel(yl))

	if pn == false
		display(p)
	else
		Gadfly.draw(PDF(pn,pw,ph),p)
	end

end
