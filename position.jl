#Structs to indicate the position and time of the tracked animal. 
#Can be easily extended by adding or removing coordinates to position struct.

struct Position
    x::Float64
    y::Float64
end

coords(p::Position) = getfield.(Ref(p), fieldnames(Position))

mutable struct Time
    val::UInt
end

struct Timed
    time::Time
    pos::Position
end

Timed(pos) = Timed(Time(1), pos)