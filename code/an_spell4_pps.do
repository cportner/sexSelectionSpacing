// Parity progression survival curves for spell 4

version 13.1
clear all

// Generic set of locations
loc rawdata "../rawData"
loc data    "../data"
loc figures "../figures"
loc tables  "../tables"

set obs 0

foreach per of numlist 1/3 {
    foreach educ in low med high {
        append using `data'/spell4_g`per'_`educ' 
    }
}


// survival curves conditional on parity progression
loc goptions "xtitle(Months) xlabel(0(6)54) ytitle("") legend(cols(1) ring(0) position(1)) clwidth(medthick..) mlwidth(medthick..) ylabel(0.0(0.2)1.0, grid glw(medthick)) "        
foreach per of numlist 1/3 {
    foreach educ in low med high {
        set scheme s1mono
        graph twoway (line pps months if period == `per' & educ == "`educ'" & urban & !girl1 & !girl2 & !girl3 , sort `goptions' lpattern(solid) legend(label(1 "Three Boys"))) ///
             (line pps months if period == `per' & educ == "`educ'" & urban & girl1 , sort `goptions' lpattern(dash) legend(label(2 "Two Boys / One Girl"))) ///
             (line pps months if period == `per' & educ == "`educ'" & urban & girl2 , sort `goptions' lpattern(shortdash) legend(label(3 "One Boy / Two Girls"))) ///
             (line pps months if period == `per' & educ == "`educ'" & urban & girl3 , sort `goptions' lpattern(shortdash_dot) legend(label(4 "Three Girls")))
        graph export `figures'/spell4_g`per'_`educ'_urban_pps.eps, replace fontface(Palatino) 
        graph twoway (line pps months if period == `per' & educ == "`educ'" & !urban & !girl1 & !girl2 & !girl3 , sort `goptions' lpattern(solid) legend(label(1 "Three Boys"))) ///
             (line pps months if period == `per' & educ == "`educ'" & !urban & girl1 , sort `goptions' lpattern(dash) legend(label(2 "Two Boys / One Girl"))) ///
             (line pps months if period == `per' & educ == "`educ'" & !urban & girl2 , sort `goptions' lpattern(shortdash) legend(label(3 "One Boy / Two Girls"))) ///
             (line pps months if period == `per' & educ == "`educ'" & !urban & girl3 , sort `goptions' lpattern(shortdash_dot) legend(label(4 "Three Girls")))
        graph export `figures'/spell4_g`per'_`educ'_rural_pps.eps, replace fontface(Palatino) 
    }
}

