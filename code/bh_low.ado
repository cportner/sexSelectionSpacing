// Baseline hazard for low education women

program bh_low, rclass
    args spell period

    if `spell' == 1 | `spell' == 2  {
        loc i = 1
        forvalues per = 1/19 {
            gen dur`i' = t == `per'
            loc ++i
        }
        gen dur`i' = t >= 20 & t <= 24
        loc ++i
        gen dur`i' = t >= 25
    }
    else if `spell' == 3 {
        loc i = 1
        forvalues per = 1(2)14 {
            gen dur`i' = t >= `per' & t <= `per' + 1    
            loc ++i
        }
        gen dur`i' = t >= 15 & t <= 19
        loc ++i
        gen dur`i' = t >= 20 
    }
    else if `spell' == 4 {
        loc i = 1
        forvalues per = 1(2)12 {
            gen dur`i' = t >= `per' & t <= `per' + 1    
            loc ++i
        }
        gen dur`i' = t >= 13
    }
        
    tempvar sumdur
    egen `sumdur' = rowtotal(dur*)
    assert `sumdur' == 1

    return scalar numPer = `i'

end


