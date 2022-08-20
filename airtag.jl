#An implementation using airtags to track an animal's location

#To use:
# - Variable setup:
#    - At the bottom of the page you will find three variables: user, airtags, and interval
#    - Set user to your macos username
#    - Set airtags to a list of airtags (initialized Airtag(name, positionsFilePath))
#        - Make sure to add all the storage files you referenced in the airtags to the project directory!
#    - Interval controls the how often the cache is checked, and defaults to 10 seconds. It can be adjusted however you wish.
# - Open findmy to start updating cache
# - Run this script and call track!(airtags, interval) to start tracking
# - When finished, call save!(airtags) to save the position data to their respective files
# - Load your saved data back into the program with the load(path) function, or multiple with load([paths...])

using JSON3

include("range.jl")

Base.string(p::Position) = join(coords(p), ",")
Base.parse(::Type{Position}, p::AbstractString) = split(p, ","; limit=fieldcount(Position)) .|>
                                                  (c -> parse(Float64, c)) |>
                                                  Base.splat(Position)

Base.string(t::Time) = string(t.val)
Base.parse(::Type{Time}, t::AbstractString) = parse(UInt, t) |> Time

Base.string(t::Timed) = "$(string(t.time)) $(string(t.pos))"
Base.parse(::Type{Timed}, t::AbstractString) = split(t; limit=2) |>
                                               (p -> parse.((Time, Position), p)) |>
                                               Base.splat(Timed)

Base.string(tp::Vector{Timed}) = join(string.(tp), "\n")
Base.parse(::Type{Vector{Timed}}, tps::AbstractString) = split(tps, "\n") .|>
                                                         tp -> parse(Timed, tp)

struct AirTag
    name::String
    positions::Vector{Timed}
    file::String
end

AirTag(name::String, file::String) = AirTag(name, [], "$(file).txt")

function load(path::String)::Vector{Timed}
    data = read("$(path).txt", String)
    if isempty(data)
        Timed[]
    else
        parse(Vector{Timed}, data[2:end])
    end
end

load(paths::Vector{String}) = load.(paths)

function save!(at::AirTag)
    open(at.file, "a") do io
        write(io, "\n$(string(at.positions))")
    end
    empty!(at.positions)
end

save!(ats::Vector{AirTag}) = (save!.(ats); nothing)

function getpos(name::String)
    posdata = (JSON3.read ∘ read)(findmyCache, String)
    tracked = (first ∘ Iterators.filter)(tracked -> tracked.name == name, posdata)
    location = tracked.location
    Position(location.longitude, location.latitude)
end

function updatepos(at::AirTag)
    pos = getpos(at.name)
    action = if isempty(at.positions) || at.positions[end].pos ≠ pos
        push!(at.positions, Timed(pos))
        "Added"
    else
        at.positions[end].time.val += 1
        "Extended"
    end
    println("$(action) position")
end

track!(ats::Vector{AirTag}, itv::Int) = Timer(_ -> updatepos.(ats), 0; interval=itv)

#User configurations

const user = "YOUR_USERNAME"
const interval = 10

#Ex: [AirTag("Fluffy", "positions/John"), AirTag("Spot", "positions/Spot")]
#Note: Do NOT include the file extension (.txt) in your file paths
const airtags = []

const findmyCache = "/Users/$(user)/Library/Caches/com.apple.findmy.fmipcore/Items.data"
