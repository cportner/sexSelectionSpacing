// Baseline hazard for middle education women

program bh_med, rclass
    version 13
    args spell period

    loc i = 1
    
    // Baseline hazard for spell 1, g1, medium
    if `spell' == 1 & `period' == 1 {
    
        forvalues per = 1/5 { // check end number originally 9
            gen dur`i' = t == `per'  // quarters
            loc i = `i' + 1
        }
        forvalues per = 6(2)7 { // originally 8
            gen dur`i' = t >= `per' & t <= `per' + 1 // half years
            loc i = `i' + 1
        }
        gen dur`i' = t >= 8 & t <= 12
        loc ++i    
        gen dur`i' = t >= 13 & t <= 17
        loc ++i
        gen dur`i' = t >= 18 & t <= 24
        
    }
    

    // Baseline hazard for spell 1, g2, medium
    if `spell' == 1 & `period' == 2 {
    
        forvalues per = 1/5 { // check end number originally 9
            gen dur`i' = t == `per'  // quarters
            loc i = `i' + 1
        }
        forvalues per = 6(2)7 { // originally 8
            gen dur`i' = t >= `per' & t <= `per' + 1 // half years
            loc i = `i' + 1
        }
        gen dur`i' = t >= 8 & t <= 12
        loc ++i    
        gen dur`i' = t >= 13 & t <= 17
        loc ++i
        gen dur`i' = t >= 18 & t <= 24
                 
    }


    // Baseline hazard for spell 1, g3, medium
    if `spell' == 1 & `period' == 3 {
    
        forvalues per = 1/5 { // check end number originally 9
            gen dur`i' = t == `per'  // quarters
            loc i = `i' + 1
        }
        forvalues per = 6(2)7 { // originally 8
            gen dur`i' = t >= `per' & t <= `per' + 1 // half years
            loc i = `i' + 1
        }
        gen dur`i' = t >= 8 & t <= 14
        loc ++i    
        gen dur`i' = t >= 15 & t <= 24

    }                    

    // Baseline hazard for spell 1, g4, medium
    if `spell' == 1 & `period' == 4 {
    
        forvalues per = 1/5 { // check end number originally 9
            gen dur`i' = t == `per'  // quarters
            loc i = `i' + 1
        }
        forvalues per = 6(2)7 { // originally 8
            gen dur`i' = t >= `per' & t <= `per' + 1 // half years
            loc i = `i' + 1
        }
        gen dur`i' = t >= 8 & t <= 12
        loc ++i    
        gen dur`i' = t >= 13 & t <= 17
        loc ++i
        gen dur`i' = t >= 18 & t <= 24
                 
    }



    // Baseline hazard for spell 2, g1, medium
    if `spell' == 2 & `period' == 1 {
    
        gen dur`i' = t == 1  // quarters
        loc i = `i' + 1
        forvalues per = 2(2)8 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 1 // half years
            loc i = `i' + 1
        }
        forvalues per = 10(3)13 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 2 // 3 quarter years
            loc i = `i' + 1
        }
        gen dur`i' = t >= 16 & t <= 21
                   
    }        

    // Baseline hazard for spell 2, g2, medium
    if `spell' == 2 & `period' == 2 {
    
        forvalues per = 1(2)7 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 1 // half years
            loc i = `i' + 1
        }
        forvalues per = 9(3)12 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 2 // 3 quarter years
            loc i = `i' + 1
        }
        gen dur`i' = t >= 15 & t <= 21

    }
            

    // Baseline hazard for spell 2, g3, medium
    if `spell' == 2 & `period' == 3 {
    
        forvalues per = 1(2)3 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 1 // half years
            loc i = `i' + 1
        }
        forvalues per = 5(3)8 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 2 // 3 quarter years
            loc i = `i' + 1
        }
        gen dur`i' = t >= 11 & t <= 21

    }            

    // Baseline hazard for spell 2, g4, medium
    if `spell' == 2 & `period' == 2 {
    
        forvalues per = 1(2)7 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 1 // half years
            loc i = `i' + 1
        }
        forvalues per = 9(3)12 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 2 // 3 quarter years
            loc i = `i' + 1
        }
        gen dur`i' = t >= 15 & t <= 21

    }



    // Baseline hazard for spell 3, g1, medium
    if `spell' == 3 & `period' == 1 {
    
        forvalues per = 1(4)9 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 3 // half years
            loc i = `i' + 1
        }
        gen dur`i' = t >= 13 & t <= 24

    }            


    // Baseline hazard for spell 3, g2, medium
    if `spell' == 3 & `period' == 2 {
    
        forvalues per = 1(2)7 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 1 // half years
            loc i = `i' + 1
        }
        forvalues per = 9(3)12 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 2 // 3 quarter years
            loc i = `i' + 1
        }
        gen dur`i' = t >= 15 & t <= 24

    }    


    // Baseline hazard for spell 3, g3, medium
    if `spell' == 3 & `period' == 3 {
    
        forvalues per = 1(4)9 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 3 // half years
            loc i = `i' + 1
        }
        gen dur`i' = t >= 13 & t <= 24

    }    

    // Baseline hazard for spell 3, g4, medium
    if `spell' == 3 & `period' == 4 {
    
        forvalues per = 1(2)7 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 1 // half years
            loc i = `i' + 1
        }
        forvalues per = 9(3)12 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 2 // 3 quarter years
            loc i = `i' + 1
        }
        gen dur`i' = t >= 15 & t <= 24

    }    



    // Baseline hazard for spell 4, g1, medium
    if `spell' == 4 & `period' == 1 {
    
        forvalues per = 1(3)2 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 2 // half years
            loc i = `i' + 1
        }
        forvalues per = 4(4)8 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 3 // half years
            loc i = `i' + 1
        }
        gen dur`i' = t >= 12 & t <= 19

    }    


    // Baseline hazard for spell 4, g2, medium
    if `spell' == 4 & `period' == 2 {
    
        forvalues per = 1(3)2 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 2 // half years
            loc i = `i' + 1
        }
        forvalues per = 4(4)8 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 3 // half years
            loc i = `i' + 1
        }
        gen dur`i' = t >= 12 & t <= 19

    }    


    // Baseline hazard for spell 4, g3, medium
    if `spell' == 4 & `period' == 3 {
    
        forvalues per = 1(4)2 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 3 // half years
            loc i = `i' + 1
        }
        forvalues per = 5(5)8 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 4 // half years
            loc i = `i' + 1
        }
        gen dur`i' = t >= 10 & t <= 19

    }
    
    // Baseline hazard for spell 4, g4, medium
    if `spell' == 4 & `period' == 4 {
    
        forvalues per = 1(3)2 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 2 // half years
            loc i = `i' + 1
        }
        forvalues per = 4(4)8 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 3 // half years
            loc i = `i' + 1
        }
        gen dur`i' = t >= 12 & t <= 19

    }    
    
        
    tempvar sumdur
    egen `sumdur' = rowtotal(dur*)
    assert `sumdur' == 1

    return scalar numPer = `i'

end

