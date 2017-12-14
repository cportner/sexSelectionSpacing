// Baseline hazard for spell 1, g1, high
program bh_s1_g1_high, rclass

    loc i = 1
    
    forvalues per = 1/5 { // check end number originally 9
        gen dur`i' = t == `per'  // quarters
        loc i = `i' + 1
    }
    forvalues per = 6(2)12 { // originally 14
        gen dur`i' = t >= `per' & t <= `per' + 1 // half years
        loc i = `i' + 1
    }
    forvalues per = 14(3)19 { // originally 14
        gen dur`i' = t >= `per' & t <= `per' + 2 // 3 quarter years
        loc i = `i' + 1
    }
    gen dur`i' = t >= 20 & t <= 24
            
    tempvar sumdur
    egen `sumdur' = rowtotal(dur*)
    assert `sumdur' == 1

    return scalar numPer = `i'

end

// Baseline hazard for spell 1, g2, high
program bh_s1_g2_high, rclass

    loc i = 1
    
    forvalues per = 1/5 { // check end number originally 9
        gen dur`i' = t == `per'  // quarters
        loc i = `i' + 1
    }
    forvalues per = 6(2)12 { // originally 14
        gen dur`i' = t >= `per' & t <= `per' + 1 // half years
        loc i = `i' + 1
    }
    gen dur`i' = t >= 14 & t <= 18
    loc ++i
    gen dur`i' = t >= 19 & t <= 24            

    tempvar sumdur
    egen `sumdur' = rowtotal(dur*)
    assert `sumdur' == 1

    return scalar numPer = `i'

end

// Baseline hazard for spell 1, g3, high
program bh_s1_g3_high, rclass

    loc i = 1
    
    forvalues per = 1/5 { // check end number originally 9
        gen dur`i' = t == `per'  // quarters
        loc i = `i' + 1
    }
    forvalues per = 6(2)10 { // originally 14
        gen dur`i' = t >= `per' & t <= `per' + 1 // half years
        loc i = `i' + 1
    }
    gen dur`i' = t >= 12 & t <= 24
                    
    tempvar sumdur
    egen `sumdur' = rowtotal(dur*)
    assert `sumdur' == 1

    return scalar numPer = `i'

end

// Baseline hazard for spell 2, g1, high
program bh_s2_g1_high, rclass

    loc i = 1
    
    forvalues per = 1(3)4 { // originally 14
        gen dur`i' = t >= `per' & t <= `per' + 2 // half years
        loc i = `i' + 1
    }
    forvalues per = 7(4)11 { // originally 14
        gen dur`i' = t >= `per' & t <= `per' + 3 // 3 quarter years
        loc i = `i' + 1
    }
    gen dur`i' = t >= 15 & t <= 21
            
    tempvar sumdur
    egen `sumdur' = rowtotal(dur*)
    assert `sumdur' == 1

    return scalar numPer = `i'

end

// Baseline hazard for spell 2, g2, high
program bh_s2_g2_high, rclass

    loc i = 1
    
    forvalues per = 1(2)5 { // originally 14
        gen dur`i' = t >= `per' & t <= `per' + 1 // half years
        loc i = `i' + 1
    }
    forvalues per = 7(3)13 { // originally 14
        gen dur`i' = t >= `per' & t <= `per' + 2 // 3 quarter years
        loc i = `i' + 1
    }
    gen dur`i' = t >= 16 & t <= 21
            
    tempvar sumdur
    egen `sumdur' = rowtotal(dur*)
    assert `sumdur' == 1

    return scalar numPer = `i'
    
end

