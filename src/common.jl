"""
Geometry is a coordinate on the geographic coordinate system.

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
Planar is a coordinate on the planar projection of Geometry with ContactPoint as a point of contanct.
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

Return a Planar coordinate Planar(x,y) on the planar projection of G with ContactPoint as a point of contact.
By default, TokyoBayRefPoint is a DefaultRefPoint.
"""
function Planar(G::Geometry;ContactPoint::Geometry=DefaultRefPoint)
    lon_scale = longitude_scale(ContactPoint.latitude)
    x = (G.longitude - ContactPoint.longitude) * lon_scale
    y = (G.latitude - ContactPoint.latitude) * latitude_scale
    return Planar(x,y)
end

function Geometry(P::Planar;ContactPoint::Geometry=DefaultRefPoint)
    lon_scale = longitude_scale(ContactPoint.latitude)
    lon = (P.x / lon_scale) + ContactPoint.longitude
    lat = (P.y / latitude_scale) + ContactPoint.latitude
    return Geometry(lon,lat)
end

"""
`Base.:+(A::Planar,B::Planar)`

Get a composite vector of positional vectors A and B.
"""
Base.:+(A::Planar,B::Planar) = Planar(A.x+B.x,A.y+B.y)

"""
`Base.:-(A::Planar,B::Planar)`

Get a composite vector of positional vectors A and -B.
"""
Base.:-(A::Planar,B::Planar) = Planar(A.x-B.x,A.y-B.y)

"""
`mean(P::Vector{Planar})`

Get a mean vector of P.
"""
function mean(P::Vector{Planar})
    n = length(P)
    S = sum(P)
    return Planar(S.x/n, S.y/n)
end

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

`dist(P::Vector{Planar})`

Get the Euclid distance matrix of each element of P
"""
function dist(A::Planar,B::Planar)
    return (A.x - B.x)^2 + (A.y - B.y)^2 |> sqrt
end

dist(A::Planar) = dist(Planar(0.0,0.0),A)

function dist(P::Vector{Planar})
    n = length(P)
    DMat = zeros(n,n)
    for i in 1:n
        for j in i+1:n
            DMat[i,j] = dist(P[i],P[j])
        end
    end
    return Symmetric(DMat)
end

"""
```julia
Base.minimum(A::Vector{Planar};dist=dist)
```

Return the element of A with the minimum distance from the origin `Planar(0.0,0.0)`.
By default, the distance is Euclid distance.
"""
function Base.minimum(A::Vector{Planar};dist=dist)
    d = map(a -> dist(Planar(0.0,0.0),a), A)
    return A[argmin(d)]
end

"""
```julia
Base.maximum(A::Vector{Planar};dist=dist)
```

Return the element of A with the maximum distance from the origin `Planar(0.0,0.0)`.
By default, the distance is Euclid distance.
"""
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

"""
ConvexPolygon is a convex polygon on planar and geographic coordinate system.
`ConvexPolygon.gvertex` is vertexes of the convex polygon on the geographic coordinate system. 
`ConvexPolygon.pvertex` is vertexes of the convex polygon on the planar coordinate system.

```
struct ConvexPolygon
    gvertex::Vector{Geometry}
    pvertex::Vector{Planar}
end
```

`ConvexPolygon(G::Vector{Geometry}) = ConvexPolygon(G,Planar.(G))`

"""
struct ConvexPolygon
    gvertex::Vector{Geometry}
    pvertex::Vector{Planar}
end

function ConvexPolygon(gvertex::Vector{Geometry})
    pvertex = Planar.(gvertex)
    return ConvexPolygon(gvertex,pvertex)
end

function ConvexPolygon(pvertex::Vector{Planar})
    gvertex = Geometry.(pvertex)
    return ConvexPolygon(gvertex,pvertex)
end

Base.:+(CP::ConvexPolygon,G::Geometry) = ConvexPolygon(map(g -> g + G, CP.gvertex))
Base.:-(CP::ConvexPolygon,G::Geometry) = ConvexPolygon(map(g -> g - G, CP.gvertex))

Base.:+(CP::ConvexPolygon,P::Planar) = ConvexPolygon(map(p -> p + P, CP.pvertex))
Base.:-(CP::ConvexPolygon,P::Planar) = ConvexPolygon(map(p -> p - P, CP.pvertex))

rotate(CP::ConvexPolygon,θ) = ConvexPolygon(rotate.(CP.pvertex,θ))

"""
`CrossProduct(A::Geometry,B::Geometry,C::Geometry)`

Get a cross product of B-A and C-A.
"""
CrossProduct(a::Geometry,b::Geometry,c::Geometry) = (b.longitude - a.longitude)*(c.latitude - a.latitude) - (b.latitude - a.latitude)*(c.longitude - a.longitude)

"""
`CrossProduct(A::Planar,B::Planar,C::Planar)`

Get a cross product of B-A and C-A.
"""
CrossProduct(a::Planar,b::Planar,c::Planar) = (b.x - a.x)*(c.y - a.y) - (b.y - a.y)*(c.x - a.x)

"""

`InOutJudge(A::ConvexPolygon,x::Geometry)`

Return `true` if x is in A.
"""
function InOutJudge(A::ConvexPolygon,x::Geometry)
    n = length(A.gvertex)
    vertex = A.gvertex[[1:end;1]]
    
    flag₀ = CrossProduct(vertex[1],x,vertex[2]) |> sign
    
    for i in 1:n
        flag₁ = CrossProduct(vertex[i],x,vertex[i+1]) |> sign
        if flag₀*flag₁ < 0
            return false
        end
        flag₀ = flag₁
    end
    return true
end

"""

`InOutJudge(A::ConvexPolygon,x::Planar)`

Return `true` if x is in A.
"""
function InOutJudge(A::ConvexPolygon,x::Planar)
    n = length(A.pvertex)
    vertex = A.pvertex[[1:end;1]]
    
    flag₀ = CrossProduct(vertex[1],x,vertex[2]) |> sign
    
    for i in 1:n
        flag₁ = CrossProduct(vertex[i],x,vertex[i+1]) |> sign
        if flag₀*flag₁ < 0
            return false
        end
        flag₀ = flag₁
    end
    return true
end