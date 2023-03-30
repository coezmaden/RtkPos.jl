function parse_stat!(df::DataFrame, s::IOStream)
    # Parse the lines of .pos.stat file
    lines =  readlines(s)
    # For now only read the $SAT messages 
    # TODO implement more parsing options
    sat_lines = split.(lines[contains.(lines, "\$SAT")], ',')
    
    for line in sat_lines
        # Timestamp
        GPS_week = line[2]
        TOW = parse(Float64, line[3])
        seconds = floor(Int, TOW)
        mseconds = floor(Int, 1e3*(TOW - seconds))
        t = GPSEPOCH + Week(GPS_week) + Second(seconds) + Millisecond(mseconds) - Second(GPSLEAP)
        push!(df.Timestamp, t)

        # PRN
        push!(df.prn, line[4])

        # Azimuth
        push!(df.az, parse(Float64, line[6]))

        # Elevation
        push!(df.el, parse(Float64, line[7]))

        # Pseudorange residual
        push!(df.prange_res, parse(Float64, line[8]))

        # Carrier phase residual
        push!(df.cphase_res, parse(Float64, line[9]))

        # SNR
        push!(df.snr, parse(Float64, line[11]))
    end

end