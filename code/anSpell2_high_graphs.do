* Graph determinants of sex selective abortions for second spell
* Hindu with 8+ years of education, both urban and rural
* Competing Discrete Hazard model
* Second spell (from 1st to second birth)
* anSpell2_high_graphs.do
* Begun.: 2017-06-08
* Edited: 2017-06-08

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

drop _all
gen id = .
gen group = .
// `e(estimates_note1)'
estimates use `data'/results_spell2_high

// create fake obs for graphs
loc newn = 0
loc lastm = `e(estimates_note2)'
forvalues g = 1/3 {
    forvalues k = 1/4 {
        loc newn = `newn' + `lastm'
        set obs `newn'
        replace group = `g' if id == .
        replace id = `k' if id == .
    }
}
sort id
bysort group id : gen t = _n


tokenize `e(estimates_note1)'
loc i = 1
while "``i''" != "" {
    loc var = substr("``i++''",3,.)
    capture gen `var' = .
}
capture gen birth = .

capture drop dur* 
capture drop d1-d21

 // PIECE-WISE LINEAR HAZARDS
// From group 3 in original version
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
loc --i // needed because the non-prop below uses `i'
egen sumdur = rowtotal(dur*)
assert sumdur == 1

// OTHER VARIABLES 
recode scheduled* (.=0)
recode land_own (.=0) 
replace b1space = 16
replace b1space2 = b1space^2/100   
replace mom_age = 22
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

loc np "  np*X* "

// Period interactions
gen period2 = group == 2
gen period3 = group == 3
foreach var of varlist dur* $b1space $parent $hh $caste `np' {
    replace per2X`var' = period2 * `var'
    replace per3X`var' = period3 * `var'
}


// PREDICTIONS AND GRAPHS

loc group = 1

predict double p0, pr outcome(0) // no child
predict double p1, pr outcome(1) // boy
predict double p2, pr outcome(2) // girl

capture predictnl double pcbg = predict(outcome(1))/(predict(outcome(1)) + predict(outcome(2))) if p2 > 0.000001, ci(pcbg_l pcbg_u)

// percentage 
set scheme s1mono
loc goptions "xtitle(Quarter) clpattern("l" "-" "-") legend(off) clwidth(medthick..) mlwidth(medthick..) yline(51.2 , lstyle(foreground) extend)"
forvalues k = 1/4 {
    gen pc`k'   = pcbg * 100 if id == `k'
    gen pc`k'_l = pcbg_l * 100 if id == `k'
    gen pc`k'_u = pcbg_u * 100 if id == `k'
    line pc`k' pc`k'_l pc`k'_u t if group == `group', sort `goptions' ylabel(35(5)75)
    graph export `figures'/spell2_g`group'_high_r`k'_pc.eps, replace
}


// survival curves
bysort group id (t): gen double s = exp(sum(ln(p0)))
lab var s "Survival"
set scheme s1mono
loc goptions "xtitle(Quarter) ytitle("") legend(off) clwidth(medthick..) mlwidth(medthick..) ylabel(0.0(0.2)1.0, grid glw(medthick)) "
forvalues k = 1/4 {
    line s t if id == `k' & group == `group', sort `goptions'
    graph export `figures'/spell2_g`group'_high_r`k'_s.eps, replace
}

// survival curves conditional on parity progression
bysort group id (t): gen double pps = (s - s[_N]) / (1.00 - s[_N])
lab var s "Survival"
set scheme s1mono
loc goptions "xtitle(Quarter) ytitle("") legend(off) clwidth(medthick..) mlwidth(medthick..) ylabel(0.0(0.2)1.0, grid glw(medthick)) "
forvalues k = 1/4 {
    line pps t if id == `k' & group == `group', sort `goptions'
    graph export `figures'/spell2_g`group'_high_r`k'_pps.eps, replace
}

loc goptions "xtitle(Quarter) ytitle("") clwidth(medthick..) mlwidth(medthick..) ylabel(0.0(0.2)1.0, grid glw(medthick)) "

graph twoway (line pps t if id == 2 & group == 1, sort `goptions' legend(label(1 "First Child a P1"))) ///
             (line pps t if id == 2 & group == 2, sort `goptions' legend(label(2 "First Child a P2"))) ///
             (line pps t if id == 2 & group == 3, sort `goptions' legend(label(3 "First Child a P3"))) 


graph twoway (line pps t if id == 4 & group == 1, sort `goptions' legend(label(1 "First Child a P1"))) ///
             (line pps t if id == 4 & group == 2, sort `goptions' legend(label(2 "First Child a P2"))) ///
             (line pps t if id == 4 & group == 3, sort `goptions' legend(label(3 "First Child a P3"))) 

graph twoway (line pps t if id == 2 & group == 1, sort `goptions' legend(label(1 "First Child a P1 - B"))) ///
             (line pps t if id == 4 & group == 1, sort `goptions' legend(label(2 "First Child a P1 - G"))) 

graph twoway (line pps t if id == 2 & group == 2, sort `goptions' legend(label(1 "First Child a P1 - B"))) ///
             (line pps t if id == 4 & group == 2, sort `goptions' legend(label(2 "First Child a P1 - G"))) 

graph twoway (line pps t if id == 2 & group == 3, sort `goptions' legend(label(1 "First Child a P1 - B"))) ///
             (line pps t if id == 4 & group == 3, sort `goptions' legend(label(2 "First Child a P1 - G"))) 
graph export `figures'/combined_spell2_g3_high_pps.eps, replace 
