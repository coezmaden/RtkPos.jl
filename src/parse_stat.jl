function parse_stat!(df::DataFrame, s::IOStream)
    # Parse the lines of .pos.stat file
    lines =  readlines(s)
    # For now only read the $SAT messages 
    # TODO implement more parsing options
    slines = split.(lines[contains.(lines, "\$SAT")], ',')
    
end