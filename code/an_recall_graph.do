// Recall error estimations

version 13.1
clear all

include directories

/*-------------------------------------------------------------------*/
/* LOADING DATA AND CREATING NEW VARIABLES                           */
/*-------------------------------------------------------------------*/

use `data'/base

// survey information
gen survey = round // Round is now calculated in crBase.do

loc i = 88
forvalues k = 1/3 {
    gen b`k'_son = b`k'_sex == 1 if fertility >= `k'
    gen b`k'_born_year = int((b`k'_born_cmc-1)/12) if fertility >= `k'
    gen b`k'_born_year_2 = b`k'_born_year^2  / 100
    gen b`k'_after`i' = b`k'_born_year > `i'
    gen b`k'_mom_age_2 = b`k'_mom_age^2 / 100
}
gen mar_year = int((marriage_cmc-1)/12)+1900
gen mar_after`i' = mar_year > `i'

// local variables
loc caste    "scheduled_caste scheduled_tribe "
loc hh       "land_irr land_nir resid_large resid_small resid_town "
loc parents  "edu_mother* edu_father* "
loc region   "i.state "
loc region   " "

// prepare data for analysis
//preserve
keep round survey urban mar_year observation_age* mom_id b*_sex b*_born_cmc
reshape long b@_sex b@_born_cmc, i(mom_id) j(bo)
drop if b_sex == .
gen born_year = int((b_born_cmc-1)/12)+1900
// drop if born_year < `startyear'
recode b_sex (2=0)


/*-------------------------------------------------------------------*/
/* DEVELOPMENT IN SEX RATIOS BY YEAR GROUP OF MARRIAGE				 */
/*-------------------------------------------------------------------*/

// Marriage year groups
egen mar_2yr_cohort = cut(mar_year), ///
    at(1959(2)2013, 2018) icodes

// "First-born" by survey
preserve
keep if bo == 1
drop if round == 1 &  mar_2yr_cohort > 15
drop if round == 2 & (mar_2yr_cohort < 2 | mar_2yr_cohort > 19)
drop if round == 3 & (mar_2yr_cohort < 6 | mar_2yr_cohort > 22)
drop if round == 4 &  mar_2yr_cohort < 9

gen prc_boys = .
gen ub = .
gen lb = .

forvalues round = 1/4 {
    sum mar_2yr_cohort if round == `round'
    loc max_yr = `r(max)'
    loc min_yr = `r(min)'
    forvalue i = `min_yr'/`max_yr' {
        ci b_sex if mar_2yr_cohort == `i' & round == `round' , binomial
        replace prc_boys = `r(mean)' if mar_2yr_cohort == `i' & round == `round'
        replace ub = `r(ub)' if mar_2yr_cohort == `i' & round == `round'
        replace lb = `r(lb)' if mar_2yr_cohort == `i' & round == `round'
    }
}

bysort round mar_year: keep if _n == 1

set scheme s1mono
twoway line prc_boys mar_year if round == 1, legend(label(1 "NFHS-1")) lpattern(solid) lwidth(medthick..) lcolor(black) ///
    || line prc_boys mar_year if round == 2, legend(label(2 "NFHS-2")) lpattern(dash) lwidth(medthick..) lcolor(black) ///
    || line prc_boys mar_year if round == 3, legend(label(3 "NFHS-3")) lpattern(shortdash) lwidth(medthick..) lcolor(black) ///
    || line prc_boys mar_year if round == 4, legend(label(4 "NFHS-4")) lpattern(dash_dot) lwidth(medthick..) lcolor(black) ///
    || , xlabel(1960(5)2015)  yline(0.51219512, lstyle(foreground) extend) ///
    ylabel(0.48(0.02)0.6) legend(ring(0) bplacement(neast)) ///
    ytitle("") xtitle("Year of Marriage")
graph export `figures'/recall_sex_ratio_marriage_cohort.eps, replace fontface(Palatino)
restore


// "Second-born" by survey
preserve
keep if bo == 2
drop if round == 1 &  mar_2yr_cohort > 14
drop if round == 2 & (mar_2yr_cohort < 4 | mar_2yr_cohort > 17)
drop if round == 3 & (mar_2yr_cohort < 7 | mar_2yr_cohort > 21)
drop if round == 4 & (mar_2yr_cohort < 10 | mar_2yr_cohort > 26)

gen prc_boys = .
gen ub = .
gen lb = .

forvalues round = 1/4 {
    sum mar_2yr_cohort if round == `round'
    loc max_yr = `r(max)'
    loc min_yr = `r(min)'
    forvalue i = `min_yr'/`max_yr' {
        ci b_sex if mar_2yr_cohort == `i' & round == `round' , binomial
        replace prc_boys = `r(mean)' if mar_2yr_cohort == `i' & round == `round'
        replace ub = `r(ub)' if mar_2yr_cohort == `i' & round == `round'
        replace lb = `r(lb)' if mar_2yr_cohort == `i' & round == `round'
    }
}

bysort round mar_year: keep if _n == 1

