// Predicted fertility 

clear
version 15.1
set more off

// Generic set of locations
include directories


// "TFR" like estimate based on base data

use `data'/base, clear

// Useful variables:
// interview_cmc 	date of interview (cmc)
// edu_mother 		Wife's education in years
// urban 			Live in urban area
// fertility		Number of children ever born
// bX_born_cmc		Date of parity X child born (cmc)
// mother_age		Respondent's current age at survey

// Restrict to match hazard model sample
keep if fertility > 0
keep if hindu 
drop if observation_age_m >= 22 & round == 1
drop if observation_age_m >= 22 & round == 2
drop if observation_age_m >= 22 & round == 3
drop if observation_age_m >= 22 & round == 4

// Education groupings
gen edu_group = 1 if edu_mother == 0
replace edu_group = 2 if edu_mother >= 1 & edu_mother <= 7
replace edu_group = 3 if edu_mother >= 8


// 3-year fertility rate by age
// The 3-year period is what is used by NFHS reports for TFR
// Might also be worth trying just within the last year
forvalues parity = 2/4 {
	// birth of parity `parity' in 3 years before survey date
	gen birth_3yr_`parity' = (interview_cmc - b`parity'_born_cmc) < 36
}

gen births_3yr_2_to_4 = birth_3yr_2 + birth_3yr_3 + birth_3yr_4

// Convert back to births by year
replace births_3yr_2_to_4 = births_3yr_2_to_4 / 3

collapse  (count) count=fertility (sum) num_births=births_3yr_2_to_4, ///
	by(round urban edu_group mother_age)

// age-specific birth rate
gen asbr = num_births / count

// Calculate "TFR" for parities 2 through 4
collapse, (sum) tfr=asbr ///
	by(round urban edu_group)


