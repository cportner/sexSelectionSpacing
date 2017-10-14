* Graph determinants of sex selective abortions for second spell
* Hindu with 0 years of education, both urban and rural
* Competing Discrete Hazard model
* Second spell (from 1st to second birth)
* an_spell2_g1_`educ'_graphs.do
* Begun.: 05/04/10
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

loc educ "low"

forvalues group = 1/1 {
        drop _all
        gen id = .
        // `e(estimates_note1)'
        estimates use `data'/results_spell2_g`group'_`educ'
        
        // create fake obs for graphs
        loc newn = 0
        loc lastm = `e(estimates_note2)'
        forvalues k = 1/4 {
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
        capture drop d1-d21
        tab t, gen(d)
        
         // PIECE-WISE LINEAR HAZARDS
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
        
include gen_spell2_graphs 



}





