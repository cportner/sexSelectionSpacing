* Descriptive statistics for all 36 regressions
* andes_stat.do
* begun.: 07/05/10
* edited: 2016-02-29

version 13.1
clear all

loc work "/net/proj/India_NFHS/base"
loc figdir "/net/proj/India_NFHS/graphs"
// loc figdir "/net/home/cportner/data/sexselection/graphs"


/*-------------------------------------------------------------------*/
/* LOADING DATA AND CREATING NEW VARIABLES                           */
/*-------------------------------------------------------------------*/

use `work'/base

keep if hindu 
drop if observation_age_m >= 22 & round == 1
drop if observation_age_m >= 23 & round == 2
drop if observation_age_m >= 26 & round == 3

lab var land_own "Owns land"

gen b0_born_year = int((marriage_cmc-1)/12)
gen b1_born_year = int((b1_born_cmc-1)/12) if fertility >= 1
gen b2_born_year = int((b2_born_cmc-1)/12) if fertility >= 2
gen b3_born_year = int((b3_born_cmc-1)/12) if fertility >= 3


* SPELL 1
preserve
gen group = 1 if b0_born_year <= 84
replace group = 2 if b0_born_year >= 85 & b0_born_year <= 94
replace group = 3 if b0_born_year >= 95

drop if b1_mom_age < 12 
drop if edu_mother == .
drop if edu_father == . | edu_father > 30
drop if b1_space == .
drop if land_own == .
gen mom_age    = b1_mom_age

replace b1_space = int((b1_space)/3) + 1 // 1-3 first quarter, 4-6 second etc
loc lastm = 4*6 //
replace b1_cen = 1 if b1_space > `lastm' // cut off 
replace b1_space = `lastm' if b1_space > `lastm'
// replace b1_space = b1_space - 3 // start when pregnancy can occur - oops that was a mistake on 1st spell
loc lastm = `lastm'-3
drop if b1_space < 1

gen boy = b1_sex == 1 & !b1_cen
gen girl = b1_sex == 2 & !b1_cen

gen edu_group = 1 if edu_mother == 0
replace edu_group = 2 if edu_mother >= 1 & edu_mother <= 7
replace edu_group = 3 if edu_mother >= 8

replace scheduled_caste = 1 if scheduled_tribe


lab var boy     "Boy born"
lab var girl    "Girl born"
lab var b1_cen  "Censored"
lab var urban   "Urban"
lab var mom_age "Age"
lab var scheduled_caste "Scheduled caste or tribe"

tab fertility

bysort edu_group group: eststo: estpost sum boy girl b1_cen urban mom_age land_own scheduled_caste
esttab using `work'/des_stat.tex, ///
    main(mean %9.3fc) aux(sd %9.3fc) noobs label nonotes nogaps ///
    replace fragment nomtitles nonumber

eststo clear
bysort edu_group group: eststo: estpost sum b1_space
lab var b1_space "Number of quarters"
esttab using `work'/des_stat.tex , ///
    main(sum %9.0fc ) not noobs label nogaps nolines nonotes ///
    fragment nomtitles nonumber append delimiter("} & \mco{" ) end("} \\") compress

eststo clear
lab var b1_space "Number of women"
bysort edu_group group: eststo: estpost sum b1_space
esttab using `work'/des_stat.tex , ///
    main(count %9.0fc ) not noobs label nogaps nolines nonotes ///
    fragment nomtitles nonumber append delimiter("} & \mco{" ) end("} \\") compress

restore


* SPELL 2

preserve
keep if fertility >= 1
gen group = 1 if b1_born_year <= 84
replace group = 2 if b1_born_year >= 85 & b1_born_year <= 94
replace group = 3 if b1_born_year >= 95

drop if b2_mom_age < 12
drop if edu_mother == .
drop if edu_father == . | edu_father > 30
drop if b1_space == .
drop if b2_space == .
drop if b2_space <= 8
drop if land_own == .

gen mom_age    = b2_mom_age

gen b1space = b1_space