// Baseline hazard for spell 2, g3, high
program bh_s2_g3_high, rclass

    loc i = 1
    
    forvalues per = 1(3)3 { // originally 14
        gen dur`i' = t >= `per' & t <= `per' + 2 // 3 quarter years
        loc i = `i' + 1
    }
    forvalues per = 4(2)6 { // originally 14
        gen dur`i' = t >= `per' & t <= `per' + 1 // half years
        loc i = `i' + 1
    }
    forvalues per = 8(4)11 { // originally 14
        gen dur`i' = t >= `per' & t <= `per' + 3 // 3 quarter years
        loc i = `i' + 1
    }
    forvalues per = 12(5)17 { // originally 14
        gen dur`i' = t >= `per' & t <= `per' + 4 // 3 quarter years
        loc i = `i' + 1
    }
    loc --i // needed because the non-prop below uses `i'
            
    tempvar sumdur
    egen `sumdur' = rowtotal(dur*)
    assert `sumdur' == 1

    return scalar numPer = `i'
    
end

// Baseline hazard for spell 3, g1, high
program bh_s3_g1_high, rclass

    loc i = 1
    
    forvalues per = 1(4)12 { // originally 14
        gen dur`i' = t >= `per' & t <= `per' + 3 // 3 quarter years
        loc i = `i' + 1
    }
    gen dur`i' = t >= 13 & t <= 24
            
    tempvar sumdur
    egen `sumdur' = rowtotal(dur*)
    assert `sumdur' == 1

    return scalar numPer = `i'

end

// Baseline hazard for spell 3, g2, high
program bh_s3_g2_high, rclass

    loc i = 1
    
    forvalues per = 1(3)4 {
        gen dur`i' = t >= `per' & t <= `per' + 2 
        loc i = `i' + 1
    }
    forvalues per = 7(4)11 { // originally 14
        gen dur`i' = t >= `per' & t <= `per' + 3 
        loc i = `i' + 1
    }
    forvalues per = 15(5)18 { // originally 14
        gen dur`i' = t >= `per' & t <= `per' + 4 
        loc i = `i' + 1
    }
    gen dur`i' = t >= 20 & t <= 24
    
    tempvar sumdur
    egen `sumdur' = rowtotal(dur*)
    assert `sumdur' == 1

    return scalar numPer = `i'

end

// Baseline hazard for spell 3, g3, high
program bh_s3_g3_high, rclass

    loc i = 1
    
    forvalues per = 1(4)3 { // originally 14
        gen dur`i' = t >= `per' & t <= `per' + 3 // half years
        loc i = `i' + 1
    }
    forvalues per = 5(3)8 { // originally 14
        gen dur`i' = t >= `per' & t <= `per' + 2 // half years
        loc i = `i' + 1
    }
    gen dur`i' = t >= 11 & t <= 24
    
    tempvar sumdur
    egen `sumdur' = rowtotal(dur*)
    assert `sumdur' == 1

    return scalar numPer = `i'

end

// Baseline hazard for spell 4, g1, high
program bh_s4_g1_high, rclass

    loc i = 1
    
    gen dur`i' = t >= 1 & t <= 9
    loc i = `i' + 1    
    gen dur`i' = t >= 10 & t <= 19
    
    tempvar sumdur
    egen `sumdur' = rowtotal(dur*)
    assert `sumdur' == 1

    return scalar numPer = `i'

end

// Baseline hazard for spell 4, g2, high
program bh_s4_g2_high, rclass

    loc i = 1
    
    forvalues per = 1(5)2 { // originally 14
        gen dur`i' = t >= `per' & t <= `per' + 4 // half years
        loc i = `i' + 1
    }
    forvalues per = 6(5)9 { // originally 14
        gen dur`i' = t >= `per' & t <= `per' + 4 // half years
        loc i = `i' + 1
    }
    gen dur`i' = t >= 11 & t <= 19
    
    tempvar sumdur
    egen `sumdur' = rowtotal(dur*)
    assert `sumdur' == 1

    return scalar numPer = `i'

end

// Baseline hazard for spell 4, g3, high
program bh_s4_g3_high, rclass

    loc i = 1
    
    forvalues per = 1(5)6 { // originally 14
        gen dur`i' = t >= `per' & t <= `per' + 4 // half years
        loc i = `i' + 1
    }
    gen dur`i' = t >= 11 & t <= 19
    
    tempvar sumdur
    egen `sumdur' = rowtotal(dur*)
    assert `sumdur' == 1

    return scalar numPer = `i'

end


