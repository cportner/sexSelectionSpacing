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


/*-------------------------------------------------------------------*/
/* DEVELOPMENT IN SEX RATIOS							             */
/*-------------------------------------------------------------------*/

// prepares data for analysis
//preserve
keep round survey urban mar_year observation_age* mom_id b*_sex b*_born_cmc
reshape long b@_sex b@_born_cmc, i(mom_id) j(bo)
drop if b_sex == .
gen born_year = int((b_born_cmc-1)/12)+1900
// drop if born_year < `startyear'
recode b_sex (2=0)

// Focus on first-born
keep if bo == 1
egen mar_2yr_group = cut(observation_age_m) , ///
    at(0, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29, 31, 33, 41) icodes
drop if mar_2yr_group == . //  Anybody married for 41+ years at time of survey
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
        xtitle("NFHS-`round'") xlabel(0(10)30)
    graph export `figures'/recall_sex_ratio_marriage_round_`round'.eps, replace fontface(Palatino)
}


