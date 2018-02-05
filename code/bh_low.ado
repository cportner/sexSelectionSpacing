// Baseline hazard for low education women

program bh_low, rclass
    version 13
    args spell period

    loc i = 1
    
    // Baseline hazard for spell 1, g1, low
    if `spell' == 1 & `period' == 1 {
    
        forvalues per = 1/4 { 
            gen dur`i' = t == `per'  
            loc i = `i' + 1
        }
        forvalues per = 5(3)14 { 
            gen dur`i' = t >= `per' & t <= `per' + 2 
            loc i = `i' + 1
        }
        gen dur`i' = t >= 17 & t <= 24
        
    }
    

    // Baseline hazard for spell 1, g2, low
    if `spell' == 1 & `period' == 2 {
    
        forvalues per = 1/4 { 
            gen dur`i' = t == `per'  
            loc i = `i' + 1
        }
        forvalues per = 5(3)17 { 
            gen dur`i' = t >= `per' & t <= `per' + 2 
            loc i = `i' + 1
        }
        gen dur`i' = t >= 20 & t <= 24
                 
    }


    // Baseline hazard for spell 1, g3, low
    if `spell' == 1 & `period' == 3 {
    
        gen dur`i' = t >= 1 & t<= 2
        loc ++i
        forvalues per = 3/4 { 
            gen dur`i' = t == `per'  
            loc i = `i' + 1
        }
        forvalues per = 5(3)14 { 
            gen dur`i' = t >= `per' & t <= `per' + 2 
            loc i = `i' + 1
        }
        gen dur`i' = t >= 17 & t <= 24

    }                    

    // Baseline hazard for spell 1, g4, low
    if `spell' == 1 & `period' == 4 {
    
        gen dur`i' = t >= 1 & t<= 3
        loc ++i
        gen dur`i' = t == 4
        loc ++ i
        forvalues per = 5(2)12 { 
            gen dur`i' = t >= `per' & t <= `per' + 1
            loc i = `i' + 1
        }
        gen dur`i' = t >= 13 & t <= 15
        loc ++ i        
        gen dur`i' = t >= 16 & t <= 24
                 
    }



    // Baseline hazard for spell 2, g1, low
    if `spell' == 2 & `period' == 1 {
    
        forvalues per = 1(3)12 { 
            gen dur`i' = t >= `per' & t <= `per' + 2 
            loc i = `i' + 1
        }
        gen dur`i' = t >= 13 & t <= 21
                   
    }        

    // Baseline hazard for spell 2, g2, low
    if `spell' == 2 & `period' == 2 {
    
        gen dur`i' = t == 1  
        loc i = `i' + 1
        forvalues per = 2(2)6 { 
            gen dur`i' = t >= `per' & t <= `per' + 1 
            loc i = `i' + 1
        }
        forvalues per = 8(3)16 { 
            gen dur`i' = t >= `per' & t <= `per' + 2 
            loc i = `i' + 1
        }
        gen dur`i' = t >= 17 & t <= 21

    }
            

    // Baseline hazard for spell 2, g3, low
    if `spell' == 2 & `period' == 3 {
    
        forvalues per = 1(2)5 { 
            gen dur`i' = t >= `per' & t <= `per' + 1 
            loc i = `i' + 1
        }
        forvalues per = 7(3)9 { 
            gen dur`i' = t >= `per' & t <= `per' + 2 
            loc i = `i' + 1
        }
        forvalues per = 10(4)12 { 
            gen dur`i' = t >= `per' & t <= `per' + 3 
            loc i = `i' + 1
        }
        gen dur`i' = t >= 14 & t <= 21

    }            

    // Baseline hazard for spell 2, g4, low
    if `spell' == 2 & `period' == 4 {
    
        forvalues per = 1(3)12 { 
            gen dur`i' = t >= `per' & t <= `per' + 2 
            loc i = `i' + 1
        }
        gen dur`i' = t >= 13 & t <= 21

    }            



    // Baseline hazard for spell 3, g1, low
    if `spell' == 3 & `period' == 1 {
    
        forvalues per = 1(3)7 { 
            gen dur`i' = t >= `per' & t <= `per' + 2 
            loc i = `i' + 1
        }
        forvalues per = 10(4)13 { 
            gen dur`i' = t >= `per' & t <= `per' + 3 
            loc i = `i' + 1
        }
        gen dur`i' = t >= 14 & t <= 24

    }            


    // Baseline hazard for spell 3, g2, low
    if `spell' == 3 & `period' == 2 {
    
        forvalues per = 1(2)9 { 
            gen dur`i' = t >= `per' & t <= `per' + 1 
            loc i = `i' + 1
        }
        forvalues per = 11(3)14 { 
            gen dur`i' = t >= `per' & t <= `per' + 2 
            loc i = `i' + 1
        }
        gen dur`i' = t >= 17 & t <= 24

    }    


    // Baseline hazard for spell 3, g3, low
    if `spell' == 3 & `period' == 3 {
    
        forvalues per = 1(3)7 { 
            gen dur`i' = t >= `per' & t <= `per' + 2 
            loc i = `i' + 1
        }
        forvalues per = 10(4)13 { 
            gen dur`i' = t >= `per' & t <= `per' + 3 
            loc i = `i' + 1
        }
        gen dur`i' = t >= 14 & t <= 24

    }    

    // Baseline hazard for spell 3, g4, low
    if `spell' == 3 & `period' == 4 {
    
        forvalues per = 1(3)6 { 
            gen dur`i' = t >= `per' & t <= `per' + 2 
            loc i = `i' + 1
        }
        forvalues per = 7(5)11 { 
            gen dur`i' = t >= `per' & t <= `per' + 4 
            loc i = `i' + 1
        }
        gen dur`i' = t >= 12 & t <= 24

    }    



    // Baseline hazard for spell 4, g1, low
    if `spell' == 4 & `period' == 1 {
    
        forvalues per = 1(7)7 { 
            gen dur`i' = t >= `per' & t <= `per' + 6 
            loc i = `i' + 1
        }
        gen dur`i' = t >= 8 & t <= 19

    }    


    // Baseline hazard for spell 4, g2, low
    if `spell' == 4 & `period' == 2 {
    
        forvalues per = 1(3)2 { 
            gen dur`i' = t >= `per' & t <= `per' + 2 
            loc i = `i' + 1
        }
        forvalues per = 4(4)8 { 
            gen dur`i' = t >= `per' & t <= `per' + 3 
            loc i = `i' + 1
        }
        gen dur`i' = t >= 12 & t <= 19

    }    


    // Baseline hazard for spell 4, g3, low
    if `spell' == 4 & `period' == 3 {
    
        forvalues per = 1(3)2 { 
            gen dur`i' = t >= `per' & t <= `per' + 2 
            loc i = `i' + 1
        }
        forvalues per = 4(4)8 { 
            gen dur`i' = t >= `per' & t <= `per' + 3 
            loc i = `i' + 1
        }
        gen dur`i' = t >= 12 & t <= 19

    }

    // Baseline hazard for spell 4, g4, low
    if `spell' == 4 & `period' == 4 {
    
        forvalues per = 1(3)2 { 
            gen dur`i' = t >= `per' & t <= `per' + 2 
            loc i = `i' + 1
        }
        forvalues per = 4(4)8 { 
            gen dur`i' = t >= `per' & t <= `per' + 3 
            loc i = `i' + 1
        }
        gen dur`i' = t >= 12 & t <= 19

    }

        
    tempvar sumdur
    egen `sumdur' = rowtotal(dur*)
    assert `sumdur' == 1

    return scalar numPer = `i'

end


