// Changes in labor force participation over time for sample used for main analyses

// Notes on variables:

// NFHS-4 only asked a subset of women (those selected for the state samples)
// about work, so the sample for NFHS-4 is slightly *smaller* than the prior surveys.

// Works at home or away (v721) is no longer part of the survey in NFHS-4, so cannot use that.

// Works for family, someone else, or self-employed is based on currently working in
// NFHS-1 but on either currently working or have worked in the last year for the 
// other rounds. There is no information on worked last year or any other time period
// for NFHS-1. I have conditioned on currently working for graphing the proportion who
// work for their family over time.


clear
version 15.1
set more off

include directories

use `data'/base

keep if hindu 
drop if observation_age_m >= 22 & round == 1
drop if observation_age_m >= 22 & round == 2
drop if observation_age_m >= 22 & round == 3
drop if observation_age_m >= 22 & round == 4

lab var land_own "Owns land"

// Married women over the age of 19
keep if mother_age > 19
egen age_group = cut(mother_age), at(20 30 40 50)

// cohort
gen cohort = mother_year
replace cohort = 1900 + cohort if cohort > 0 & cohort < 100

// Variables
gen currently_working = v714 == 1 if (v714 != 9 & v714 != .)
gen work_family       = v719 == 1 if currently_working & v719 != . & v719 != 9
gen work_self_others  = v719 == 2 | v719 == 3 if currently_working & v719 != . & v719 != 9
gen work_cash         = v741 == 1 | v741 == 2 if currently_working & v741 != . & v741 != 9 & (round == 3 | round == 4)
replace work_cash     = v720 == 1 if currently_working & v720 != . & v720 != 9 & (round == 1 | round == 2)
gen round_year = interview_year
recode round_year (1992/1993 = 1992) (1998/2000 = 1999) (2005/2006 = 2006) (2015/2016 = 2015)

// education group
drop if edu_mother > 30 // 98 and 99 Don't know and NA
gen educ_none = edu_mother == 0
gen educ_1_7  = edu_mother > 0 & edu_mother < 8
gen educ_8_11 = edu_mother >= 8 & edu_mother < 12
gen educ_12_up = edu_mother >= 12
egen educ_group = cut(edu_mother), at(0 1 8 30)


// Graph variables
set scheme s1mono

collapse currently_working work_family work_self_others work_cash, ///
    by(round_year urban educ_none educ_1_7 educ_8_11 educ_12_up age_group)
    
replace currently_working = currently_working * 100
replace work_family = work_family * 100
replace work_cash = work_cash * 100

foreach var of varlist currently_working work_family work_cash {
    foreach age of numlist 20 30 40 {
        foreach area in urban !urban {
            if "`area'" == "urban" local where = "urban"
            else local where = "rural"
            if "`var'" == "currently_working" local position = 2
            if "`var'" == "work_cash" local position = 5
            if "`var'" == "work_family" local position = 10
            graph twoway line `var' round if educ_none == 1 & `area' & age_group == `age', lwidth(thick) lpattern(solid) lcolor(black) /// 
                || line `var' round if educ_1_7 == 1 & `area' & age_group == `age', lwidth(thick) lpattern(longdash) lcolor(black) ///
                || line `var' round if educ_8_11  == 1 & `area' & age_group == `age', lwidth(thick) lpattern(dash) lcolor(black) ///
                || line `var' round if educ_12_up  == 1 & `area' & age_group == `age', lwidth(thick) lpattern(shortdash) lcolor(black) ///
                || , legend(label(1 "No education") label(2 "1 to 7 years") label(3 "8 to 11 years") label(4 "12 or more years") ring(0) position(`position') col(1)) ///
                    plotregion(margin(zero)) xlabel(1992 1999 2006 2015) ylabel(0(10)100) ytitle("Percent") xtitle("Survey Year")
        
            graph export `figures'/`var'_`where'_`age'.eps, replace fontface(Palatino)
        }            
    }
}

