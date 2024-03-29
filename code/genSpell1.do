// genSpell1.do
// data manipulation for spell 1
// begun.: 2015-03-17
// Edited: 2016-02-10

// dropping those with too much recall error
drop if observation_age_m >= 22 & round == 1
drop if observation_age_m >= 22 & round == 2
drop if observation_age_m >= 22 & round == 3
drop if observation_age_m >= 22 & round == 4

gen mom_age    = b1_mom_age
gen mom_age2   = mom_age^2/100
lab var mom_age  "Wife's age at beginning of spell"
lab var mom_age2 "Wife's age squared / 100"

gen b0_born_year = int((marriage_cmc-1)/12) 
create_groups b0_born_year

gen org_b1_space = b1_space
replace b1_space = int((b1_space)/3) + 1 // 0-2 first quarter, 3-5 second, etc - now 9 months is **not** dropped
loc lastm = 4*10 // 10 years after marriage (rather than 6 in original version)
replace b1_cen = 1 if b1_space > `lastm' // cut off 
replace b1_space = `lastm' if b1_space > `lastm'
global lastm = `lastm'

// // Changing area of residence to residence at end of spell
// gen endSpellYear = int((marriage_cmc+org_b1_space-1)/12)+1900
// gen moved = (interview_year - placeYearLived) > endSpellYear  // has moved **after** end of spell and therefore has "wrong" area for that spell
// replace urban = 0 if moved & placePrevious == 2 & urban == 1
// replace urban = 1 if moved & placePrevious == 1 & urban == 0

gen gu_group = 1 if !urban
replace gu_group = 2 if urban
label def gu 1 "Rural" 2 "Urban"
label val gu_group gu
global spell = "1"

replace scheduled_caste = 1 if scheduled_tribe

// Glocal variables
// global caste    "scheduled_caste scheduled_tribe "
global b1space  " " // there are no prior births
global caste    "scheduled_caste "
global hh       "land_own "
global parents  "mom_age "
gen id = _n

compress
