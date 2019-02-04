// Table of spell lengths with bootstrapped standard errors

version 15.1
clear all

// loc num_reps = 100
loc num_reps = 4
file close _all // easier, in case something went wrong with last file write (Stata does not close files gracefully)

capture program drop _all
do bootspell.do

include directories

use `data'/base

tempfile main reduced
compress
save "`main'"

// Restricting sample and data manipulations

foreach educ in "high" "med" "low" {

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
    
    // No need to load all data again since loop below is for same education level
    compress
    save "`reduced'", replace 

    // Loop over regions
    forval region = 1/4 {
    
        forvalues spell = 2/4 {

            forvalues group = 1/4 {
            
                use "`reduced'" , clear
                run genSpell`spell'.do
                keep if group == `group' & region == `region'

                if `spell' == 1 {
                    global b1space ""
                    loc girlvar ""
                } 
                else {
                    loc girlvar " girl* "
                }
                
                // Set up the required statistics
                // These should match the naming in bootspell.do
                loc stats = ""
                foreach where in "urban" "rural" {
                    forvalues prior = 1/`spell' {
                        loc girls = `spell' - `prior'
                        // Remember p is percent left!!
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
                        foreach per of numlist 25 50 75 {
                            loc stats = "`stats' diff_p`per'_`where'_g`all_girls'_vs_g`comp' = r(diff_p`per'_`where'_g`all_girls'_vs_g`comp')"
                        } 
                    } 
                }
            
                keep id b`spell'_space b`spell'_sex b`spell'_cen `girlvar' ///
                    urban $b1space $parents $hh $caste // remove unnecessary variables to speed bootstrap
        
                // Bootstrapping
                bootstrap `stats' , ///
                    reps(`num_reps') seed(100669) nowarn saving(`data'/bs_s`spell'_g`group'_`educ'_r`region', replace) ///
                    : bootspell `spell' 
            
            }
        }
    }    
}

