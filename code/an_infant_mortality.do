// Infant mortality and birth spacing

clear all
version 15.1
set more off

include directories

use `data'/base, clear

// Base data already has most of the information
// b2_space 1st -> 2nd birth
// b2_sex 2nd child sex
// b2_dead_cmc CMC dated month of death
// b2_born_cmc CMC birth month

// Create variables to match hazard models
replace scheduled_caste = 1 if scheduled_tribe

// Drop those less than 1 year old or without second births
drop if b2_born_cmc == .
drop if interview_cmc - b2_born_cmc < 13

// Dummy for died as infant
gen b2_died_as_infant = b2_dead_cmc - b2_born_cmc < 13 if b2_born_cmc != .
gen b3_died_as_infant = b3_dead_cmc - b3_born_cmc < 13 if b3_born_cmc != .
gen b4_died_as_infant = b4_dead_cmc - b4_born_cmc < 13 if b4_born_cmc != .


// Girl dummies
gen b1_girl = b1_sex == 2
gen b2_girl = b2_sex == 2
gen b3_girl = b3_sex == 2
gen b4_girl = b4_sex == 2

gen b2_only_girls = b1_girl & b2_girl if fertility > 2
gen b3_only_girls = b1_girl & b2_girl & b3_girl if fertility > 3


// Year groups
gen b1_born_year = int((b1_born_cmc-1)/12)
create_groups b1_born_year
gen b1_group = group
drop group
gen b2_born_year = int((b2_born_cmc-1)/12)
create_groups b2_born_year
gen b2_group = group
drop group
gen b3_born_year = int((b3_born_cmc-1)/12)
create_groups b3_born_year
gen b3_group = group
drop group

// Birth spacing variables
replace b2_space = b2_space - 9
replace b3_space = b3_space - 9
replace b4_space = b4_space - 9

gen b2_space_2 = b2_space^2
gen b2_space_3 = b2_space^3
gen b2_space_4 = b2_space^4

egen spacing_group = cut(b2_space), at(9(3)120)

gen b2_short_spacing = b2_space <= 24 if b2_space != .
gen b3_short_spacing = b3_space <= 24 if b3_space != .
gen b4_short_spacing = b4_space <= 24 if b4_space != .

gen b2_less_short_spacing = b2_space <= 36 if b2_space != .
gen b3_less_short_spacing = b3_space <= 36 if b3_space != .
gen b4_less_short_spacing = b4_space <= 36 if b4_space != .


// // Descriptive stats:
// 
// // Overall development in infant mortality
// bysort urban: tabulate b1_group b1_girl       if edu_mother >= 8 , summarize(b2_died_as_infant ) means
// bysort urban: tabulate b2_group b2_only_girls if edu_mother >= 8 , summarize(b3_died_as_infant ) means
// bysort urban: tabulate b3_group b3_only_girls if edu_mother >= 8 , summarize(b4_died_as_infant ) means
// 
// 
// table b2_group b2_only_girls  if edu_mother >= 8, c(mean b3_died_as_infant ) by(urban)
// 
// // Decomposition of mortality changes
// bysort urban b3_short_spacing : tabulate b2_group b2_only_girls if edu_mother >= 8 , summarize(b3_died_as_infant ) means
// bysort urban b3_short_spacing b3_girl : tabulate b2_group b2_only_girls if edu_mother >= 8 , summarize(b3_died_as_infant ) means
// 
// table b2_group b2_only_girls  b3_short_spacing  if edu_mother >= 8, c(mean b3_died_as_infant ) by(urban )
// table b2_group b2_only_girls  b3_short_spacing  if edu_mother >= 8, c(mean b3_died_as_infant ) by(urban b3_girl )
// 
// bysort urban b3_short_spacing : tabulate b2_group b2_only_girls if edu_mother >= 8 , summarize( b3_girl ) means
// 
// 
// // Changes in spacing patterns
// bysort urban  : tabulate b2_group b2_only_girls if edu_mother >= 8 , summarize( b3_short_spacing  ) means
// bysort urban b3_girl : tabulate b2_group b2_only_girls if edu_mother >= 8 , summarize( b3_short_spacing  ) means
// 

// example estimation for second birth

keep if edu_mother >= 12
keep if b1_group == 4
keep if b2_space <= 96

reg b2_died_as_infant b1_girl b1_mom_age scheduled_caste land_own urban /// 
    i.b2_girl##(c.b2_space c.b2_space#c.b2_space c.b2_space#c.b2_space#c.b2_space c.b2_space#c.b2_space#c.b2_space#c.b2_space)     

margins, at(b2_space==(1(3)96))

marginsplot
