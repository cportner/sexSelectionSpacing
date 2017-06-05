* Graph determinants of sex selective abortions for second spell
* Hindu with 8+ years of education, both urban and rural
* Competing Discrete Hazard model
* Second spell (from 1st to second birth)
* an_spell2_g3_hindu_high_graphs.do
* Begun.: 2017-06-04
* Edited: 2017-06-04

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

forvalues group = 3/3 {
        drop _all
        gen id = .
        // `e(estimates_note1)'
        estimates use `data'/results_spell2_g`group'_hindu_high
        
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
        forvalues per = 12(5)17 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 4 // 3 quarter years
            loc i = `i' + 1
        }
//         gen dur`i' = t >= 16 & t <= 21
//         loc i = `i' + 1
        loc --i // needed because the non-prop below uses `i'
        
        recode scheduled* (.=0)
        recode land_own (.=0) 
        replace b1space = 16
        replace b1space2 = b1space^2/100   
        replace mom_age = 22
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
        
        predict double p0, pr outcome(0) // no child
        predict double p1, pr outcome(1) // boy
        predict double p2, pr outcome(2) // girl
        
        set scheme s1mono
        loc goptions "xtitle(Quarter) legend(off) clwidth(medthick..) mlwidth(medthick..) "
        forvalues k = 1/4 {
            gen y`k'_b = p1 if id == `k'
            gen y`k'_g = p2 if id == `k'
            lab var y`k'_b "Exit: Boy"
            lab var y`k'_g "Exit: Girl"
            line y`k'_b y`k'_g t , sort `goptions'
            graph export `figures'/spell2_g`group'_high_r`k'.eps , replace
//             !a2ping `figdir'/spell2_g`group'_high_r`k'.eps
        }
        
        // percentage 
        capture predictnl double pcbg = ///
            predict(outcome(1))/(predict(outcome(1)) + predict(outcome(2))) if p2 > 0.000001, ///
            ci(pcbg_l pcbg_u)
        set scheme s1mono
        loc goptions "xtitle(Quarter) clpattern("l" "-" "-") legend(off) clwidth(medthick..) mlwidth(medthick..) yline(51.2 , lstyle(foreground) extend)"
        forvalues k = 1/4 {
            gen pc`k'   = pcbg * 100 if id == `k'
            gen pc`k'_l = pcbg_l * 100 if id == `k'
            gen pc`k'_u = pcbg_u * 100 if id == `k'
            line pc`k' pc`k'_l pc`k'_u t, sort `goptions' ylabel(35(5)75)
            graph export `figures'/spell2_g`group'_high_r`k'_pc.eps, replace
//             !a2ping `figdir'/spell2_g`group'_high_r`k'_pc.eps
        }
        
        // relative risk
//         capture predictnl RRbg = predict(outcome(1))/predict(outcome(2)) if p2 > 0.000001, ci(RRbg_l RRbg_u)
//         set scheme s1mono
//         loc goptions "xtitle(Quarter) clpattern("l" "-" "-") legend(off) clwidth(medthick..) mlwidth(medthick..) yline(105, lstyle(foreground) extend) yline(140, lstyle(foreground) extend)"
//         forvalues k = 1/4 {
//             gen rr`k'   = RRbg * 100 if id == `k'
//             gen rr`k'_l = RRbg_l * 100 if id == `k'
//             gen rr`k'_u = RRbg_u * 100 if id == `k'
// //             line rr`k' rr`k'_l rr`k'_u t, sort `goptions' ylabel(0.6(0.2)2.2)
//             line rr`k' rr`k'_l rr`k'_u t, sort `goptions' 
//             graph export `figdir'/spell2_g`group'_high_r`k'_rr.eps, replace
//             !a2ping `figdir'/spell2_g`group'_high_r`k'_rr.eps
//         }
        
        // "hazards" curves
        bysort id (t): gen double h = 1-p0
        lab var h "Hazard"
        set scheme s1mono
        loc goptions "xtitle(Quarter) legend(off) clwidth(medthick..) mlwidth(medthick..) "
        forvalues k = 1/4 {
            line h t if id == `k', sort `goptions'
            graph export `figures'/spell2_g`group'_high_r`k'_h.eps, replace
//             !a2ping `figdir'/spell2_g`group'_high_r`k'_h.eps
        }

        
        // survival curves
        bysort id (t): gen double s = exp(sum(ln(p0)))
        lab var s "Survival"
        set scheme s1mono
        loc goptions "xtitle(Quarter) ytitle("") legend(off) clwidth(medthick..) mlwidth(medthick..) ylabel(0.0(0.2)1.0, grid glw(medthick)) "
        forvalues k = 1/4 {
            line s t if id == `k', sort `goptions'
            graph export `figures'/spell2_g`group'_high_r`k'_s.eps, replace
//             !a2ping `figdir'/spell2_g`group'_high_r`k'_s.eps
        }

        // Calculate sex ratios and number of abortions
        bysort id (t): gen double leave = s[_n-1] - s[_n]
        bysort id (t): replace leave = 1-s if _n == 1
        bysort id (t): gen double weight = leave/(1-s[_N])
        bysort id (t): gen double sumweight = weight if _n == 1
        bysort id (t): replace sumweight = sumweight[_n-1] + weight[_n] if _n > 1
        
        // need to calculate number of pregnancies to use as weights for abortions
        bysort id (t): gen double perabort = (pcbg*205/105 - 1) // abortions in a given period
        bysort id (t): gen double wabort = perabort*weight
        bysort id (t): egen double pctabort = total(wabort) // "Number" of abortions based on % boys born by period
        bysort id (t): gen double wsr = pcbg * weight  // Weighting percent boys by ratio born in that period
        bysort id (t): egen double cumwsr = total(wsr) // Sex ratio for children born until end of spell
        bysort id (t): gen double pctbirth = 1 - s[_N] // Percent women with a birth
        bysort id (t): gen double abort1sr = cumwsr*205/105 - 1 // missing girls/abortions based on observed sex ratio (cumwsr)
        
//         bysort id (t):  keep if _n == _N
        gen vaegt = 1-s
    
        by id: sum pctbirth cumwsr pctabort abort1sr if _n == _N

}

// cd `figdir'
// !rm *.eps
// cd `work'



