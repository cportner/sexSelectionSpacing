// Baseline hazard for high education women

program bh_high, rclass
    version 13
    args spell period

    loc i = 1
    
    // Baseline hazard for spell 1, g1, high
    if `spell' == 1 & `period' == 1 {
    
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
        gen dur`i' = t >= 20 
        
    }
    

    // Baseline hazard for spell 1, g2, high
    if `spell' == 1 & `period' == 2 {
    
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
        loc ++i
        gen dur`i' = t >= 25
                 
    }


    // Baseline hazard for spell 1, g3, high
    if `spell' == 1 & `period' == 3 {
    
        forvalues per = 1/5 { // check end number originally 9
            gen dur`i' = t == `per'  // quarters
            loc i = `i' + 1
        }
        forvalues per = 6(2)10 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 1 // half years
            loc i = `i' + 1
        }
        gen dur`i' = t >= 12 & t <= 24
        loc ++i
        gen dur`i' = t >= 25

    }                    

    // Baseline hazard for spell 1, g4, high
    if `spell' == 1 & `period' == 4 {
    
        forvalues per = 1(2)12 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 1 // half years
            loc i = `i' + 1
        }
        gen dur`i' = t >= 13 & t <= 18
        loc ++i
        gen dur`i' = t >= 19 & t <= 24   
        loc ++i
        gen dur`i' = t >= 25
                 
    }



    // Baseline hazard for spell 2, g1, high
    if `spell' == 2 & `period' == 1 {
    
        forvalues per = 1(3)4 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 2 // half years
            loc i = `i' + 1
        }
        forvalues per = 7(4)11 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 3 // 3 quarter years
            loc i = `i' + 1
        }
        gen dur`i' = t >= 15 
                   
    }        

    // Baseline hazard for spell 2, g2, high
    if `spell' == 2 & `period' == 2 {
    
        forvalues per = 1(2)5 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 1 // half years
            loc i = `i' + 1
        }
        forvalues per = 7(3)13 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 2 // 3 quarter years
            loc i = `i' + 1
        }
        gen dur`i' = t >= 16 

    }
            

    // Baseline hazard for spell 2, g3, high
    if `spell' == 2 & `period' == 3 {
    
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
        forvalues per = 12(5)16 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 4 // 3 quarter years
            loc i = `i' + 1
        }
        gen dur`i' = t >= 17 & t <= 24
        loc ++i
        gen dur`i' = t >= 25

    }            


    // Baseline hazard for spell 2, g4, high
    if `spell' == 2 & `period' == 4 {
    
        forvalues per = 1(2)5 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 1 // half years
            loc i = `i' + 1
        }
        forvalues per = 7(3)13 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 2 // 3 quarter years
            loc i = `i' + 1
        }
        gen dur`i' = t >= 16 & t <= 24
        loc ++i
        gen dur`i' = t >= 25

    }



    // Baseline hazard for spell 3, g1, high
    if `spell' == 3 & `period' == 1 {
    
        forvalues per = 1(4)12 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 3 // 3 quarter years
            loc i = `i' + 1
        }
        gen dur`i' = t >= 13 

    }            


    // Baseline hazard for spell 3, g2, high
    if `spell' == 3 & `period' == 2 {
    
        forvalues per = 1(3)6 {
            gen dur`i' = t >= `per' & t <= `per' + 2 
            loc i = `i' + 1
        }
        forvalues per = 7(4)14 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 3 
            loc i = `i' + 1
        }
        gen dur`i' = t >= 15 

    }    


    // Baseline hazard for spell 3, g3, high
    if `spell' == 3 & `period' == 3 {
    
        forvalues per = 1(4)3 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 3 // half years
            loc i = `i' + 1
        }
        forvalues per = 5(3)8 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 2 // half years
            loc i = `i' + 1
        }
        gen dur`i' = t >= 11 & t <= 18
        loc ++i
        gen dur`i' = t >= 19

    }    

    // Baseline hazard for spell 3, g4, high
    if `spell' == 3 & `period' == 4 {
    
        forvalues per = 1(4)3 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 3 // half years
            loc i = `i' + 1
        }
        forvalues per = 5(3)8 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 2 // half years
            loc i = `i' + 1
        }
        gen dur`i' = t >= 11 & t <= 18
        loc ++i
        gen dur`i' = t >= 19

    }    



    // Baseline hazard for spell 4, g1, high
    if `spell' == 4 & `period' == 1 {
    
        gen dur`i' = t >= 1 & t <= 7
        loc i = `i' + 1    
        gen dur`i' = t >= 8 

    }    


    // Baseline hazard for spell 4, g2, high
    if `spell' == 4 & `period' == 2 {
    
        forvalues per = 1(5)2 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 4 // half years
            loc i = `i' + 1
        }
        forvalues per = 6(5)9 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 4 // half years
            loc i = `i' + 1
        }
        gen dur`i' = t >= 11 

    }    


    // Baseline hazard for spell 4, g3, high
    if `spell' == 4 & `period' == 3 {
    
        forvalues per = 1(7)7 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 6 // half years
            loc i = `i' + 1
        }
        gen dur`i' = t >= 8 

    }


    // Baseline hazard for spell 4, g4, high
    if `spell' == 4 & `period' == 4 {
    
        forvalues per = 1(8)8 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 7 // half years
            loc i = `i' + 1
        }
        gen dur`i' = t >= 9 & t <= 18
        loc ++i
        gen dur`i' = t >= 19

    }

        
    tempvar sumdur
    egen `sumdur' = rowtotal(dur*)
    assert `sumdur' == 1

    return scalar numPer = `i'

end


