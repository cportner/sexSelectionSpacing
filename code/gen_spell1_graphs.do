// Graph generation for spell 1

//
recode scheduled* (.=0)
recode land_own (.=0) 
replace mom_age = 20
gen urban = 0 if id == 1 
replace urban = 1 if id == 2 


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
loc goptions "xtitle(Quarter) clpattern("l" "-" "-") legend(off) clwidth(medthick..) mlwidth(medthick..) yline(51.2 , lstyle(foreground) extend)"
forvalues k = 1/2 {
    gen pc`k'   = pcbg * 100 if id == `k'
    gen pc`k'_l = pcbg_l * 100 if id == `k'
    gen pc`k'_u = pcbg_u * 100 if id == `k'
    line pc`k' pc`k'_l pc`k'_u t, sort `goptions' ylabel(40(5)75)
    graph export `figures'/spell1_g`group'_`educ'_r`k'_pc.eps, replace
}


// survival curves
bysort id (t): gen s = exp(sum(ln(p0)))
//         lab var s "Survival"
set scheme s1mono
loc goptions "xtitle(Quarter) ytitle("") legend(off) clwidth(medthick..) mlwidth(medthick..) ylabel(0.0(0.2)1.0, grid glw(medthick)) "
forvalues k = 1/2 {
    line s t if id == `k', sort `goptions'
    graph export `figures'/spell1_g`group'_`educ'_r`k'_s.eps, replace
}

// survival curves conditional on parity progression
bysort id (t): gen double pps = (s - s[_N]) / (1.00 - s[_N])

save `data'/spell1_g`group'_`educ' , replace



