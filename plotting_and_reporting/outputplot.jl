#using StatsBase 
using GR 
using StatPlots 
#using Plots 
#using Winston 
gr() 
lats = readdlm("output1.dat", '\t' , UInt64 )
println("1")
p = boxplot!([ "$(2^i)" for i = 0:1], lats[1], ylabel="latency (ns)", xlabel="Process count", outliers=true, marker=(0.5, :blue, stroke(3)), key=false)
println("2")
StatPlots.savefig(p,"plot.pdf")
#pl = plot()
