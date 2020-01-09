// Predicted fertility using hazard model

clear
version 15.1
set more off

// Generic set of locations
include directories

use `data'/base, clear

save "`data'/temp_main"

// Restricting sample and data manipulations

foreach educ in "high" "med" "low" {

    use "`data'/temp_main", clear

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
    
    save "`data'/temp_`educ'" 

    forvalues spell = 1/4 {

        forvalues group = 1/4 {
            
            use "`data'/temp_`educ'" , clear

            // Obviously no prior children for first spell
            if `spell' == 1 {
                global b1space ""
                loc girlvar ""
            } 
            else {
                loc girlvar " girl* "
            }
            
            run genSpell`spell'.do
            
            keep if group == `group'

            keep id b`spell'_space b`spell'_sex b`spell'_cen `girlvar' ///
                urban $b1space $parents $hh $caste // remove unnecessary variables to speed up
        
            // Estimations
            expand b`spell'_space 
            bysort id: gen t = _n
            // the b3_cen == 0 is needed since I restrict the duration to `lastm' above
            // b3_sex is the child born as end of spell 2
            gen byte birth = 0
            bysort id (t): replace birth = 1 if b`spell'_sex == 1 & b`spell'_cen == 0 & _n == _N // exit with a son
            bysort id (t): replace birth = 2 if b`spell'_sex == 2 & b`spell'_cen == 0 & _n == _N // exit with a daugther

            // PIECE-WISE LINEAR HAZARDS - REMEMBER TO CHANGE BELOW IF ANY CHANGES HERE!
            if `spell' == 1 | `spell' == 2  {
                loc i = 1
                forvalues per = 1/19 {
                    gen dur`i' = t == `per'
                    loc ++i
                }
                gen dur`i' = t >= 20 & t <= 24
                loc ++i
                gen dur`i' = t >= 25
            }
            else if `spell' == 3 {
                loc i = 1
                forvalues per = 1/14 {
                    gen dur`i' = t == `per'
                    loc ++i
                }
                gen dur`i' = t >= 15 & t <= 19
                loc ++i
                gen dur`i' = t >= 20 
            }
            else if `spell' == 4 {
                loc i = 1
                gen dur`i' = t >= 1 & t <= 5
                loc ++i
                gen dur`i' = t >= 6 & t <= 10
                loc ++i
                gen dur`i' = t >= 11
            }

            // CREATE INTERACTIONS BASED ON SPELL NUMBER
            // Note: spell 1 will never enter the loop

            // NON-PROPORTIONALITY
            loc npvar = "urban "
            loc spell_m1 = `spell'-1
            forvalues j = 1/`spell_m1' {
                loc npvar = "`npvar' girl`j' girl`j'Xurban "
            }
            foreach var of var `npvar' {
                forval x = 1/`i' {
                    gen np`x'X`var'  = dur`x' * `var' 
                }
            }

            loc np "  np*X* "

            // ESTIMATION
            mlogit birth dur* $b1space ///
                $parents $hh $caste `np'  ///
                , baseoutcome(0) noconstant iterate(15)
        
            if `e(converged)' == 0 {
                dis "Multinomial logit did not converge!"
                exit
            }
            
            // Save results
            local names : colfullnames e(b)
            estimates notes: `names'
            estimates notes: $lastm
            estimates save `data'/fertility_results_spell`spell'_g`group'_`educ', replace
            
        }
    }
}







