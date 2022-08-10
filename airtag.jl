#An implementation using airtags to track an animal's location

#To use:
# - Set user and airtag to your user and airtag name. The update interval defaults to 10 seconds, but can be adjusted however you wish.
# - Open findmy to keep updating the cache
# - Run this script and call the track function

using JSON3

include("range.jl")

const user = "reed"
const airtag = "Ari"
const interval = 10

const pospath = "/Users/$(user)/Library/Caches/com.apple.findmy.fmipcore/Items.data"
const data = "positions.txt"

function savedata(d=data)
    open(d, "a") do file
        strpos = join(printpos.(positions), "\n")
        write(file, strpos)
    end
    empty!(positions)
end

function loaddata(d=data)
    data = read(d, String)
    if isempty(data)
        Timed[]
    else
        split(data, "\n") .|> function (stp)
            st, sp = split(stp; limit=2)
            t = parse(Int, st) |> Time
            p = split(sp, ","; limit=fieldcount(Position)) .|> (c -> parse(Float64, c)) |> Base.splat(Pos)
            Timed(t, p)
        end
    end
end

const positions = loaddata()

function getpos(name)
    posdata = (JSON3.read ∘ read)(pospath, String)
    tracked = (first ∘ Iterators.filter)(tracked -> tracked.name == name, posdata)
    location = tracked.location
    Position(location.longitude, location.latitude)
end

function updatepos()
    pos = getpos(airtag)
    action = if isempty(positions) || positions[end].pos ≠ pos
        push!(positions, Timed(pos))
        "Added"
    else
        positions[end].time.val += 1
        "Extended"
    end
    println("$(action) position")
end

track() = Timer(_ -> updatepos(), 0; interval=interval)
