* Graph determinants of sex selective abortions for second spell
* Hindu with 0 years of education, both urban and rural
* Competing Discrete Hazard model
* First spell (from marriage to first birth)
* an_spell1_g3_`educ'_graphs.do
* Begun.: 08/04/10
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

forvalues group = 3/3 {
        drop _all
        gen id = .
        // `e(estimates_note1)'
        estimates use `data'/results_spell1_g`group'_`educ'
        
        // create fake obs for graphs
        loc newn = 0
        loc lastm = `e(estimates_note2)'
        forvalues k = 1/2 {
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
        gen dur`i' = t >= 1 & t<= 2
        loc ++i
        forvalues per = 3/4 { // check end number originally 9
            gen dur`i' = t == `per'  // quarters
            loc i = `i' + 1
        }
//         forvalues per = 5(2)6 { // originally 14
//             gen dur`i' = t >= `per' & t <= `per' + 1 // half years
//             loc i = `i' + 1
//         }
        forvalues per = 5(3)14 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 2 // 3 quarter years
            loc i = `i' + 1
        }
        gen dur`i' = t >= 17 & t <= 24
        
        include gen_spell1_graphs
}




