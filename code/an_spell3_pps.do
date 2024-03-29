// Parity progression survival curves for spell 3

version 15.1
clear all

include directories

set obs 0

foreach per of numlist 1/4 {
    foreach educ in low med high highest {
        append using `data'/spell3_g`per'_`educ' 
    }
}

// survival curves conditional on parity progression
loc goptions "xtitle(Months) xlabel(0(6)96) ytitle("") legend(cols(1) ring(0) position(1)) clwidth(medthick..) mlwidth(medthick..) ylabel(0.0(0.2)1.0, grid glw(medthick)) lcolor(black...) "        
foreach per of numlist 1/4 {
    foreach educ in low med high highest {
        set scheme s1mono

        graph twoway ///
            (line pps months if period == `per' & educ == "`educ'" & urban & girl2 , sort `goptions' lpattern(solid) legend(label(1 "2 Girls"))) ///
            (line pps months if period == `per' & educ == "`educ'" & urban & girl1 , sort `goptions' lpattern(longdash) legend(label(2 "1 Boy, 1 Girl"))) ///
            (line pps months if period == `per' & educ == "`educ'" & urban & !girl1 & !girl2 , sort `goptions' lpattern(dash) legend(label(3 "2 Boys")))
        graph export `figures'/spell3_g`per'_`educ'_urban_pps.eps, replace fontface(Palatino)  

        graph twoway ///
            (line pps months if period == `per' & educ == "`educ'" & !urban & girl2 , sort `goptions' lpattern(solid) legend(label(1 "2 Girls"))) ///
            (line pps months if period == `per' & educ == "`educ'" & !urban & girl1 , sort `goptions' lpattern(longdash) legend(label(2 "1 Boy, 1 Girl"))) ///
            (line pps months if period == `per' & educ == "`educ'" & !urban & !girl1 & !girl2 , sort `goptions' lpattern(dash) legend(label(3 "2 Boys")))
        graph export `figures'/spell3_g`per'_`educ'_rural_pps.eps, replace fontface(Palatino)   
    }
}
