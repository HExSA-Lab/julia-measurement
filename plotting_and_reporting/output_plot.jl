#
# 	Plot_for_output plots output for .dat 
#	files recieved from driver.jl 
# 	@fn:  .dat output filename 
#  	@pn:  .pdf plot filename
#
#
#using StatsBase
using GR
using StatPlots
#using Plots
#using Winston
gr()

function plot_for_output(fn, pn)

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

#	Before replotting make sure the names of plot files 
#	are different or the previous ones are deleted.
	
#plot_for_output("output1.dat","plot1.pdf")

#plot_for_output("output2.dat","plot2.pdf")
~
