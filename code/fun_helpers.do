// Helper functions 

// Creates a variable ("group") split into time periods
program create_groups 
    version 13
    args born_year
    gen     group = 1 if `born_year' <= 84
    replace group = 2 if `born_year' >= 85  & `born_year' <= 94
    replace group = 3 if `born_year' >= 95  & `born_year' <= 104
    replace group = 4 if `born_year' >= 105 
end
