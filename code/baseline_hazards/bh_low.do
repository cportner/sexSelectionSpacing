// Baseline hazard for spell 1, g1, low
program bh_s1_g1_low, rclass

    loc i = 1
    
    forvalues per = 1/4 { // check end number originally 9
        gen dur`i' = t == `per'  // quarters
        loc i = `i' + 1
    }
    forvalues per = 5(3)17 { // originally 14
        gen dur`i' = t >= `per' & t <= `per' + 2 // 3 quarter years
        loc i = `i' + 1
    }
    gen dur`i' = t >= 20 & t <= 24
            
    tempvar sumdur
    egen `sumdur' = rowtotal(dur*)
    assert `sumdur' == 1

    return scalar numPer = `i'

end

// Baseline hazard for spell 1, g2, low
program bh_s1_g2_low, rclass

    loc i = 1
    
    forvalues per = 1/4 { // check end number originally 9
        gen dur`i' = t == `per'  // quarters
        loc i = `i' + 1
    }
    forvalues per = 5(3)17 { // originally 14
        gen dur`i' = t >= `per' & t <= `per' + 2 // 3 quarter years
        loc i = `i' + 1
    }
    gen dur`i' = t >= 20 & t <= 24

    tempvar sumdur
    egen `sumdur' = rowtotal(dur*)
    assert `sumdur' == 1

    return scalar numPer = `i'

end

// Baseline hazard for spell 1, g3, low
program bh_s1_g3_low, rclass

    loc i = 1
    
    gen dur`i' = t >= 1 & t<= 2
    loc ++i
    forvalues per = 3/4 { // check end number originally 9
        gen dur`i' = t == `per'  // quarters
        loc i = `i' + 1
    }
    forvalues per = 5(3)14 { // originally 14
        gen dur`i' = t >= `per' & t <= `per' + 2 // 3 quarter years
        loc i = `i' + 1
    }
    gen dur`i' = t >= 17 & t <= 24
                    
    tempvar sumdur
    egen `sumdur' = rowtotal(dur*)
    assert `sumdur' == 1

    return scalar numPer = `i'

end

// Baseline hazard for spell 2, g1, low
program bh_s2_g1_low, rclass

    loc i = 1
    
    forvalues per = 1(2)2 { // originally 14
        gen dur`i' = t >= `per' & t <= `per' + 1 // half years
        loc i = `i' + 1
    }
    forvalues per = 3(3)11 { // originally 14
        gen dur`i' = t >= `per' & t <= `per' + 2 // 3 quarter years
        loc i = `i' + 1
    }
    forvalues per = 12(4)13 { // originally 14
        gen dur`i' = t >= `per' & t <= `per' + 3 // 3 quarter years
        loc i = `i' + 1
    }
    gen dur`i' = t >= 16 & t <= 21
            
    tempvar sumdur
    egen `sumdur' = rowtotal(dur*)
    assert `sumdur' == 1

    return scalar numPer = `i'

end

// Baseline hazard for spell 2, g2, low
program bh_s2_g2_low, rclass

    loc i = 1
    
    gen dur`i' = t == 1  // quarters
    loc i = `i' + 1
    forvalues per = 2(2)6 { // originally 14
        gen dur`i' = t >= `per' & t <= `per' + 1 // half years
        loc i = `i' + 1
    }
    forvalues per = 8(3)16 { // originally 14
        gen dur`i' = t >= `per' & t <= `per' + 2 // 3 quarter years
        loc i = `i' + 1
    }
    gen dur`i' = t >= 17 & t <= 21
            
    tempvar sumdur
    egen `sumdur' = rowtotal(dur*)
    assert `sumdur' == 1

    return scalar numPer = `i'
    
end

// Baseline hazard for spell 2, g3, low
program bh_s2_g3_low, rclass

    loc i = 1
    
    forvalues per = 1(2)5 { // originally 14
        gen dur`i' = t >= `per' & t <= `per' + 1 // half years
        loc i = `i' + 1
    }
    forvalues per = 7(3)9 { // originally 14
        gen dur`i' = t >= `per' & t <= `per' + 2 // 3 quarter years
        loc i = `i' + 1
    }
    forvalues per = 10(4)12 { // originally 14
        gen dur`i' = t >= `per' & t <= `per' + 3 // 3 quarter years
        loc i = `i' + 1
    }
    gen dur`i' = t >= 14 & t <= 21
            
    tempvar sumdur
    egen `sumdur' = rowtotal(dur*)
    assert `sumdur' == 1

    return scalar numPer = `i'
    
