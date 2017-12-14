// Table of spell lengths with bootstrapped standard errors

version 13.1
clear all

capture program drop _all
do bootspell.do
do baseline_hazards/bh_high.do

// Generic set of locations
loc rawdata "../rawData"
loc data    "../data"
loc figures "../figures"
loc tables  "../tables"

use `data'/base

// Restricting sample and data manipulations

keep if edu_mother >= 8
loc educ = "high"

tempfile main
save "`main'"

forvalues spell = 2/2 {
    use "`main'", clear
    if `spell' == 1 {
        global b1space ""
        loc girlvar ""
    } 
    else {
        loc girlvar " girl* "
    }
    run genSpell`spell'.do
    // need to have a way of setting up the required statistics
    loc stats = ""
    foreach where in "urban" "rural" {
        forvalues prior = 1/`spell' {
            loc girls = `spell' - `prior'
            loc stats = "`stats' p50_`where'_g`girls' = r(p50_`where'_g`girls') "
        } 
    }
    forvalues group = 1/3 {
        preserve
        keep if group == `group'

        keep id b`spell'_space b`spell'_sex b`spell'_cen `girlvar' ///
            urban $b1space $parents $hh $caste // remove unnecessary variables to speed bootstrap
        
        // Bootstrapping
        bootstrap `stats' , reps(10) seed(100669) nowarn : bootspell `spell' `group' `educ'
        
        restore
    }
}

exit


// Table stuff here