replace b2_space = int((b2_space)/3) + 1 // 1-3 first quarter, 4-6 second etc
loc lastm = 4*6 //
replace b2_cen = 1 if b2_space > `lastm' // cut off 
replace b2_space = `lastm' if b2_space > `lastm'
replace b2_space = b2_space - 3 // start when pregnancy can occur
loc lastm = `lastm'-3
drop if b2_space < 1

gen boy = b2_sex == 1 & !b2_cen
gen girl = b2_sex == 2 & !b2_cen

gen b1_girl = b1_sex == 2 if b1_sex != .
gen b1_boy  = b1_sex == 1 if b1_sex != .

gen edu_group = 1 if edu_mother == 0
replace edu_group = 2 if edu_mother >= 1 & edu_mother <= 7
replace edu_group = 3 if edu_mother >= 8

replace scheduled_caste = 1 if scheduled_tribe

lab var boy     "Boy born"
lab var girl    "Girl born"
lab var b2_cen  "Censored"
lab var b1_boy  "One boy"
lab var b1_girl "One girl"
lab var urban   "Urban"
lab var b1_space "First spell length"
lab var mom_age "Age"
lab var scheduled_caste "Scheduled caste or tribe"


eststo clear
bysort edu_group group: eststo: estpost sum boy girl b2_cen ///
    b1_boy b1_girl urban mom_age b1_space land_own scheduled_caste
esttab using `work'/des_stat.tex, ///
    main(mean %9.3fc) aux(sd %9.3fc) noobs label nonotes nogaps ///
    append fragment nomtitles nonumber

eststo clear
bysort edu_group group: eststo: estpost sum b2_space
lab var b2_space "Number of quarters"
esttab using `work'/des_stat.tex , ///
    main(sum %9.0fc ) not noobs label nogaps nolines nonotes ///
    fragment nomtitles nonumber append delimiter("} & \mco{" ) end("} \\") compress

eststo clear
lab var b2_space "Number of women"
bysort edu_group group: eststo: estpost sum b2_space
esttab using `work'/des_stat.tex , ///
    main(count %9.0fc ) not noobs label nogaps nolines nonotes ///
    fragment nomtitles nonumber append delimiter("} & \mco{" ) end("} \\") compress

restore



* SPELL 3

preserve
keep if fertility >= 2
gen group = 1 if b2_born_year <= 84
replace group = 2 if b2_born_year >= 85 & b2_born_year <= 94
replace group = 3 if b2_born_year >= 95

drop if b2_mom_age < 12 | b3_mom_age < 14
drop if edu_mother == .
drop if edu_father == . | edu_father > 30
drop if b1_space == .
drop if b2_space == .
drop if b2_space <= 8
drop if b3_space == .
drop if b3_space <= 8
drop if land_own == .

gen mom_age    = b3_mom_age
gen b1space = b1_space

replace b3_space = int((b3_space)/3) + 1 // 1-3 first quarter, 4-6 second etc
loc lastm = 4*6 //
replace b3_cen = 1 if b3_space > `lastm' // cut off 
replace b3_space = `lastm' if b3_space > `lastm'
replace b3_space = b3_space - 3 // start when pregnancy can occur
loc lastm = `lastm'-3
drop if b3_space < 1

gen boy = b3_sex == 1 & !b3_cen
gen girl = b3_sex == 2 & !b3_cen

egen numgirls = anycount(b1_sex b2_sex) if b1_sex != . & b2_sex != ., v(2)
gen b2_2b   = numgirls == 0
gen b2_1b1g = numgirls == 1
gen b2_2g   = numgirls == 2

gen edu_group = 1 if edu_mother == 0
replace edu_group = 2 if edu_mother >= 1 & edu_mother <= 7
replace edu_group = 3 if edu_mother >= 8

replace scheduled_caste = 1 if scheduled_tribe

lab var boy     "Boy born"
lab var girl    "Girl born"
lab var b3_cen  "Censored"
lab var b2_2b   "Two boys"
lab var b2_1b1g "One boy, one girl"
lab var b2_2g   "Two girls"
lab var urban   "Urban"
lab var b1_space "First spell length"
lab var mom_age "Age"
lab var scheduled_caste "Scheduled caste or tribe"

eststo clear
bysort edu_group group: eststo: estpost sum boy girl b3_cen ///
    b2_2b b2_1b1g b2_2g urban mom_age b1_space land_own scheduled_caste
esttab using `work'/des_stat.tex, ///
    main(mean %9.3fc) aux(sd %9.3fc) noobs label nonotes nogaps ///
    append fragment nomtitles nonumber

