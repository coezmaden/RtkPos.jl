function parse_body!(df::DataFrame, s::IOStream)
    
    # Parse the tabularized data of the body
    tbl = readdlm(
        s,                  # IOStream
        ' ',                # Delimiter char
        skipblanks=true,    # Skipping blank lines if any
        comments=true,      # Skipping metadata lines
        comment_char='%'    # '%' defines comments in .pos files
    )

    filt_data = Matrix{Any}(undef, size(tbl,1), 15)
    for m in axes(tbl, 1)
        filt_data[m,:] = reshape(
            filter(
                x -> x != "", tbl[m,:]
            ),
            (1,15)
        )
    end

    # Add timestamps
    for datetime in ZonedDateTime.(
        Date.(filt_data[:,1], dateformat"Y/m/d") .+
        Time.(filt_data[:,2]), tz"UTC"
    )
        push!(df.Timestamp, datetime)
    end

    # Add positions
    for pos in ECEF.(filt_data[:,3], filt_data[:,4], filt_data[:,5])
        push!(df.Position, pos)
    end

    # Add quality factors
    q_factors = CategoricalArray(filt_data[:,6])
    for q in q_factors
        push!(df.Q, q)
    end

    # Add number of satellites
    for nsat in filt_data[:,7]
        push!(df.ns, nsat)
    end

    # Add covariance matrices
    # Declare three dimensional Matrices with the dims = (3, 3, num_rows(df))
    A = Array{Float64}(undef, (3, 3, size(df, 1)))
    B = Array{Float64}(undef, (3, 3, size(df, 1)))

    # Fill the sigma values
    A[1, 1, :] = filt_data[:,8]
    A[2, 2, :] = filt_data[:,9]
    A[3, 3, :] = filt_data[:,10]
    A[1, 2, :] = filt_data[:,11]
    A[1, 3, :] = filt_data[:,12]
    A[2, 3, :] = filt_data[:,13]

    # Convert the matrices to symmetric matrices
    for i in axes(A, 3)
        B[:,:,i] = Symmetric(A[:,:,i])
    end

    for covmat in eachslice(B, dims=3)
        push!(df.Cov, covmat)
    end

    # Add ages
    age_s = Dates.Second.(Int.(floor.(filt_data[:,14])))
    age_ms = Dates.Millisecond.(
        Int.(ceil.((filt_data[:,14] - floor.(filt_data[:,14])) .* 100)))
    ages = age_s + age_ms
    for age in ages
        push!(df.age, age)
    end

    # Add ratios
    for ratio in filt_data[:, 15]
        push!(df.ratio, ratio)
    end

    # Return the resulting DataFrame
    return df
end