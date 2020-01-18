// Baseline hazard for high education women

program bh_highest, rclass
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
//        forvalues per = 1(2)14 {
//            gen dur`i' = t >= `per' & t <= `per' + 1    
//            loc ++i
//        }
        forvalues per = 1/8 {
            gen dur`i' = t == `per' 
            loc ++i
        }
        gen dur`i' = t >= 9 & t <= 11
        loc ++i
        gen dur`i' = t >= 12 & t <= 14
        loc ++i
        gen dur`i' = t >= 15 & t <= 19
        loc ++i
        gen dur`i' = t >= 20 
    }
    else if `spell' == 4 {
        loc i = 1
        forvalues per = 1(2)10 {
            gen dur`i' = t >= `per' & t <= `per' + 1    
            loc ++i
        }
        gen dur`i' = t >= 11
    }

    tempvar sumdur
    egen `sumdur' = rowtotal(dur*)
    assert `sumdur' == 1

    return scalar numPer = `i'

end