set scheme s1mono
twoway line prc_boys mar_year if round == 1, legend(label(1 "NFHS-1")) lpattern(solid) lwidth(medthick..) lcolor(black) ///
    || line prc_boys mar_year if round == 2, legend(label(2 "NFHS-2")) lpattern(dash) lwidth(medthick..) lcolor(black) ///
    || line prc_boys mar_year if round == 3, legend(label(3 "NFHS-3")) lpattern(shortdash) lwidth(medthick..) lcolor(black) ///
    || line prc_boys mar_year if round == 4, legend(label(4 "NFHS-4")) lpattern(dash_dot) lwidth(medthick..) lcolor(black) ///
    || , xlabel(1960(5)2015)  yline(0.51219512, lstyle(foreground) extend) ///
    ylabel(0.48(0.02)0.6) legend(ring(0) bplacement(neast)) ///
    ytitle("") xtitle("Year of Marriage")
graph export `figures'/recall_sex_ratio_marriage_cohort_bo2.eps, replace fontface(Palatino)
restore



/*-------------------------------------------------------------------*/
/* DEVELOPMENT IN SEX RATIOS BY DURATION OF MARRIAGE				 */
/*-------------------------------------------------------------------*/


// Marriage age groups
egen mar_2yr_group = cut(observation_age_m) , ///
    at(0, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29, 31, 33, 41) icodes
drop if mar_2yr_group == . //  Anybody married for 41+ years at time of survey

// "First-born" combined across surveys
preserve
keep if bo == 1
sum mar_2yr_group
loc num_yr_groups = `r(max)'

gen prc_boys = .
gen ub = .
gen lb = .

forvalue i = 0/`num_yr_groups' {
    ci b_sex if mar_2yr_group == `i' , binomial
    replace prc_boys = `r(mean)' if mar_2yr_group == `i' 
    replace ub = `r(ub)' if mar_2yr_group == `i' 
    replace lb = `r(lb)' if mar_2yr_group == `i' 
}

bysort observation_age_m: keep if _n == 1

loc goptions "xtitle(Year) clpattern("l" "-" "-") legend(off) clwidth(medthick..) mlwidth(medthick..) yline(0.51219512, lstyle(foreground) extend) ylabel(0.48(0.02)0.6)"
set scheme s1mono

line prc_boys ub lb observation_age_m , `goptions' ///
    xtitle("Years between Marriage and Interview") xlabel(0(10)30)
graph export `figures'/recall_sex_ratio_marriage.eps, replace fontface(Palatino)

restore


// "First-born" by survey round
preserve
keep if bo == 1
sum mar_2yr_group
loc num_yr_groups = `r(max)'

gen prc_boys = .
gen ub = .
gen lb = .

forvalues round = 1/4 {
    forvalue i = 0/`num_yr_groups' {
        ci b_sex if mar_2yr_group == `i' & round == `round' , binomial
        replace prc_boys = `r(mean)' if mar_2yr_group == `i' & round == `round'
        replace ub = `r(ub)' if mar_2yr_group == `i' & round == `round'
        replace lb = `r(lb)' if mar_2yr_group == `i' & round == `round'
    }
}

bysort round observation_age_m: keep if _n == 1

loc goptions "xtitle(Year) clpattern("l" "-" "-") legend(off) clwidth(medthick..) mlwidth(medthick..) yline(0.51219512, lstyle(foreground) extend) ylabel(0.48(0.02)0.6)"
set scheme s1mono

forvalues round = 1/4 {
    line prc_boys ub lb observation_age_m if round == `round', `goptions' ///
        xtitle("Years between Marriage and Interview") xlabel(0(10)30)
    graph export `figures'/recall_sex_ratio_marriage_round_`round'.eps, replace fontface(Palatino)
}
restore

// "Second-born" by survey round
preserve
keep if bo == 2 & mar_2yr_group > 0 // little chance of a second birth within first two years
sum mar_2yr_group
loc num_yr_groups = `r(max)'

gen prc_boys = .
gen ub = .
gen lb = .

forvalues round = 1/4 {
    forvalue i = 0/`num_yr_groups' {
        ci b_sex if mar_2yr_group == `i' & round == `round' , binomial
        replace prc_boys = `r(mean)' if mar_2yr_group == `i' & round == `round'
        replace ub = `r(ub)' if mar_2yr_group == `i' & round == `round'
        replace lb = `r(lb)' if mar_2yr_group == `i' & round == `round'
    }
}

bysort round observation_age_m: keep if _n == 1

loc goptions "xtitle(Year) clpattern("l" "-" "-") legend(off) clwidth(medthick..) mlwidth(medthick..) yline(0.51219512, lstyle(foreground) extend) ylabel(0.48(0.02)0.6)"
set scheme s1mono

forvalues round = 1/4 {
    line prc_boys ub lb observation_age_m if round == `round', `goptions' ///
        xtitle("Years between Marriage and Interview") 
    graph export `figures'/recall_sex_ratio_marriage_round_`round'_bo2.eps, replace fontface(Palatino)
}
restore

