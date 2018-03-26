// Parity progression survival curves for spell 2

version 13.1
clear all

include directories

set obs 0

foreach per of numlist 1/4 {
    foreach educ in low med high {
        append using `data'/spell2_g`per'_`educ' 
    }
}

// survival curves conditional on parity progression
loc goptions "xtitle(Months) xlabel(0(6)96) ytitle("") legend(ring(0) position(1)) clwidth(medthick..) mlwidth(medthick..) ylabel(0.0(0.2)1.0, grid glw(medthick)) "        
foreach per of numlist 1/4 {
    foreach educ in low med high {
        set scheme s1mono

        graph twoway (line pps months if period == `per' & educ == "`educ'" & urban & !girl1 , sort `goptions' lpattern(solid) legend(label(1 "First Child a Boy"))) ///
            (line pps months if period == `per' & educ == "`educ'" & urban & girl1 , sort `goptions' lpattern(dash) legend(label(2 "First Child a Girl")))
        graph export `figures'/spell2_g`per'_`educ'_urban_pps.eps, replace fontface(Palatino) 

        graph twoway (line pps months if period == `per' & educ == "`educ'" & !urban & !girl1 , sort `goptions' lpattern(solid) legend(label(1 "First Child a Boy"))) ///
            (line pps months if period == `per' & educ == "`educ'" & !urban & girl1 , sort `goptions' lpattern(dash) legend(label(2 "First Child a Girl")))
        graph export `figures'/spell2_g`per'_`educ'_rural_pps.eps, replace fontface(Palatino) 
    }
}
