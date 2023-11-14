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

"""
`Base.:+(A::Planar,B::Planar)`

Get a composite vector of positional vectors A and B.
"""
Base.:+(A::Planar,B::Planar) = Planar(A.x+B.x,A.y+A.y)

"""
`Base.:-(A::Planar,B::Planar)`

Get a composite vector of positional vectors A and -B.
"""
Base.:-(A::Planar,B::Planar) = Planar(A.x-B.x,A.y-B.y)

"""
`Base.cos(A::Planar,B::Planar)`

Get a cosine of the angle between vectors A and B.
"""
function Base.cos(A::Planar,B::Planar)
    norm_A = sqrt(A.x^2 + A.y^2)
    norm_B = sqrt(B.x^2 + B.y^2)
    
    if norm_A == 0.0 || norm_B == 0.0
        return 0.0
    end
    
    inner_product_AB = A.x * B.x + A.y * B.y
    
    result = inner_product_AB / (norm_A * norm_B)
    
    if result > 1.0
        return 1.0
    else
        return result
    end
end

"""
`dist(A::Planar,B::Planar)`

Get the Euclid distance of A and B. 

`dist(A::Planar) = dist(A,Planar(0.0,0.0))`
"""
function dist(A::Planar,B::Planar)
    return (A.x - B.x)^2 + (A.y - B.y)^2 |> sqrt
end

dist(A::Planar) = dist(Planar(0.0,0.0),A)

"""
```julia
Base.minimum(A::Vector{Planar};dist=dist)
Base.maximum(A::Vector{Planar};dist=dist)
```


Return the element of A with the minimum (maximum) distance from the origin `Planar(0.0,0.0)`.
By default, the distance is Euclid distance.
"""
function Base.minimum(A::Vector{Planar};dist=dist)
    d = map(a -> dist(Planar(0.0,0.0),a), A)
    return A[argmin(d)]
end
function Base.maximum(A::Vector{Planar};dist=dist)
    d = map(a -> dist(Planar(0.0,0.0),a), A)
    return A[argmax(d)]
end

"""
```julia
rotate(A::Planar,θ::Real)
```
Get a Planar rotated A θ counterclockwise

"""
function rotate(a::Planar,θ::Real)
    R = [cos(θ) -sin(θ);sin(θ) cos(θ)]
    
    p = [a.x, a.y]
    
    q = R*p
    
    return Planar(q[1],q[2])
end

