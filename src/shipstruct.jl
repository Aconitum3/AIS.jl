"""
Ship is a ConvexPolygon that have a center point on planar and geographic coordinate system.
`Ship.Shape` is the shape of the ship. It's like a home base. 
`Ship.Geometry` is a center point on geographic coordinate system.
`Ship.Planar` is a center point on planar coordinate system.

```
struct Ship
    Shape::ConvexPolygon
    Geometry::Geometry
    Planar::Planar
end
```

`TrueHeading` specifies the direction of the bow.
`RefPoint` specifies the shape of the ship. 
`RefPoint` is given in the form 'a-b-c-d' and 'a' is the length of the upper side from the anntena.
'b' is the lower size, 'c' is the left side and 'd' is the right side.
`edge_param` specifies the sharpness of the bow of the ship.
```
Ship(P::Planar,TrueHeading,RefPoint;edge_param=0.9)
````

"""
struct Ship
    Shape::ConvexPolygon
    Geometry::Geometry
    Planar::Planar
end

function Ship(P::Planar,TrueHeading,RefPoint::String;edge_param=0.9)
    a,b,c,d = split(RefPoint,"-") .|> m -> parse(Int32,m)
    θ = TrueHeading * π/180

    pvertex = [Planar(-c,-b),Planar(-c,edge_param*(a+b)-b),Planar(-c/2 + d/2,a),Planar(d,edge_param*(a+b)-b),Planar(d,-b)]
    Shape = ConvexPolygon(pvertex) |> CP -> rotate(CP,-θ) |> CP -> CP + P # <= ERROR POINT!!
    
    return Ship(Shape,Geometry(P),P)
end
    

