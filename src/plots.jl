## Plots.jl Recipe

@recipe function f(a::Geometry)
    
    markersize --> 4
    markerstrokewidth --> 0
        
    [(a.longitude,a.latitude)]
end

@recipe function f(A::Vector{Geometry})
    longitude = A .|> a -> a.longitude
    latitude  = A .|> a -> a.latitude
    
    aspect_ratio --> latitude_scale / longitude_scale(DefaultRefPoint.latitude)
    size --> (500,500)
    
    markersize --> 1
    markerstrokewidth --> 0
    label --> false
            
    (longitude,latitude)
end

@recipe function f(A::ConvexPolygon;type=:Geometry)
    
    size --> (500,500)
    
    markersize --> 1
    markerstrokewidth --> 0
    label --> false
    
    if type == :Geometry
        longitude = A.gvertex .|> a -> a.longitude
        latitude = A.gvertex .|> a -> a.latitude
        
        aspect_ratio --> latitude_scale / longitude_scale(DefaultRefPoint.latitude)
        
        (longitude[[1:end;1]], latitude[[1:end;1]])
    elseif type == :Planar
        x = A.pvertex .|> a -> a.x
        y = A.pvertex .|> a -> a.y

        aspect_ratio --> 1.0

        (x[[1:end;1]], y[[1:end;1]])
    end
end


@recipe function f(a::Planar)
    
    markersize --> 4
    markerstrokewidth --> 0
        
    [(a.x,a.y)]
end

@recipe function f(A::Vector{Planar})
    X = A .|> a -> a.x
    Y  = A .|> a -> a.y
    
    size --> (500,500)
    
    markersize --> 1
    markerstrokewidth --> 0
    label --> false
            
    (X,Y)
end

@recipe function f(A::Ship;type=:Geometry)

    if type == :Geometry
        @series begin

            type --> type

            A.Shape
        end
        
        
        aspect_ratio --> latitude_scale / longitude_scale(DefaultRefPoint.latitude)

        label --> false

        seriestype := :scatter
        markersize --> 5
        
        A.Geometry
    elseif type == :Planar
       @series begin

            type --> type

            A.Shape
       end 

       aspect_ratio --> 1.0

       label --> false

       seriestype := :scatter
       markersize --> 5

       A.Planar
    end
end
    