end

// Baseline hazard for spell 3, g1, low
program bh_s3_g1_low, rclass

    loc i = 1
    
    forvalues per = 1(3)7 { // originally 14
        gen dur`i' = t >= `per' & t <= `per' + 2 // half years
        loc i = `i' + 1
    }
    forvalues per = 10(4)13 { // originally 14
        gen dur`i' = t >= `per' & t <= `per' + 3 // 3 quarter years
        loc i = `i' + 1
    }
    gen dur`i' = t >= 14 & t <= 24
            
    tempvar sumdur
    egen `sumdur' = rowtotal(dur*)
    assert `sumdur' == 1

    return scalar numPer = `i'

end

// Baseline hazard for spell 3, g2, low
program bh_s3_g2_low, rclass

    loc i = 1
    
    forvalues per = 1(2)9 { // originally 14
        gen dur`i' = t >= `per' & t <= `per' + 1 // half years
        loc i = `i' + 1
    }
    forvalues per = 11(3)14 { // originally 14
        gen dur`i' = t >= `per' & t <= `per' + 2 // 3 quarter years
        loc i = `i' + 1
    }
    gen dur`i' = t >= 17 & t <= 24
    
    tempvar sumdur
    egen `sumdur' = rowtotal(dur*)
    assert `sumdur' == 1

    return scalar numPer = `i'

end

// Baseline hazard for spell 3, g3, low
program bh_s3_g3_low, rclass

    loc i = 1
    
    forvalues per = 1(3)7 { // originally 14
        gen dur`i' = t >= `per' & t <= `per' + 2 // half years
        loc i = `i' + 1
    }
    forvalues per = 10(4)13 { // originally 14
        gen dur`i' = t >= `per' & t <= `per' + 3 // 3 quarter years
        loc i = `i' + 1
    }
    gen dur`i' = t >= 14 & t <= 24
    
    tempvar sumdur
    egen `sumdur' = rowtotal(dur*)
    assert `sumdur' == 1

    return scalar numPer = `i'

end

// Baseline hazard for spell 4, g1, low
program bh_s4_g1_low, rclass

    loc i = 1
    
    forvalues per = 1(3)2 { // originally 14
        gen dur`i' = t >= `per' & t <= `per' + 2 // half years
        loc i = `i' + 1
    }
    forvalues per = 4(4)8 { // originally 14
        gen dur`i' = t >= `per' & t <= `per' + 3 // half years
        loc i = `i' + 1
    }
    gen dur`i' = t >= 12 & t <= 19
    
    tempvar sumdur
    egen `sumdur' = rowtotal(dur*)
    assert `sumdur' == 1

    return scalar numPer = `i'

end

// Baseline hazard for spell 4, g2, low
program bh_s4_g2_low, rclass

    loc i = 1
    
    forvalues per = 1(3)2 { // originally 14
        gen dur`i' = t >= `per' & t <= `per' + 2 // half years
        loc i = `i' + 1
    }
    forvalues per = 4(4)8 { // originally 14
        gen dur`i' = t >= `per' & t <= `per' + 3 // half years
        loc i = `i' + 1
    }
    gen dur`i' = t >= 12 & t <= 19
    
    tempvar sumdur
    egen `sumdur' = rowtotal(dur*)
    assert `sumdur' == 1

    return scalar numPer = `i'

end

// Baseline hazard for spell 4, g3, low
program bh_s4_g3_low, rclass

    loc i = 1
    
    forvalues per = 1(3)2 { // originally 14
        gen dur`i' = t >= `per' & t <= `per' + 2 // half years
        loc i = `i' + 1
    }
    forvalues per = 4(4)8 { // originally 14
        gen dur`i' = t >= `per' & t <= `per' + 3 // half years
        loc i = `i' + 1
    }
    gen dur`i' = t >= 12 & t <= 19
    
    tempvar sumdur
    egen `sumdur' = rowtotal(dur*)
    assert `sumdur' == 1

    return scalar numPer = `i'

end


