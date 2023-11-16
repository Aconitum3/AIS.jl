"""
`extractEdge(P::Vector{Planar})`

get edge of P. `P[i]` is an edge candigate if `P[i]` satisfies `cos(P[i],P[i-1])<0`

Edge is the pair that maximize Euclid distance in edge candigates.

"""
function extractEdge(P::Vector{Planar})
    n = length(P)
    edge_candigate = [cos(P[i] - P[i-1],P[i-1] - P[i-2]) for i in 3:n] |> x -> findall(x.<0) .+ 1

    if length(edge_candigate) < 2
        return nothing
    end
    
    edge = dist(P[edge_candigate]) |> x -> argmax(x) |> x -> [edge_candigate[x[1]],edge_candigate[x[2]]]
    return P[edge]
end

"""
`estimateBasePoint(P::Vector{Planar};d=100,returnMid=false)`

Get a vertex of the isosceles triangle whose base is side of `extractEdge(P::Vector{Planar})` and height is `d`.

Return the mid point of the triangle base if `returnMid=true`.

"""
function estimateBasePoint(P::Vector{Planar};d=100,returnMid=false)
    n = length(P)
    ap_rotated = nothing
    
    # get edge
    edge = getedge(P)
    if isnothing(edge)
        return nothing
    end
    
    # localize x-axis (rotation)
    a = edge[2] - edge[1] |> p -> p.y / p.x
    θ = atan(a)

    P_rotated = rotate.(P,-θ)
    edge_rotated = rotate.(edge,-θ)
    mid_rotated = mean(edge_rotated)    

    # base point direction
    upper_n = length(P_rotated[(P_rotated .|> p -> p.y) .> mid_rotated.y])
    lower_n = length(P_rotated[(P_rotated .|> p -> p.y) .< mid_rotated.y])
    
    if upper_n >= lower_n
        ap_rotated = Planar(mid_rotated.x,mid_rotated.y - d)
    else
        ap_rotated = Planar(mid_rotated.x,mid_rotated.y + d)
    end

    # return mid
    if returnMid
        return (;mid=mean(edge),ap=rotate(ap_rotated,θ))
    end
    
    return rotate(ap_rotated,θ)
end


"""
`AngleFromBasePoint(P::Vector{Planar};d=100)`

get vector of angle between the vertex of `estimateBasePoint` and `P[i]`.
Strictry, Angle at the vartex V of a triangle consisting of three points V, P[i], and the mid point of triangle base. 
"""
function AngleAnchoringPoint(P::Vector{Planar};d=100)
    BP = estimateBasePoint(P,d=d,returnMid=true)
    
    if isnothing(BP)
        return nothing
    end
    
    APvec = BP.mid - BP.ap    
    
    V = P .- BP.ap
    θ = [cos(APvec,v) |> x -> floor(x,digits=5) |> acos; for v in V]
    
    return θ
end