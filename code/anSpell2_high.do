* Women with high education (8+ years) for both urban and rural
* Competing Discrete Hazard model
* Second spell (from 1st to second birth) for all periods
* Currently uses too narrow bands for piece-wise linear hazards
* anSpell2_high.do
* Begun.: 2017-06-07
* Edited: 2017-06-08 


// REVISIONS

version 13.1
clear all
set matsize 1000

// Generic set of locations
loc rawdata "../rawData"
loc data    "../data"
loc figures "../figures"
loc tables  "../tables"


/*-------------------------------------------------------------------*/
/* LOADING DATA AND CREATING NEW VARIABLES                           */
/*-------------------------------------------------------------------*/

use `data'/base

keep if edu_mother >= 8
local edgroup = "high"

// data manipulation
do genSpell2

// "group" is the period when the spell began (birth of the first child here)
// "gu_group" is the combination of sex of prior child and urban/rural

// GENERATE TIME VARIABLES
expand b2_space 
bysort id: gen t = _n
// the b2_cen == 0 is needed since I restrict the duration to `lastm' above
// b2_sex is the child born as end of spell 2
gen byte birth = 0
bysort id (t): replace birth = 1 if b2_sex == 1 & b2_cen == 0 & _n == _N // exit with a son
bysort id (t): replace birth = 2 if b2_sex == 2 & b2_cen == 0 & _n == _N // exit with a daugther
// EXITS WITH BIRTH ONLY (NON-CENSORED)
dis " All "
tab b2_space if birth == 1 | birth == 2
tab b2_space gu_group if birth == 1 | birth == 2
tab t if b2_cen == 0

// PIECE-WISE LINEAR HAZARDS
tab t, gen(dur)
egen sumdur = rowtotal(dur*)
assert sumdur == 1

// NON-PROPORTIONALITY
sum t
loc maxT = `r(max)'
foreach var of var ///
girl urban girlXurban {
    forval x = 1/`maxT' {
        gen np`x'X`var'  = dur`x' * `var' 
    }
}

loc np "  np*X* "

// Period interactions
gen period2 = group == 2
gen period3 = group == 3
foreach var of varlist dur* $b1space $parent $hh $caste `np' {
    gen per2X`var' = period2 * `var'
    gen per3X`var' = period3 * `var'
}


// ESTIMATION
eststo clear
eststo: mlogit birth dur* $b1space $parents $hh $caste `np' ///
    per2X* per3X* ///
    , baseoutcome(2) noconstant 

local names : colfullnames e(b)
estimates notes: `names'
estimates notes: $lastm
estimates save `data'/results_spell2_high, replace

