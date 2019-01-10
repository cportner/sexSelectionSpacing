// genSpell4.do
// data manipulations need for all spell 4 analyses
// begun.: 2015-03-17
// Edited: 2016-02-10

keep if fertility >= 3

// dropping those with too much recall error
drop if observation_age_m >= 22 & round == 1
drop if observation_age_m >= 22 & round == 2
drop if observation_age_m >= 22 & round == 3
drop if observation_age_m >= 22 & round == 4

gen mom_age    = b4_mom_age
gen mom_age2   = mom_age^2/100
lab var mom_age  "Wife's age at beginning of spell"
lab var mom_age2 "Wife's age squared / 100"

gen b1space = b1_space
gen b1space2 = b1space^2/100
global b1space " b1space b1space2 "

gen b3_born_year = int((b3_born_cmc-1)/12) 
create_groups b3_born_year

drop if b4_space == .
gen org_b4_space = b4_space
replace b4_space = int((b4_space)/3) + 1 // 0-2 first quarter, 3-5 second, etc - now 9 months is **not** dropped
loc lastm = 4*8+3
replace b4_cen = 1 if b4_space > `lastm' // cut off 
replace b4_space = `lastm' if b4_space > `lastm'
replace b4_space = b4_space - 3 // start when pregnancy can occur
global lastm = `lastm'-3
drop if b4_space < 1

// // Changing area of residence to residence at end of spell
// gen endSpellYear = int((b3_born_cmc+org_b4_space-1)/12)+1900
// gen moved = (interview_year - placeYearLived) > endSpellYear  // has moved **after** end of spell and therefore has "wrong" area for that spell
// replace urban = 0 if moved & placePrevious == 2 & urban == 1
// replace urban = 1 if moved & placePrevious == 1 & urban == 0

egen numgirls = anycount(b1_sex b2_sex b3_sex), v(2)
gen girl1 = numgirls == 1 if b1_sex != . & b2_sex != . & b3_sex != .
gen girl2 = numgirls == 2 if b1_sex != . & b2_sex != . & b3_sex != .
gen girl3 = numgirls == 3 if b1_sex != . & b2_sex != . & b3_sex != .

tab numgirls

gen girl1Xurban = girl1 * urban
gen girl2Xurban = girl2 * urban
gen girl3Xurban = girl3 * urban

assert girl1 != . & girl2 != . & girl3 != .

gen gu_group = 1 if numgirls == 0 & !urban
replace gu_group = 2 if girl1 & !urban
replace gu_group = 3 if girl2 & !urban
replace gu_group = 4 if girl3 & !urban
replace gu_group = 5 if numgirls == 0 & urban
replace gu_group = 6 if girl1 & urban
replace gu_group = 7 if girl2 & urban
replace gu_group = 8 if girl3 & urban

label def gu 1 "Rural, 3 boys" 2 "Rural, 2 boys / 1 girl" 3 "Rural, 1 bosy / 2 girls" 4 "Rural, 3 girls" 5 "Urban, 3 boys" 6 "Urban, 2 boys / 1 girl" 7 "Urban, 1 bosy / 2 girls" 8 "Urban, 3 girls"
label val gu_group gu
global spell = "4"

replace scheduled_caste = 1 if scheduled_tribe

// local variables
// global caste    "scheduled_caste scheduled_tribe "
global caste    "scheduled_caste "
global hh       "land_own "
global parents  "mom_age "
gen id = _n

compress
