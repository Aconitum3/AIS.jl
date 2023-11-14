"""
Geometry is a coordinate on a geographic coordinate system.

```julia
struct Geometry
    longitude::Real
    latitude::Real
end
```
"""
struct Geometry
    longitude::Real
    latitude::Real
end

# Tokyo Bay Reference Point
const TokyoBayRefPoint = Geometry(139.0,35.0)

DefaultRefPoint = TokyoBayRefPoint

"""
Planar is a coordinate on a planar projection of Geometry with ContactPoint as a point of contanct.
In a Planar Coordinate System, the units are meters.

```julia
struct Planar
    x::Real
    y::Real
end
```
"""
struct Planar
    x::Real
    y::Real
end

"""
`Planar(G::Geometry;ContactPoint::Geometry=DefaultRefPoint)`

Return a Planar coordinate Planar(x,y) on a planar projection of G with ContactPoint as a point of contact.
By default, TokyoBayRefPoint is a DefaultRefPoint.
"""

function Planar(G::Geometry;ContactPoint::Geometry=DefaultRefPoint)
    lon_scale = longitude_scale(ContactPoint.latitude)
    x = (G.longitude - ContactPoint.longitude) * lon_scale
    y = (G.latitude - ContactPoint.latitude) * latitude_scale
    return Coordinate(x,y)
end

Base.:+(a::Planar,b::Planar) = Planar(a.x+b.x,a.y+b.y)
Base.:-(a::Planar,b::Planar) = Planar(a.x-b.x,a.y-b.y)

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

