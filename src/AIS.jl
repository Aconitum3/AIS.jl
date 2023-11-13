module AIS

import Base: +,-,cos,minimum,maximum

"""
This package is only valid around the origin!
"""

# Tokyo Bay origin
const origin = (;longitude=139.0,latitude=35.0)

# Latitude, Longitude scale ( m / 1.0° )
const longitude_scale = 91_000
const latitude_scale = 111_000

# type system
include("common.jl")

end
