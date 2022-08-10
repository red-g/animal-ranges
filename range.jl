#Contains the functions for range calculation. 
#Call the bounds function with the list of positions and times in order to get the radius and center of the range.

using StatsBase: mean, FrequencyWeights
using LinearAlgebra: norm

include("position.jl")
include("plot.jl")

splitstructs(s) = s |> eltype |> fieldnames .|> f -> getfield.(s, f)

function bounds(tp::Vector{Timed}, ran=0.9)
    (ran <= 0 || ran > 1) && throw(DomainError(ran, "Range must be greater than 0 and at most 1"))
    t, p = splitpos(tp)
    c = center(t, p)
    r = radii(p, c)
    g = grouprad(t, r)
    l = sum(t) * ran
    findrad(g, l), c
end

function splitpos(tp)
    t, p = splitstructs(tp)
    getfield.(t, :val), p
end

function center(t, p)
    fw = Ref(FrequencyWeights(t))
    c = splitstructs(p)
    mean.(c, fw)
end

radii(p, c) = p .|> coords .|> (co -> co .- c) .|> norm

function grouprad(t, r)
    groups = Dict{Float64,UInt}()
    for (tₙ, rₙ) in zip(t, r)
        groups[rₙ] = get(groups, rₙ, 0) + tₙ
    end
    groups
end

function findrad(g, l)
    i = 0
    for kₙ in g |> keys |> collect |> sort!
        i += g[kₙ]
        i < l || return kₙ
    end
    throw(ErrorException("No matching radius found"))
end