// Graph generation for spell 4

recode scheduled* (.=0)
recode land_own (.=0) 
replace b1space = 16
replace b1space2 = b1space^2/100   
replace mom_age = 25
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


// percentage 
capture predictnl pcbg = predict(outcome(1))/(predict(outcome(1)) + predict(outcome(2))) if p2 > 0.000001, ci(pcbg_l pcbg_u)
gen pc   = pcbg * 100 
gen pc_l = pcbg_l * 100
gen pc_u = pcbg_u * 100

set scheme s1mono
loc goptions "xtitle(Quarter) clpattern("l" "-" "-") legend(off) clwidth(medthick..) mlwidth(medthick..) yline(51.2 , lstyle(foreground) extend) ylabel(25(5)90)"

line pc pc_l pc_u t if urban & girl3, sort `goptions'
graph export `figures'/spell4_g`group'_`educ'_urban_ggg_pc.eps, replace

line pc pc_l pc_u t if urban & girl2, sort `goptions'
graph export `figures'/spell4_g`group'_`educ'_urban_bgg_pc.eps, replace

line pc pc_l pc_u t if urban & girl1, sort `goptions'
graph export `figures'/spell4_g`group'_`educ'_urban_bbg_pc.eps, replace

line pc pc_l pc_u t if urban & !girl1 & !girl2 & !girl3, sort `goptions'
graph export `figures'/spell4_g`group'_`educ'_urban_bbb_pc.eps, replace

line pc pc_l pc_u t if !urban & girl3, sort `goptions'
graph export `figures'/spell4_g`group'_`educ'_rural_ggg_pc.eps, replace

line pc pc_l pc_u t if !urban & girl2, sort `goptions'
graph export `figures'/spell4_g`group'_`educ'_rural_bgg_pc.eps, replace

line pc pc_l pc_u t if !urban & girl1, sort `goptions'
graph export `figures'/spell4_g`group'_`educ'_rural_bbg_pc.eps, replace

line pc pc_l pc_u t if !urban & !girl1 & !girl2 & !girl3, sort `goptions'
graph export `figures'/spell4_g`group'_`educ'_rural_bbb_pc.eps, replace



// survival curves
bysort id (t): gen s = exp(sum(ln(p0)))
set scheme s1mono
loc goptions "xtitle(Quarter) ytitle("") legend(off) clwidth(medthick..) mlwidth(medthick..) ylabel(0.0(0.2)1.0, grid glw(medthick)) "

line s t if urban & girl3, sort `goptions'
graph export `figures'/spell4_g`group'_`educ'_urban_ggg_s.eps, replace

line s t if urban & girl2, sort `goptions'
graph export `figures'/spell4_g`group'_`educ'_urban_bgg_s.eps, replace

line s t if urban & girl1, sort `goptions'
graph export `figures'/spell4_g`group'_`educ'_urban_bbg_s.eps, replace

line s t if urban & !girl1 & !girl2 & !girl3, sort `goptions'
graph export `figures'/spell4_g`group'_`educ'_urban_bbb_s.eps, replace

line s t if !urban & girl3, sort `goptions'
graph export `figures'/spell4_g`group'_`educ'_rural_ggg_s.eps, replace

line s t if !urban & girl2, sort `goptions'
graph export `figures'/spell4_g`group'_`educ'_rural_bgg_s.eps, replace

line s t if !urban & girl1, sort `goptions'
graph export `figures'/spell4_g`group'_`educ'_rural_bbg_s.eps, replace

line s t if !urban & !girl1 & !girl2 & !girl3, sort `goptions'
graph export `figures'/spell4_g`group'_`educ'_rural_bbb_s.eps, replace



gen period = `group'
gen educ   = "`educ'"
save `data'/spell4_g`group'_`educ' , replace
