// Test of differences in means across periods and 
// of difference-in-difference in means across periods


program comb_boot
    version 13.1
    args spell group1 group2 educ
    clear all

    set matsize 1000

    loc num_reps = 3
    file close _all // easier, in case something went wrong with last file write (Stata does not close files gracefully)

    include directories

    use `data'/base

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

    if `spell' == 1 {
        global b1space ""
        loc girlvar ""
    } 
    else {
        loc girlvar " girl* "
    } 
    include genSpell`spell'
    keep if group == `group1' | group == `group2'

    // Set up the required statistics
    // These should match the naming in bootspell.do
    loc stats = ""
    // should depend on arguments passed to program - use the numbers directly rather than forvalues
    // to allow for comparing, for example, periods 1 and 3.
    foreach period of numlist  `group1' `group2' { 
        foreach where in "urban" "rural" {
            forvalues prior = 1/`spell' {
                loc girls = `spell' - `prior'
                // Remember p is percent left!!
                loc stats = "`stats' p75_`where'_g`girls'_p`period' = r(p75_`where'_g`girls'_p`period')"
                loc stats = "`stats' p50_`where'_g`girls'_p`period' = r(p50_`where'_g`girls'_p`period')"
                loc stats = "`stats' p25_`where'_g`girls'_p`period' = r(p25_`where'_g`girls'_p`period')"
                loc stats = "`stats' pct_`where'_g`girls'_p`period' = r(pct_`where'_g`girls'_p`period')"
                loc stats = "`stats' any_`where'_g`girls'_p`period' = r(any_`where'_g`girls'_p`period')"
            } 
        }
    }

    keep id group b`spell'_space b`spell'_sex b`spell'_cen `girlvar' ///
        urban $b1space $parents $hh $caste // remove unnecessary variables to speed bootstrap

    // Bootstrapping
    bootstrap `stats' , ///
        reps(`num_reps') seed(100) nowarn ///
        : comb_analysis `spell' `group1' `group2' `educ'

end


