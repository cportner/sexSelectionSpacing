* Graph determinants of sex selective abortions for second spell
* Hindu with 8+ years of education, both urban and rural
* Competing Discrete Hazard model
* Third spell (from 2nd to 3rd birth)
* an_spell3_g2_`educ'_graphs.do
* Begun.: 07/04/10
* Edited: 2015-03-12

// REVISIONS

version 13.1
clear all

// Generic set of locations
loc rawdata "../rawData"
loc data    "../data"
loc figures "../figures"
loc tables  "../tables"


/*-------------------------------------------------------------------*/
/* LOADING DATA AND CREATING NEW VARIABLES                           */
/*-------------------------------------------------------------------*/

loc educ "high"

forvalues group = 2/2 {
        drop _all
        gen id = .
        // `e(estimates_note1)'
        estimates use `data'/results_spell3_g`group'_`educ'
        
        // create fake obs for graphs
        loc newn = 0
        loc lastm = `e(estimates_note2)'
        forvalues k = 1/6 {
            loc newn = `newn' + `lastm'
            set obs `newn'
            replace id = `k' if id == .
        }
        sort id
        bysort id: gen t = _n
        
        tokenize `e(estimates_note1)'
        loc i = 1
        while "``i''" != "" {
            loc var = substr("``i++''",3,.)
            capture gen `var' = .
        }
        capture gen birth = .
        
        capture drop dur* 
        capture drop d1-d2?
        tab t, gen(d)
        
        // PIECE-WISE LINEAR HAZARDS
        loc i = 1
        forvalues per = 1(3)4 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 2 // 3 quarter years
            loc i = `i' + 1
        }
        forvalues per = 7(4)11 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 3 // 3 quarter years
            loc i = `i' + 1
        }
        forvalues per = 15(5)18 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 4 // 3 quarter years
            loc i = `i' + 1
        }
        gen dur`i' = t >= 20 & t <= 24
                
include gen_spell3_graphs 

}





