* Graph determinants of sex selective abortions for second spell
* Hindu with 0 years of education, both urban and rural
* Competing Discrete Hazard model
* First spell (from marriage to first birth)
* an_spell1_g2_low_graphs.do
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

forvalues group = 2/2 {
        drop _all
        gen id = .
        // `e(estimates_note1)'
        estimates use `data'/results_spell1_g`group'_low
        
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
        forvalues per = 1/4 { // check end number originally 9
            gen dur`i' = t == `per'  // quarters
            loc i = `i' + 1
        }
//         forvalues per = 5(2)6 { // originally 14
//             gen dur`i' = t >= `per' & t <= `per' + 1 // half years
//             loc i = `i' + 1
//         }
        forvalues per = 5(3)17 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 2 // 3 quarter years
            loc i = `i' + 1
        }
        gen dur`i' = t >= 20 & t <= 24
                        
        recode scheduled* (.=0)
        recode land_own (.=0) 
//         replace want2 = 1
        replace mom_age = 16
//        replace mom_age2 = mom_age^2 / 100
        gen urban = 0 if id == 1 | id == 3
        replace urban = 1 if id == 2 | id == 4
        
        // NON-PROPORTIONALITY
        capture drop np*        

        foreach var of var ///
        urban {
            forval x = 1/`i' {
                gen np`x'X`var'  = dur`x' * `var' 
            }
        }
        
        predict p0, pr outcome(0) // no child
        predict p1, pr outcome(1) // boy
        predict p2, pr outcome(2) // girl
        
        
        // percentage 
        capture predictnl pcbg = predict(outcome(1))/(predict(outcome(1)) + predict(outcome(2))) if p2 > 0.000001, ci(pcbg_l pcbg_u)
        set scheme s1mono
//         loc goptions "xtitle(Quarter) clpattern("l" "-" "-") legend(off) clwidth(medthick..) mlwidth(medthick..) yline(105, lstyle(foreground) extend)"
        loc goptions "xtitle(Quarter) clpattern("l" "-" "-") legend(off) clwidth(medthick..) mlwidth(medthick..) yline(51.2 , lstyle(foreground) extend)"
        forvalues k = 1/2 {
            gen pc`k'   = pcbg * 100 if id == `k'
            gen pc`k'_l = pcbg_l * 100 if id == `k'
            gen pc`k'_u = pcbg_u * 100 if id == `k'
            line pc`k' pc`k'_l pc`k'_u t, sort `goptions' ylabel(40(5)75)
            graph export `figdir'/spell1_g`group'_low_r`k'_pc.eps, replace
        }
        
        

        
        // survival curves
        bysort id (t): gen s = exp(sum(ln(p0)))
        lab var s "Survival"
        set scheme s1mono
        loc goptions "xtitle(Quarter) ytitle("") legend(off) clwidth(medthick..) mlwidth(medthick..) ylabel(0.0(0.2)1.0, grid glw(medthick)) "
        forvalues k = 1/2 {
            line s t if id == `k', sort `goptions'
            graph export `figdir'/spell1_g`group'_low_r`k'_s.eps, replace
        }
}




