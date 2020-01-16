// Table of spell lengths with bootstrapped standard errors

version 15.1
clear all

// loc num_reps = 100
loc num_reps = 3
file close _all // easier, in case something went wrong with last file write (Stata does not close files gracefully)

capture program drop _all
do bootspell_all.do

include directories

use `data'/base

save "`data'/temp_main", replace

// Restricting sample and data manipulations

foreach educ in "highest" "high" "med" "low" {

    use "`data'/temp_main", clear

    // keep only those in education group
    if "`educ'" == "low" {
        keep if edu_mother == 0
    }
    else if "`educ'" == "med" {
        keep if edu_mother >= 1 & edu_mother <= 7
    }
    else if "`educ'" == "high" {
        keep if edu_mother >= 8 & edu_mother <= 11
    }
    else if "`educ'" == "highest" {
        keep if edu_mother >= 12
    }
    else {
        dis "Something went wrong with education level"
        exit
    }
    
    save "`data'/temp_`educ'" , replace

	forvalues group = 1/4 {
	
		// Do not run the first period for the highest education group; too few obs
		if "`educ'" == "highest" & `group' == 1 {
			continue
		}

	    forvalues spell = 2/4 {
            
            use "`data'/temp_`educ'" , clear
            if `spell' == 1 {
                global b1space ""
                loc girlvar ""
            } 
            else {
                loc girlvar " girl* "
            }
            run genSpell`spell'.do
            // Set up the required statistics
            // These should match the naming in bootspell.do
            loc stats = ""
            foreach where in "urban" "rural" {
                forvalues prior = 1/`spell' {
                    loc girls = `spell' - `prior'
                    // Remember p is percent left!!
                    loc stats = "`stats' avg_`where'_g`girls' = r(avg_`where'_g`girls')"
                    loc stats = "`stats' p75_`where'_g`girls' = r(p75_`where'_g`girls')"
                    loc stats = "`stats' p50_`where'_g`girls' = r(p50_`where'_g`girls')"
                    loc stats = "`stats' p25_`where'_g`girls' = r(p25_`where'_g`girls')"
                    loc stats = "`stats' pct_`where'_g`girls' = r(pct_`where'_g`girls')"
                    loc stats = "`stats' any_`where'_g`girls' = r(any_`where'_g`girls')"
                }
                // Differences for testing - only girls against each of the other sex compositions
                loc all_girls = `spell' - 1
                loc end = `spell' - 2
                forvalues comp = 0 / `end' {
                    loc stats = "`stats' diff_avg_`where'_g`all_girls'_vs_g`comp' = r(diff_avg_`where'_g`all_girls'_vs_g`comp')"
                    foreach per of numlist 25 50 75 {
                        loc stats = "`stats' diff_p`per'_`where'_g`all_girls'_vs_g`comp' = r(diff_p`per'_`where'_g`all_girls'_vs_g`comp')"
                    } 
                } 
            }
            
            keep if group == `group'

            keep id b`spell'_space b`spell'_sex b`spell'_cen `girlvar' ///
                urban $b1space $parents $hh $caste // remove unnecessary variables to speed bootstrap
        
            // Bootstrapping
            bootstrap `stats' , ///
                reps(`num_reps') seed(100669) nowarn saving(`data'/bs_s`spell'_g`group'_`educ'_all, replace) ///
                : bootspell_all `spell' `group' `educ'
            
        }
    }
}

