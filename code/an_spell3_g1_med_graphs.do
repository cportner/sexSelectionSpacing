* Graph determinants of sex selective abortions for second spell
* Hindu with 1-7 years of education, both urban and rural
* Competing Discrete Hazard model
* Third spell (from 2nd to 3rd birth)
* an_spell3_g1_med_graphs.do
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

forvalues group = 1/1 {
        drop _all
        gen id = .
        // `e(estimates_note1)'
        estimates use `data'/results_spell3_g`group'_med
        
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
        capture drop d1-d21
        tab t, gen(d)
        
        // PIECE-WISE LINEAR HAZARDS
        loc i = 1
        forvalues per = 1(4)9 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 3 // half years
            loc i = `i' + 1
        }
        gen dur`i' = t >= 13 & t <= 24
        
        recode scheduled* (.=0)
        recode land_own (.=0) 
//         replace want2 = 1
        replace b1space = 16
        replace b1space2 = b1space^2/100   
        replace mom_age = 21
//        replace mom_age2 = mom_age^2 / 100
        gen girl1 = 0
        gen girl2 = 0
        replace girl1 = 1 if id == 3 | id == 4
        replace girl2 = 1 if id == 5 | id == 6
        gen urban = 0 if id == 1 | id == 3 | id == 5
        replace urban = 1 if id == 2 | id == 4 | id == 6
        gen girl1Xurban = girl1 * urban
        gen girl2Xurban = girl2 * urban

        // NON-PROPORTIONALITY
        capture drop np*        

        foreach var of var ///
        girl1 girl2 urban girl1Xurban girl2Xurban {
            forval x = 1/`i' {
                gen np`x'X`var'  = dur`x' * `var' 
            }
        }
        
        predict p0, pr outcome(0) // no child
        predict p1, pr outcome(1) // boy
        predict p2, pr outcome(2) // girl
        
        set scheme s1mono
        loc goptions "xtitle(Quarter) legend(off) clwidth(medthick..) mlwidth(medthick..) "
        forvalues k = 1/6 {
            gen y`k'_b = p1 if id == `k'
            gen y`k'_g = p2 if id == `k'
            lab var y`k'_b "Exit: Boy"
            lab var y`k'_g "Exit: Girl"
            line y`k'_b y`k'_g t , sort `goptions'
            graph export `figdir'/spell3_g`group'_med_r`k'.eps , replace
        }
        
        // percentage 
        capture predictnl pcbg = predict(outcome(1))/(predict(outcome(1)) + predict(outcome(2))) if p2 > 0.000001, ci(pcbg_l pcbg_u)
        set scheme s1mono
//         loc goptions "xtitle(Quarter) clpattern("l" "-" "-") legend(off) clwidth(medthick..) mlwidth(medthick..) yline(105, lstyle(foreground) extend)"
        loc goptions "xtitle(Quarter) clpattern("l" "-" "-") legend(off) clwidth(medthick..) mlwidth(medthick..) yline(51.2 , lstyle(foreground) extend)"
        forvalues k = 1/6 {
            gen pc`k'   = pcbg * 100 if id == `k'
            gen pc`k'_l = pcbg_l * 100 if id == `k'
            replace pc`k'_l = . if pc`k'_l < 30
            gen pc`k'_u = pcbg_u * 100 if id == `k'
            line pc`k' pc`k'_l pc`k'_u t, sort `goptions' ylabel(30(5)85)
            graph export `figdir'/spell3_g`group'_med_r`k'_pc.eps, replace
        }
        
        
        // survival curves
        bysort id (t): gen s = exp(sum(ln(p0)))
        lab var s "Survival"
        set scheme s1mono
        loc goptions "xtitle(Quarter) ytitle("") legend(off) clwidth(medthick..) mlwidth(medthick..) ylabel(0.0(0.2)1.0, grid glw(medthick)) "
        forvalues k = 1/6 {
            line s t if id == `k', sort `goptions'
            graph export `figdir'/spell3_g`group'_med_r`k'_s.eps, replace
        }
        

        // survival curves conditional on parity progression
        bysort id (t): gen double pps = (s - s[_N]) / (1.00 - s[_N])
        loc goptions "xtitle(Quarter) ytitle("") legend(cols(1) ring(0) position(1)) clwidth(medthick..) mlwidth(medthick..) ylabel(0.0(0.2)1.0, grid glw(medthick)) "        
        graph twoway (line pps t if id == 2 , sort `goptions' lpattern(solid) legend(label(1 "Two Boys"))) ///
             (line pps t if id == 4 , sort `goptions' lpattern(dash) legend(label(2 "One Boy / One Girl"))) ///
             (line pps t if id == 6 , sort `goptions' lpattern(shortdash) legend(label(3 "Two Girls")))
        graph export `figures'/spell3_g`group'_med_pps_urban.eps, replace fontface(Palatino) 

        graph twoway (line pps t if id == 1 , sort `goptions' lpattern(solid) legend(label(1 "Two Boys"))) ///
             (line pps t if id == 3 , sort `goptions' lpattern(dash) legend(label(2 "One Boy / One Girl"))) ///
             (line pps t if id == 5 , sort `goptions' lpattern(shortdash) legend(label(3 "Two Girls")))
        graph export `figures'/spell3_g`group'_med_pps_rural.eps, replace fontface(Palatino) 
        
}




