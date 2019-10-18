// Comparison with no correction for censoring

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


// Girl and boy dummies
gen b1_girl = b1_sex == 2 if b1_born_cmc != .
gen b2_girl = b2_sex == 2 if b2_born_cmc != .
gen b3_girl = b3_sex == 2 if b3_born_cmc != .
gen b4_girl = b4_sex == 2 if b4_born_cmc != .

gen b1_boy = b1_sex == 1 if b1_born_cmc != .
gen b2_boy = b2_sex == 1 if b2_born_cmc != .
gen b3_boy = b3_sex == 1 if b3_born_cmc != .
gen b4_boy = b4_sex == 1 if b4_born_cmc != .



gen b2_only_girls = b1_girl & b2_girl if fertility >= 2
gen b3_only_girls = b1_girl & b2_girl & b3_girl if fertility >= 3

gen b2_number_girls = b1_girl + b2_girl if fertility >= 2
gen b3_number_girls = b1_girl + b2_girl + b3_girl if fertility >= 3

// Fertility numbers
gen has_2nd_child = b2_born_cmc != . & b2_space <= 105
gen has_3rd_child = b3_born_cmc != . & b3_space <= 105
gen has_4th_child = b4_born_cmc != . & b4_space <= 105

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

// The spacing results in the paper starts at 9 months, but the data here starts at
// zero months

// gen b2_interval = b2_space - 8 if b2_born_cmc != . & b2_space - 8 <= 96
// gen b3_interval = b3_space - 8 if b3_born_cmc != . & b3_space - 8 <= 96
// gen b4_interval = b4_space - 8 if b4_born_cmc != . & b4_space - 8 <= 96

gen b2_interval = b2_space - 8 if b2_born_cmc != . 
gen b3_interval = b3_space - 8 if b3_born_cmc != . 
gen b4_interval = b4_space - 8 if b4_born_cmc != . 



// Uncorrected intervals, sex ratios, and parity progression probability
table b1_group b1_girl if edu_mother >= 8 , c(mean b2_interval mean b2_boy mean has_2nd_child ) by(urban)

table b2_group b2_number_girls if edu_mother >= 8 , c(mean b3_interval mean b3_boy mean has_3rd_child) by(urban)

table b3_group b3_number_girls if edu_mother >= 8 , c(mean b4_interval mean b4_boy mean has_4th_child) by(urban)


// Percentile uncorrected intervals
table b1_group b1_girl if edu_mother >= 8 , c(p25 b2_interval p50 b2_interval p75 b2_interval ) by(urban)

table b2_group b2_number_girls if edu_mother >= 8 , c(p25 b3_interval p50 b3_interval p75 b3_interval ) by(urban)

table b3_group b3_number_girls if edu_mother >= 8 , c(p25 b4_interval p50 b4_interval p75 b4_interval ) by(urban)




