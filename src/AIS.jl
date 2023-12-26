module AIS

import Base: +,-,cos,minimum,maximum

using LinearAlgebra
using LibPQ
using Plots

# latitude, longitude scale (m)
const latitude_scale = 111_000

const equatorial_radius = 6_378_137
const flattening = 1/(298.257_222_101)
const eccentricity = sqrt(flattening*(2-flattening))
longitude_scale(latitude) = π/180 * equatorial_radius * cos(latitude * π/180) / sqrt(1-eccentricity^2 * sin(latitude * π/180)^2)


# type system
include("common.jl")
include("shipstruct.jl")

# plot.jl recipe
include("plots.jl")
# angle tools  DEPRECATED
#include("angletools.jl")
# PostgreSQL tools
include("PQUtils.jl")

export Geometry, Planar, ConvexPolygon, Ship
export mean, dist, rotate, InOutJudge
# export cosFromBasePoint 

end

