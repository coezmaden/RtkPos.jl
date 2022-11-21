module RtkPos

using FileIO
using DelimitedFiles
using DataFrames
using Geodesy
using Dates
using TimeZones
using LinearAlgebra
using CategoricalArrays

include("parse_body.jl")

function load_pos(f)
    df = DataFrame(
        Timestamp = ZonedDateTime[],
        Position = ECEF[],
        Q = CategoricalValue{Int64, UInt32}[],
        ns = Int[],
        Cov = Matrix{Float64}[],
        age = Dates.CompoundPeriod[],
        ratio = Float64[]
    )
    open(f) do s
        parse_body!(df, s)
    end
    return df
end

end