eststo clear
bysort edu_group group: eststo: estpost sum b3_space
lab var b3_space "Number of quarters"
esttab using `work'/des_stat.tex , ///
    main(sum %9.0fc ) not noobs label nogaps nolines nonotes ///
    fragment nomtitles nonumber append delimiter("} & \mco{" ) end("} \\") compress

eststo clear
lab var b3_space "Number of women"
bysort edu_group group: eststo: estpost sum b3_space
esttab using `work'/des_stat.tex , ///
    main(count %9.0fc ) not noobs label nogaps nolines nonotes ///
    fragment nomtitles nonumber append delimiter("} & \mco{" ) end("} \\") compress

restore


* SPELL 4

preserve
keep if fertility >= 3
gen group = 1 if b3_born_year <= 84
replace group = 2 if b3_born_year >= 85 & b3_born_year <= 94
replace group = 3 if b3_born_year >= 95

drop if b2_mom_age < 12 | b3_mom_age < 14 | b4_mom_age < 15
drop if edu_mother == .
drop if edu_father == . | edu_father > 30
drop if b1_space == .
drop if b2_space == .
drop if b2_space <= 8
drop if b3_space == .
drop if b3_space <= 8
drop if b4_space == .
drop if b4_space <= 8
drop if land_own == .

gen mom_age    = b4_mom_age
gen b1space = b1_space

replace b4_space = int((b4_space)/3) + 1 // 1-3 first quarter, 4-6 second etc
loc lastm = 19+3 //
replace b4_cen = 1 if b4_space > `lastm' // cut off 
replace b4_space = `lastm' if b4_space > `lastm'
replace b4_space = b4_space - 3 // start when pregnancy can occur
loc lastm = `lastm'-3
drop if b4_space < 1

gen boy = b4_sex == 1 & !b4_cen
gen girl = b4_sex == 2 & !b4_cen

egen numgirls = anycount(b1_sex b2_sex b3_sex) if b1_sex != . & b2_sex != . & b3_sex != ., v(2)
gen girl0 = numgirls == 0 if b1_sex != . & b2_sex != . & b3_sex != .
gen girl1 = numgirls == 1 if b1_sex != . & b2_sex != . & b3_sex != .
gen girl2 = numgirls == 2 if b1_sex != . & b2_sex != . & b3_sex != .
gen girl3 = numgirls == 3 if b1_sex != . & b2_sex != . & b3_sex != .

gen edu_group = 1 if edu_mother == 0
replace edu_group = 2 if edu_mother >= 1 & edu_mother <= 7
replace edu_group = 3 if edu_mother >= 8

replace scheduled_caste = 1 if scheduled_tribe

lab var boy     "Boy born"
lab var girl    "Girl born"
lab var b4_cen  "Censored"
lab var girl0   "Three boys"
lab var girl1   "Two boys, one girl"
lab var girl2   "One boys, two girls"
lab var girl3   "Three girls"
lab var urban   "Urban"
lab var b1_space "First spell length"
lab var mom_age "Age"
lab var scheduled_caste "Scheduled caste or tribe"


eststo clear
bysort edu_group group: eststo: estpost sum boy girl b4_cen ///
    girl0-girl3 urban mom_age b1_space land_own scheduled_caste
esttab using `work'/des_stat.tex, ///
    main(mean %9.3fc) aux(sd %9.3fc) noobs label nonotes nogaps ///
    append fragment nomtitles nonumber

eststo clear
bysort edu_group group: eststo: estpost sum b4_space
lab var b4_space "Number of quarters"
esttab using `work'/des_stat.tex , ///
    main(sum %9.0fc ) not noobs label nogaps nolines nonotes ///
    fragment nomtitles nonumber append delimiter("} & \mco{" ) end("} \\") compress

eststo clear
lab var b4_space "Number of women"
bysort edu_group group: eststo: estpost sum b4_space
esttab using `work'/des_stat.tex , ///
    main(count %9.0fc ) not noobs label nogaps nolines nonotes ///
    fragment nomtitles nonumber append delimiter("} & \mco{" ) end("} \\") compress

restore


