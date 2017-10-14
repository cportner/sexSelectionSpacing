// Graph generation for spell 2

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

predict p0, pr outcome(0) // no child
predict p1, pr outcome(1) // boy
predict p2, pr outcome(2) // girl


// percentage 
capture predictnl pcbg = predict(outcome(1))/(predict(outcome(1)) + predict(outcome(2))) if p2 > 0.000001, ci(pcbg_l pcbg_u)
gen pc   = pcbg   * 100
gen pc_l = pcbg_l * 100
gen pc_u = pcbg_u * 100

set scheme s1mono
loc goptions "xtitle(Quarter) clpattern("l" "-" "-") legend(off) clwidth(medthick..) mlwidth(medthick..) yline(51.2 , lstyle(foreground) extend) ylabel(35(5)75)"

line pc pc_l pc_u t if urban & girl, sort `goptions' 
graph export `figures'/spell2_g`group'_`educ'_urban_g_pc.eps, replace

line pc pc_l pc_u t if urban & !girl, sort `goptions'
graph export `figures'/spell2_g`group'_`educ'_urban_b_pc.eps, replace

line pc pc_l pc_u t if !urban & girl, sort `goptions'
graph export `figures'/spell2_g`group'_`educ'_rural_g_pc.eps, replace

line pc pc_l pc_u t if !urban & !girl, sort `goptions'
graph export `figures'/spell2_g`group'_`educ'_rural_b_pc.eps, replace

    

// survival curves
bysort id (t): gen s = exp(sum(ln(p0)))
set scheme s1mono
loc goptions "xtitle(Quarter) ytitle("") legend(off) clwidth(medthick..) mlwidth(medthick..) ylabel(0.0(0.2)1.0, grid glw(medthick)) "


line s t if urban & girl, sort `goptions'
graph export `figures'/spell2_g`group'_`educ'_urban_g_s.eps, replace

line s t if urban & !girl, sort `goptions'
graph export `figures'/spell2_g`group'_`educ'_urban_b_s.eps, replace

line s t if !urban & girl, sort `goptions'
graph export `figures'/spell2_g`group'_`educ'_rural_g_s.eps, replace

line s t if !urban & !girl, sort `goptions'
graph export `figures'/spell2_g`group'_`educ'_rural_b_s.eps, replace



// survival curves conditional on parity progression
bysort id (t): gen double pps = (s - s[_N]) / (1.00 - s[_N])
loc goptions "xtitle(Quarter) ytitle("") legend(ring(0) position(1)) clwidth(medthick..) mlwidth(medthick..) ylabel(0.0(0.2)1.0, grid glw(medthick)) "        
graph twoway (line pps t if id == 2 , sort `goptions' legend(label(1 "First Child a Boy"))) ///
 (line pps t if id == 4 , sort `goptions' legend(label(2 "First Child a Girl")))
graph export `figures'/spell2_g`group'_`educ'_urban_pps.eps, replace fontface(Palatino) 

graph twoway (line pps t if id == 1 , sort `goptions' legend(label(1 "First Child a Boy"))) ///
 (line pps t if id == 3 , sort `goptions' legend(label(2 "First Child a Girl")))
graph export `figures'/spell2_g`group'_`educ'_rural_pps.eps, replace fontface(Palatino) 

save `data'/spell2_g`group'_`educ' , replace

