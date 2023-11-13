"""

`Coordinate` specifies the point in terms of both x-y meter coordinates and longitude-latitude decimal coordinates.

"""
struct Coordinate
    x::Real
    y::Real
    longitude::Real
    latitude::Real
end

function Coordinate(longitude::Real,latitude::Real)
    x = (longitude - origin.longitude) * longitude_scale
    y = (latitude - origin.latitude) * latitude_scale
    return Coordinate(x,y,longitude,latitude)
end

Base.:+(a::Coordinate,b::Coordinate) = Coordinate(a.longitude+b.longitude,a.latitude+b.latitude)
Base.:-(a::Coordinate,b::Coordinate) = Coordinate(a.longitude-b.longitude,a.latitude-b.latitude)

function Base.cos(a::Coordinate,b::Coordinate)
    norm_a = sqrt(a.x^2 + a.y^2)
    norm_b = sqrt(b.x^2 + b.y^2)
    
    if norm_a == 0.0 || norm_b == 0.0
        return 0.0
    end
    
    inner_product_ab = a.x * b.x + a.y * b.y
    
    result = inner_product_ab / (norm_a * norm_b)
    
    if result > 1.0
        return 1.0
    else
        return result
    end
end

function dist(a::Coordinate,b::Coordinate)
    return (a.x - b.x)^2 + (a.y - b.y)^2 |> sqrt
end

dist(a::Coordinate) = dist(Coordinate(0.0,0.0,origin.longitude,origin.latitude),a)

function Base.minimum(A::Vector{Coordinate};dist=dist)
    d = map(a -> dist(Coordinate(0.0,0.0,origin.longitude,origin.latitude),a), A)
    return A[argmin(d)]
end

function Base.maximum(A::Vector{Coordinate};dist=dist)
    d = map(a -> dist(Coordinate(0.0,0.0,origin.longitude,origin.latitude),a), A)
    return A[argmax(d)]
end

"""
`rotate Coordinate θ counterclockwise`


"""
function rotate(a::Coordinate,θ::Real)
    R = [cos(θ) -sin(θ);sin(θ) cos(θ)]
    
    p = [a.x, a.y]
    
    q = R*p
    
    return Coordinate(q[1],q[2])
end

