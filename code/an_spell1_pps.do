// Parity progression survival curves for spell 1

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
        append using `data'/spell1_g`per'_`educ' 
    }
}

// survival curves conditional on parity progression
loc goptions "xtitle(Months)  xlabel(0(6)72) ytitle("") legend(cols(1) ring(0) position(1)) clwidth(medthick..) mlwidth(medthick..) ylabel(0.0(0.2)1.0, grid glw(medthick)) "        
foreach educ in low med high {
    set scheme s1mono
    graph twoway (line pps months if educ == "`educ'" & period == 1 & urban , sort `goptions' lpattern(solid) legend(label(1 "1972-1984"))) ///
         (line pps months if educ == "`educ'" & period == 2 & urban , sort `goptions' lpattern(dash) legend(label(2 "1985-1994"))) ///
         (line pps months if educ == "`educ'" & period == 3 & urban , sort `goptions' lpattern(shortdash) legend(label(3 "1995-2006")))
    graph export `figures'/spell1_`educ'_urban_pps.eps, replace fontface(Palatino) 

    graph twoway (line pps months if educ == "`educ'" & period == 1 & !urban , sort `goptions' lpattern(solid) legend(label(1 "1972-1984"))) ///
         (line pps months if educ == "`educ'" & period == 2 & !urban , sort `goptions' lpattern(dash) legend(label(2 "1985-1994"))) ///
         (line pps months if educ == "`educ'" & period == 3 & !urban , sort `goptions' lpattern(shortdash) legend(label(3 "1995-2006")))
    graph export `figures'/spell1_`educ'_rural_pps.eps, replace fontface(Palatino) 
}

