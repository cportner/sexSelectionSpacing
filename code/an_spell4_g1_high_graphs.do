* Graph determinants of sex selective abortions
* Hindu with 8+ years of education, both urban and rural
* Competing Discrete Hazard model
* Fourth spell (from 3rd to 4th birth)
* an_spell4_g1_high_graphs.do
* Begun.: 30/04/10
* Edited: 2016-02-03

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

forvalues group = 1/1 {
        drop _all
        gen id = .
        // `e(estimates_note1)'
        estimates use `data'/results_spell4_g`group'_high
        
        // create fake obs for graphs
        loc newn = 0
        loc lastm = `e(estimates_note2)'
        forvalues k = 1/8 {
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
        gen dur`i' = t >= 1 & t <= 9
        loc i = `i' + 1
        
        gen dur`i' = t >= 10 & t <= 19

        
include gen_spell4_graphs
}





