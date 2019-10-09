// Prior children mortality 

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

// Drop those less than 1 year old or without second births
drop if b2_born_cmc == .
drop if interview_cmc - b2_born_cmc < 13

// Dummy for died as infant
gen b1_died_as_infant = b1_dead_cmc - b1_born_cmc < 13 if b1_born_cmc != .
gen b2_died_as_infant = b2_dead_cmc - b2_born_cmc < 13 if b2_born_cmc != .
gen b3_died_as_infant = b3_dead_cmc - b3_born_cmc < 13 if b3_born_cmc != .
gen b4_died_as_infant = b4_dead_cmc - b4_born_cmc < 13 if b4_born_cmc != .

// Died 
gen b1_died_any = b1_dead_cmc != . if b1_born_cmc != .
gen b2_died_any = b2_dead_cmc != . if b2_born_cmc != .
gen b3_died_any = b3_dead_cmc != . if b3_born_cmc != .
gen b4_died_any = b4_dead_cmc != . if b4_born_cmc != .

gen b1_b2_died_any = b1_died_any | b2_died_any

// Died later than infant
gen b1_died_later = b1_died_any & !b1_died_as_infant if b1_born_cmc != .
gen b2_died_later = b2_died_any & !b2_died_as_infant if b2_born_cmc != .
gen b3_died_later = b3_died_any & !b3_died_as_infant if b3_born_cmc != .
gen b4_died_later = b4_died_any & !b4_died_as_infant if b4_born_cmc != .

gen b1_b2_died_later = b1_died_later | b2_died_later if b1_died_later != . & b2_died_later != .
gen b1_b2_b3_died_later = b1_died_later | b2_died_later | b3_died_later ///
    if b1_died_later != . & b2_died_later != . & b3_died_later != .

// Girl dummies
gen b1_girl = b1_sex == 2
gen b2_girl = b2_sex == 2
gen b3_girl = b3_sex == 2
gen b4_girl = b4_sex == 2

gen b2_only_girls = b1_girl & b2_girl if fertility > 2
gen b3_only_girls = b1_girl & b2_girl & b3_girl if fertility > 3

// Spacing 
gen b2_short_spacing = b2_space <= 24 if b2_space != .
gen b3_short_spacing = b3_space <= 24 if b3_space != .
gen b4_short_spacing = b4_space <= 24 if b4_space != .


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


// Descriptive statistics on mortality

table b1_group b1_girl if edu_mother >= 8, c(mean b1_died_later mean b2_short_spacing  ) by(urban)

table b2_group b2_only_girls if edu_mother >= 8, c(mean b1_b2_died_later mean b3_short_spacing   ) by(urban)
table b2_group b3_girl b2_only_girls if edu_mother >= 8, c(mean b1_b2_died_later mean b3_short_spacing  ) by(urban)

table b3_group b3_only_girls if edu_mother >= 8, c(mean b1_b2_b3_died_later mean b4_short_spacing  ) by(urban)
table b3_group b4_girl b3_only_girls if edu_mother >= 8, c(mean b1_b2_b3_died_later mean b4_short_spacing  ) by(urban)



