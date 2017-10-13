* Graph determinants of sex selective abortions for second spell
* Hindu with 1-7 years of education, both urban and rural
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

loc educ "med"

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
        
        recode scheduled* (.=0)
        recode land_own (.=0) 
        replace b1space = 16
        replace b1space2 = b1space^2/100   
        replace mom_age = 19
//        replace mom_age2 = mom_age^2 / 100
        gen b2_girls = 0 if id == 1 | id == 2  
        replace b2_girls = 1 if id == 3 | id == 4 
        gen urban = 0 if id == 1 | id == 3
        replace urban = 1 if id == 2 | id == 4
        gen girl = b2_girls
        gen girlXurban = girl * urban

        
        // NON-PROPORTIONALITY
        capture drop np*        

        foreach var of var ///
        girl urban girlXurban {
            forval x = 1/`i' {
                gen np`x'X`var'  = dur`x' * `var' 
            }
        }
        
        predict p0, pr outcome(0) // no child
        predict p1, pr outcome(1) // boy
        predict p2, pr outcome(2) // girl
        
        set scheme s1mono
        loc goptions "xtitle(Quarter) legend(off) clwidth(medthick..) mlwidth(medthick..) "
        forvalues k = 1/4 {
            gen y`k'_b = p1 if id == `k'
            gen y`k'_g = p2 if id == `k'
            lab var y`k'_b "Exit: Boy"
            lab var y`k'_g "Exit: Girl"
            line y`k'_b y`k'_g t , sort `goptions'
            graph export `figures'/spell2_g`group'_`educ'_r`k'.eps , replace
        }
        
        // percentage 
        capture predictnl pcbg = predict(outcome(1))/(predict(outcome(1)) + predict(outcome(2))) if p2 > 0.000001, ci(pcbg_l pcbg_u)
        set scheme s1mono
//         loc goptions "xtitle(Quarter) clpattern("l" "-" "-") legend(off) clwidth(medthick..) mlwidth(medthick..) yline(105, lstyle(foreground) extend)"
        loc goptions "xtitle(Quarter) clpattern("l" "-" "-") legend(off) clwidth(medthick..) mlwidth(medthick..) yline(51.2 , lstyle(foreground) extend)"
        forvalues k = 1/4 {
            gen pc`k'   = pcbg * 100 if id == `k'
            gen pc`k'_l = pcbg_l * 100 if id == `k'
            gen pc`k'_u = pcbg_u * 100 if id == `k'
            line pc`k' pc`k'_l pc`k'_u t, sort `goptions' ylabel(35(5)75)
            graph export `figures'/spell2_g`group'_`educ'_r`k'_pc.eps, replace
        }        

        
        // survival curves
        bysort id (t): gen s = exp(sum(ln(p0)))
        lab var s "Survival"
        set scheme s1mono
        loc goptions "xtitle(Quarter) ytitle("") legend(off) clwidth(medthick..) mlwidth(medthick..) ylabel(0.0(0.2)1.0, grid glw(medthick)) "
        forvalues k = 1/4 {
            line s t if id == `k', sort `goptions'
            graph export `figures'/spell2_g`group'_`educ'_r`k'_s.eps, replace
        }
        

        // survival curves conditional on parity progression
        bysort id (t): gen double pps = (s - s[_N]) / (1.00 - s[_N])
        loc goptions "xtitle(Quarter) ytitle("") legend(ring(0) position(1)) clwidth(medthick..) mlwidth(medthick..) ylabel(0.0(0.2)1.0, grid glw(medthick)) "        
        graph twoway (line pps t if id == 2 , sort `goptions' legend(label(1 "First Child a Boy"))) ///
             (line pps t if id == 4 , sort `goptions' legend(label(2 "First Child a Girl")))
        graph export `figures'/spell2_g`group'_`educ'_pps_urban.eps, replace fontface(Palatino) 

        graph twoway (line pps t if id == 1 , sort `goptions' legend(label(1 "First Child a Boy"))) ///
             (line pps t if id == 3 , sort `goptions' legend(label(2 "First Child a Girl")))
        graph export `figures'/spell2_g`group'_`educ'_pps_rural.eps, replace fontface(Palatino) 
        
        
}




