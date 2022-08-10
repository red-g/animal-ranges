#Graphs calculated range vs data points

import Plots: plot, scatter!

function circleshape(r, (h, k))
    θ = LinRange(0, 2 * π, 500)
    h .+ r * sin.(θ), k .+ r * cos.(θ)
end

function plotdata(tp::Vector{Timed}; r=0.9)
    plot(circleshape(bounds(tp, r)...); seriestype=[:shape], aspect_ratio=1, fillalpha=0.2, legend=false)
    getfield.(tp, :pos) |> splitstructs |> Base.splat(scatter!)
end