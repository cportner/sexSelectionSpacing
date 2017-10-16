* Graph determinants of sex selective abortions for second spell
* Hindu with 1-7 years of education, both urban and rural
* Competing Discrete Hazard model
* Fourth spell (from 3rd to 4th birth)
* an_spell4_g3_hindu_med_graphs.do
* Begun.: 09/04/10
* Edited: 2016-02-03

// REVISIONS

version 13.1
clear all

loc data "/net/proj/India_NFHS/base"
loc work "/net/proj/India_NFHS/base/sampleMain"
loc figdir "~/data/sexselection/graphs/sampleMain"


/*-------------------------------------------------------------------*/
/* LOADING DATA AND CREATING NEW VARIABLES                           */
/*-------------------------------------------------------------------*/

forvalues group = 3/3 {
        drop _all
        gen id = .
        // `e(estimates_note1)'
        estimates use `work'/results_spell4_g`group'_hindu_med
        
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
        forvalues per = 1(4)2 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 3 // half years
            loc i = `i' + 1
        }
        forvalues per = 5(5)8 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 4 // half years
            loc i = `i' + 1
        }
        gen dur`i' = t >= 10 & t <= 19

        
        recode scheduled* (.=0)
        recode land_own (.=0) 
//         replace want2 = 1
        replace b1space = 16
        replace b1space2 = b1space^2/100   
        replace mom_age = 24
//        replace mom_age2 = mom_age^2 / 100
        gen girl1 = 0
        gen girl2 = 0
        gen girl3 = 0
        replace girl1 = 1 if id == 3 | id == 4
        replace girl2 = 1 if id == 5 | id == 6
        replace girl3 = 1 if id == 7 | id == 8
        gen urban = 0 if id == 1 | id == 3 | id == 5 | id == 7
        replace urban = 1 if id == 2 | id == 4 | id == 6 | id == 8
        gen girl1Xurban = girl1 * urban
        gen girl2Xurban = girl2 * urban
        gen girl3Xurban = girl3 * urban
        
        // NON-PROPORTIONALITY
        capture drop np*        

        foreach var of var ///
        girl1 girl2 girl3 urban girl1Xurban girl2Xurban girl3Xurban {
            forval x = 1/`i' {
                gen np`x'X`var'  = dur`x' * `var' 
            }
        }
        
        predict p0, pr outcome(0) // no child
        predict p1, pr outcome(1) // boy
        predict p2, pr outcome(2) // girl
        
        set scheme s1mono
        loc goptions "xtitle(Quarter) legend(off) clwidth(medthick..) mlwidth(medthick..) "
        forvalues k = 1/8 {
            gen y`k'_b = p1 if id == `k'
            gen y`k'_g = p2 if id == `k'
            lab var y`k'_b "Exit: Boy"
            lab var y`k'_g "Exit: Girl"
            line y`k'_b y`k'_g t , sort `goptions'
            graph export `figdir'/spell4_g`group'_med_r`k'.eps , replace
            !a2ping `figdir'/spell4_g`group'_med_r`k'.eps
        }
        
        // percentage 
        predictnl pcbg = predict(outcome(1))/(predict(outcome(1)) + predict(outcome(2))) if p2 > 0.000001, ci(pcbg_l pcbg_u)
        set scheme s1mono
//         loc goptions "xtitle(Quarter) clpattern("l" "-" "-") legend(off) clwidth(medthick..) mlwidth(medthick..) yline(105, lstyle(foreground) extend)"
        loc goptions "xtitle(Quarter) clpattern("l" "-" "-") legend(off) clwidth(medthick..) mlwidth(medthick..) yline(51.2 , lstyle(foreground) extend)"
        forvalues k = 1/8 {
            gen pc`k'   = pcbg * 100 if id == `k'
            gen pc`k'_l = pcbg_l * 100 if id == `k'
            replace pc`k'_l = . if pc`k'_l < 25
            gen pc`k'_u = pcbg_u * 100 if id == `k'
            line pc`k' pc`k'_l pc`k'_u t, sort `goptions' ylabel(25(5)90)
            graph export `figdir'/spell4_g`group'_med_r`k'_pc.eps, replace
            !a2ping `figdir'/spell4_g`group'_med_r`k'_pc.eps
        }
        
        // relative risk
//         capture predictnl RRbg = predict(outcome(1))/predict(outcome(2)) if p2 > 0.000001, ci(RRbg_l RRbg_u)
//         set scheme s1mono
//         loc goptions "xtitle(Quarter) clpattern("l" "-" "-") legend(off) clwidth(medthick..) mlwidth(medthick..) yline(105, lstyle(foreground) extend) yline(140, lstyle(foreground) extend)"
//         forvalues k = 1/8 {
//             gen rr`k'   = RRbg * 100 if id == `k'
//             gen rr`k'_l = RRbg_l * 100 if id == `k'
//             gen rr`k'_u = RRbg_u * 100 if id == `k'
// //             line rr`k' rr`k'_l rr`k'_u t, sort `goptions' ylabel(0.6(0.2)2.2)
//             line rr`k' rr`k'_l rr`k'_u t, sort `goptions' 
//             graph export `figdir'/spell4_g`group'_med_r`k'_rr.eps, replace
//             !a2ping `figdir'/spell4_g`group'_med_r`k'_rr.eps
//         }
        
        // "hazards" curves
        bysort id (t): gen h = 1-p0
        lab var h "Hazard"
        set scheme s1mono
        loc goptions "xtitle(Quarter) legend(off) clwidth(medthick..) mlwidth(medthick..) "
        forvalues k = 1/8 {
            line h t if id == `k', sort `goptions'
            graph export `figdir'/spell4_g`group'_med_r`k'_h.eps, replace
            !a2ping `figdir'/spell4_g`group'_med_r`k'_h.eps
        }

        
        // survival curves
        bysort id (t): gen s = exp(sum(ln(p0)))
        lab var s "Survival"
        set scheme s1mono
        loc goptions "xtitle(Quarter) ytitle("") legend(off) clwidth(medthick..) mlwidth(medthick..) ylabel(0.0(0.2)1.0, grid glw(medthick)) "
        forvalues k = 1/8 {
            line s t if id == `k', sort `goptions'
            graph export `figdir'/spell4_g`group'_med_r`k'_s.eps, replace
            !a2ping `figdir'/spell4_g`group'_med_r`k'_s.eps
        }
}

cd `figdir'
!rm *.eps
cd `work'



