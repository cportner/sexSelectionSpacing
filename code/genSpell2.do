// genSpell2.do
// data manipulations for spell 2
// begun.: 2015-03-17
// Edited: 2016-02-10

keep if fertility >= 1

// dropping those with too much recall error
// the combined graphs looks like < 18 should be kept, but that might mask actual abortions
drop if observation_age_m >= 22 & round == 1
drop if observation_age_m >= 23 & round == 2
drop if observation_age_m >= 26 & round == 3
// drop if observation_age_m >= 20

gen mom_age    = b2_mom_age
gen mom_age2   = mom_age^2/100
lab var mom_age  "Wife's age at beginning of spell"
lab var mom_age2 "Wife's age squared / 100"

gen b1space = b1_space
gen b1space2 = b1space^2/100
global b1space " b1space b1space2 "

gen b1_born_year = int((b1_born_cmc-1)/12) if fertility >= 1
create_groups b1_born_year

drop if b2_space == .
gen org_b2_space = b2_space
replace b2_space = int((b2_space)/3) + 1 // 0-2 first quarter, 3-5 second, etc - now 9 months is **not** dropped
loc lastm = 4*6+3 //
// loc lastm = 4*6+4 //
// loc lastm = 4*6 //
replace b2_cen = 1 if b2_space > `lastm' // cut off 
replace b2_space = `lastm' if b2_space > `lastm'
replace b2_space = b2_space - 3 // start when pregnancy can occur
global lastm = `lastm'-3
drop if b2_space < 1

// Changing area of residence to residence at end of spell
gen endSpellYear = int((b1_born_cmc+org_b2_space-1)/12)+1900
gen moved = (interview_year - placeYearLived) > endSpellYear  // has moved **after** end of spell and therefore has "wrong" area for that spell
replace urban = 0 if moved & placePrevious == 2 & urban == 1
replace urban = 1 if moved & placePrevious == 1 & urban == 0

// replace b2_girls = b1_sex == 2 if b1_sex != .
gen girl1 = b1_sex == 2 if b1_sex != .
gen girl1Xurban = girl1 * urban

gen gu_group = 1 if !girl1 & !urban
replace gu_group = 2 if girl1 & !urban
replace gu_group = 3 if !girl1 & urban
replace gu_group = 4 if girl1 & urban
label def gu 1 "Rural, 1 boy" 2 "Rural, 1 girl" 3 "Urban, 1 boy" 4 "Urban, 1 girl"
label val gu_group gu
global spell = "2"

replace scheduled_caste = 1 if scheduled_tribe

// local variables
// global caste    "scheduled_caste scheduled_tribe "
global caste    "scheduled_caste "
global hh       "land_own "
global parents  "mom_age "
gen id = _n

compress

