// Graph generation for spell 1

//
recode scheduled* (.=0)
recode land_own (.=0) 
replace mom_age = 20
gen urban = 0 if id == 1 
replace urban = 1 if id == 2 
gen months = t * 3


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
gen pc   = pcbg   * 100 
gen pc_l = pcbg_l * 100 
gen pc_u = pcbg_u * 100 

set scheme s1mono
loc goptions "xtitle(Months) clpattern("l" "-" "-") legend(off) clwidth(medthick..) mlwidth(medthick..) yline(51.2 , lstyle(foreground) extend)"

line pc pc_l pc_u months if urban, sort `goptions' ylabel(40(5)75)
graph export `figures'/spell1_g`group'_`educ'_urban_pc.eps, replace

line pc pc_l pc_u months if !urban, sort `goptions' ylabel(40(5)75)
graph export `figures'/spell1_g`group'_`educ'_rural_pc.eps, replace



// survival curves
bysort id (t): gen s = exp(sum(ln(p0)))
set scheme s1mono
loc goptions "xtitle(Months) ytitle("") legend(off) clwidth(medthick..) mlwidth(medthick..) ylabel(0.0(0.2)1.0, grid glw(medthick)) "

line s months if urban, sort `goptions'
graph export `figures'/spell1_g`group'_`educ'_urban_s.eps, replace

line s months if !urban, sort `goptions'
graph export `figures'/spell1_g`group'_`educ'_rural_s.eps, replace



// survival curves conditional on parity progression
bysort id (t): gen double pps = (s - s[_N]) / (1.00 - s[_N])
gen period = `group'
gen educ   = "`educ'"
// Merge in observation data
merge m:1 urban using `data'/obs_spell1_`group'_`educ'
sort id t
drop _merge
save `data'/spell1_g`group'_`educ' , replace



