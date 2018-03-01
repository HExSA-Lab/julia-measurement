#using StatsBase
using GR
using StatPlots
#using Plots
#using Winston
gr()
function plot_for_output(fn,pn)
        lats = readdlm(fn, '\t' , UInt64 )
        count  = size(lats)[1]
        p  = Any
        x = []
        for i = 1:count
                el  = 2^i
                push!(x, el)
        end
        for i= 1:count
                row = lats[i,:]
                x_axis = convert(Array{Int64},x)
                y_axis = convert(Array{UInt64,1}, row)
                p = boxplot!( x_axis, y_axis , ylabel="latency (ns)", xlabel="Process count", outliers=false, marker=(0.5, :blue, stroke(3)), key=false)
        end
        StatPlots.savefig(p,pn)
end
plot_for_output("output1.dat","plot1.pdf")
plot_for_output("output2.dat","plot2.pdf")
~
