## Plots.jl Recipe

@recipe function f(a::Geometry)
    
    markersize --> 4
    markerstrokewidth --> 0
        
    [(a.longitude,a.latitude)]
end

@recipe function f(A::Vector{Geometry})
    longitude = A .|> a -> a.longitude
    latitude  = A .|> a -> a.latitude
    
    aspect_ratio --> longitude_scale(DefaultRefPoint.latitude) / latitude_scale
    size --> (500,500)
    
    markersize --> 1
    markerstrokewidth --> 0
    label --> false
            
    (longitude,latitude)
end

@recipe function f(A::ConvexPolygon)
    longitude = A.gvertex .|> a -> a.longitude
    latitude = A.gvertex .|> a -> a.latitude
    
    aspect_ratio --> longitude_scale(DefaultRefPoint.latitude) / latitude_scale
    size --> (500,500)
    
    markersize --> 1
    markerstrokewidth --> 0
    label --> false
    
    (longitude[[1:end;1]], latitude[[1:end;1]])
end
