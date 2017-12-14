// Table of spell lengths with bootstrapped standard errors

version 13.1
clear all

capture program drop _all
do bootspell.do
do baseline_hazards/bh_low.do
do baseline_hazards/bh_med.do
do baseline_hazards/bh_high.do

// Generic set of locations
loc rawdata "../rawData"
loc data    "../data"
loc figures "../figures"
loc tables  "../tables"

use `data'/base

tempfile main low med high
save "`main'"

// Restricting sample and data manipulations

// foreach educ in "low" "med" "high" {
foreach educ in  "high" {

    use "`main'", clear

    // keep only those in education group
    if "`educ'" == "low" {
        keep if edu_mother == 0
    }
    else if "`educ'" == "med" {
        keep if edu_mother >= 1 & edu_mother < 8
    }
    else if "`educ'" == "high" {
        keep if edu_mother >= 8
    }
    else {
        dis "Something went wrong with education level"
        exit
    }
    
    save "``educ''" // Need double ` because the name that comes from educ is itself a local variable

    forvalues spell = 3/3 {
        use "``educ''" , clear
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
                // Remember p is percent left!!
                loc stats = "`stats' p75_`where'_g`girls' = r(p75_`where'_g`girls')"
                loc stats = "`stats' p50_`where'_g`girls' = r(p50_`where'_g`girls')"
                loc stats = "`stats' p25_`where'_g`girls' = r(p25_`where'_g`girls')"
                loc stats = "`stats' pct_`where'_g`girls' = r(pct_`where'_g`girls')"
            } 
        }
        forvalues group = 2/2 {
            preserve
            keep if group == `group'

            keep id b`spell'_space b`spell'_sex b`spell'_cen `girlvar' ///
                urban $b1space $parents $hh $caste // remove unnecessary variables to speed bootstrap
        
            // Bootstrapping
            bootstrap `stats' , reps(5) seed(100669) nowarn : bootspell `spell' `group' `educ'
        
            restore
        }
    }
}

exit


// Table stuff here
