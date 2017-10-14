// Graph generation for spell 3


recode scheduled* (.=0)
recode land_own (.=0) 
//         replace want2 = 1
replace b1space = 16
replace b1space2 = b1space^2/100   
replace mom_age = 24
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


// percentage 
capture predictnl pcbg = predict(outcome(1))/(predict(outcome(1)) + predict(outcome(2))) if p2 > 0.000001, ci(pcbg_l pcbg_u)
gen pc   = pcbg   * 100
gen pc_l = pcbg_l * 100
gen pc_u = pcbg_u * 100

set scheme s1mono
loc goptions "xtitle(Quarter) clpattern("l" "-" "-") legend(off) clwidth(medthick..) mlwidth(medthick..) yline(51.2 , lstyle(foreground) extend) ylabel(30(5)85)"

line pc pc_l pc_u t if urban & girl2, sort `goptions' 
graph export `figures'/spell3_g`group'_`educ'_urban_gg_pc.eps, replace

line pc pc_l pc_u t if urban & girl1, sort `goptions' 
graph export `figures'/spell3_g`group'_`educ'_urban_bg_pc.eps, replace

line pc pc_l pc_u t if urban & !girl1 & !girl2, sort `goptions' 
graph export `figures'/spell3_g`group'_`educ'_urban_bb_pc.eps, replace

line pc pc_l pc_u t if !urban & girl2, sort `goptions' 
graph export `figures'/spell3_g`group'_`educ'_rural_gg_pc.eps, replace

line pc pc_l pc_u t if !urban & girl1, sort `goptions' 
graph export `figures'/spell3_g`group'_`educ'_rural_bg_pc.eps, replace

line pc pc_l pc_u t if !urban & !girl1 & !girl2, sort `goptions' 
graph export `figures'/spell3_g`group'_`educ'_rural_bb_pc.eps, replace



// survival curves
bysort id (t): gen s = exp(sum(ln(p0)))
set scheme s1mono
loc goptions "xtitle(Quarter) ytitle("") legend(off) clwidth(medthick..) mlwidth(medthick..) ylabel(0.0(0.2)1.0, grid glw(medthick)) "

line s t if urban & girl2, sort `goptions'
graph export `figures'/spell3_g`group'_`educ'_urban_gg_s.eps, replace

line s t if urban & girl1, sort `goptions'
graph export `figures'/spell3_g`group'_`educ'_urban_bg_s.eps, replace

line s t if urban & !girl1 & !girl2, sort `goptions'
graph export `figures'/spell3_g`group'_`educ'_urban_bb_s.eps, replace

line s t if !urban & girl2, sort `goptions'
graph export `figures'/spell3_g`group'_`educ'_rural_gg_s.eps, replace

line s t if !urban & girl1, sort `goptions'
graph export `figures'/spell3_g`group'_`educ'_rural_bg_s.eps, replace

line s t if !urban & !girl1 & !girl2, sort `goptions'
graph export `figures'/spell3_g`group'_`educ'_rural_bb_s.eps, replace



// survival curves conditional on parity progression
bysort id (t): gen double pps = (s - s[_N]) / (1.00 - s[_N])
loc goptions "xtitle(Quarter) ytitle("") legend(cols(1) ring(0) position(1)) clwidth(medthick..) mlwidth(medthick..) ylabel(0.0(0.2)1.0, grid glw(medthick)) "        
graph twoway (line pps t if id == 2 , sort `goptions' lpattern(solid) legend(label(1 "Two Boys"))) ///
     (line pps t if id == 4 , sort `goptions' lpattern(dash) legend(label(2 "One Boy / One Girl"))) ///
     (line pps t if id == 6 , sort `goptions' lpattern(shortdash) legend(label(3 "Two Girls")))
graph export `figures'/spell3_g`group'_`educ'_urban_pps.eps, replace fontface(Palatino) 

graph twoway (line pps t if id == 1 , sort `goptions' lpattern(solid) legend(label(1 "Two Boys"))) ///
     (line pps t if id == 3 , sort `goptions' lpattern(dash) legend(label(2 "One Boy / One Girl"))) ///
     (line pps t if id == 5 , sort `goptions' lpattern(shortdash) legend(label(3 "Two Girls")))
graph export `figures'/spell3_g`group'_`educ'_rural_pps.eps, replace fontface(Palatino) 

gen period = `group'
gen educ   = "`educ'"
save `data'/spell3_g`group'_`educ' , replace
