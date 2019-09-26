// Infant mortality and birth spacing

clear all
version 15.1
set more off

include directories

use `data'/base, clear

// Drop those less than 1 year old or without second births
drop if b2_born_cmc == .
drop if interview_cmc - b2_born_cmc < 13

// Dummy for died as infant
gen died_as_infant = b2_dead_cmc - b2_born_cmc < 13

// Girl dummies
gen b1_girl = b1_sex == 2
gen b2_girl = b2_sex == 2

// Year groups
gen b1_born_year = int((b1_born_cmc-1)/12)
create_groups b1_born_year

// Birth spacing variables
gen b2_space_2 = b2_space^2
gen b2_space_3 = b2_space^3
gen b2_space_4 = b2_space^4

egen spacing_group = cut(b2_space), at(9(3)120)


