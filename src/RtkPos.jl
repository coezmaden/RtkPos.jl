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
include("parse_stat.jl")

GPSEPOCH = DateTime(1980, 1, 6, 0, 0, 0)
GPSLEAP = 18

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

function load_pos_stat(f)
    df = DataFrame(
        Timestamp = DateTime[],
        prn = String[],
        az = Float64[],
        el = Float64[]
        # prange_res = Float64[],
        # cphase_res = Float64[],
        # valid = Bool[],
        # SNR = Float64[],
        # fix = Int64[],
        # slip = Int64[],
        # lock = Int64[],
        # outc = Int64[],
        # slipc = Int64[],
        # rejc = Int64[],
        # icbias = Float64[],
        # bias = Float64[],
        # bias_var = Float64[],
        # lambda = Float64[]
    )
    open(f) do s
        parse_stat!(df, s)
    end
    return df
end

end