// Predicted Total Marital Fertility Rate

// TFR-like estimate using base data for married women.
//
// This is a very bad idea since it give unrealistical high predicted fertility numbers. 
// Specifically, the fertility rate for first-born is higher than 1. Turns out that this
// is a known problem for this measure (see Hoem and Mureşan 2011; https://www.jstor.org/stable/41474433). 
// I have kept the file in the interest of completeness.

clear
version 15.1
set more off

// Generic set of locations
include directories


use `data'/base, clear

// Useful variables:
// interview_cmc 	date of interview (cmc)
// edu_mother 		Wife's education in years
// urban 			Live in urban area
// fertility		Number of children ever born
// bX_born_cmc		Date of parity X child born (cmc)
// mother_age		Respondent's current age at survey

// Restrict to match hazard model sample
// keep if fertility > 0
keep if hindu 
keep if mother_age >= 15 & mother_age < 46
drop if observation_age_m >= 22 & round == 1
drop if observation_age_m >= 22 & round == 2
drop if observation_age_m >= 22 & round == 3
drop if observation_age_m >= 22 & round == 4

// 5-year age groups
egen age_group = cut(mother_age ) , at(15(5)40 46)

// Education groupings
gen edu_group = 1 if edu_mother == 0
replace edu_group = 2 if edu_mother >= 1 & edu_mother <= 7
replace edu_group = 3 if edu_mother >= 8 & edu_mother <= 11
replace edu_group = 4 if edu_mother >= 12


// 3-year fertility rate by age
// The 3-year period is what is used by NFHS reports for TFR
// Births in the month of interview are not included as in DHS
// See "Guide to DHS Statistics 5.2 (~ p 186)
forvalues parity = 1/4 {
    assert interview_cmc >= b`parity'_born_cmc if b`parity'_born_cmc != .
	// birth of parity `parity' in 3 years before survey date
	gen birth_3yr_`parity' = (interview_cmc - b`parity'_born_cmc) >= 1 & ///
	    (interview_cmc - b`parity'_born_cmc) <= 36
	// birth of parity `parity' in 1 year before survey date
	gen birth_1yr_`parity' = (interview_cmc - b`parity'_born_cmc) >= 1 & ///
	    (interview_cmc - b`parity'_born_cmc) <= 12
}


gen births_3yr_1_to_4 = birth_3yr_1 + birth_3yr_2 + birth_3yr_3 + birth_3yr_4
gen births_1yr_1_to_4 = birth_1yr_1 + birth_1yr_2 + birth_1yr_3 + birth_1yr_4


// 
collapse  (count) num_women = fertility ///
    (sum) num_births_3yr_bo_1 = birth_3yr_1 ///
    (sum) num_births_3yr_bo_2 = birth_3yr_2 ///
    (sum) num_births_3yr_bo_3 = birth_3yr_3 ///
    (sum) num_births_3yr_bo_4 = birth_3yr_4 ///
    (sum) num_births_3yr = births_3yr_1_to_4 ///
    (sum) num_births_1yr = births_1yr_1_to_4, ///
	by(round urban edu_group age_group)


// age-specific birth rate (Convert back to births by year for 3-year)
forvalues bo = 1/4 {
    gen asbr_3yr_bo_`bo' = 5 * (num_births_3yr_bo_`bo' / 3) / num_women 
}
gen asbr_3yr = 5 * (num_births_3yr / 3) / num_women 
gen asbr_1yr = 5 * num_births_1yr / num_women 


// Calculate "TFR" for parities 2 through 4 and 
// combined "TFR" based on 3 and 1 year births
// (See Bongaarts 1999
collapse ///
    (sum) tfr_3yr_bo_1 = asbr_3yr_bo_1 ///
    (sum) tfr_3yr_bo_2 = asbr_3yr_bo_2 ///
    (sum) tfr_3yr_bo_3 = asbr_3yr_bo_3 ///
    (sum) tfr_3yr_bo_4 = asbr_3yr_bo_4 ///
    (sum) tfr_3yr=asbr_3yr ///
    (sum) tfr_1yr=asbr_1yr , ///
	by(round urban edu_group)

list

