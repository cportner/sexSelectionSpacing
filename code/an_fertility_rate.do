// Predicted Total Fertility Rate

// The NFHS reports do not match the sample I use, so calculate TFR for the relevant
// samples instead. Cannot use base (or any of the base files for the rounds), since those
// drop all never-married women early on. Hence, load needed data directly. Only need
// some very basic information for TFR (urban/rural, education, and timing of births).

clear
version 15.1
set more off

// Generic set of locations
include directories


// NFHS-4

// use caseid v001-v012 v024 ///
//    v102 v104 v105 v130-v135 ///
//    bidx_01-b16_20 ///
//    v224 ///
//    s116 using `rawdata'/iair72fl
// 
// // keep if v135 == 1 // usual resident in hh
// // drop if v104 == 96 // visitor to hh
// 
// // urban-rural
// gen urban = v102 == 1
// gen rural = v102 == 2
// ren v102 urban_rural
// 
// // religion
// gen hindu = v130 == 1
// 
// ren v008 interview_cmc
// ren v012 mother_age   
// 
// ren v133 edu_mother
// drop if edu_mother > 30
// 
// ren v224 fertility
// 
// // Useful variables:
// // interview_cmc 	date of interview (cmc)
// // edu_mother 		Wife's education in years
// // urban 			Live in urban area
// // fertility		Number of children ever born
// // bX_born_cmc		Date of parity X child born (cmc)
// // mother_age		Respondent's current age at survey
// 
// // Restrict to match hazard model sample
// // keep if fertility > 0
// keep if hindu 
// keep if mother_age >= 15 & mother_age < 46
// 
// // drop women with multiple births if birth order 4 or lower
// forvalues i = 1/20 {
//     if `i' < 10 {
//         loc var = "0`i'"
//     } 
//     else {
//         loc var = "`i'"
//     }
//     drop if b0_`var' > 0 & bord_`var' < 5
// }
// 
// 
// // birth variables
// 
// // first spacing (marriage to first birth or interview)
// gen b1_born_cmc = .
// forvalues i = 1/20 {
//     if `i' < 10 {
//         loc var = "0`i'"
//     } 
//     else {
//         loc var = "`i'"
//     }
//     replace b1_born_cmc = b3_`var' if bord_`var' == 1
// }
// 
// // second and higher spacing
// forvalues bo = 2/20 {
//     loc bom1 = `bo'-1
//     gen b`bo'_born_cmc = .
//     forvalues i = 1/20 {
//         if `i' < 10 {
//             loc var = "0`i'"
//         }
//         else {
//             loc var = "`i'"
//         }
//         replace b`bo'_born_cmc = b3_`var' if bord_`var' == `bo'
//     }
// }
// 
// 
// // 5-year age groups
// egen age_group = cut(mother_age ) , at(15(5)40 46)
// 
// // Education groupings
// gen edu_group = 1 if edu_mother == 0
// replace edu_group = 2 if edu_mother >= 1 & edu_mother <= 7
// replace edu_group = 3 if edu_mother >= 8 
// 
// 
// // replace edu_group = 3 if edu_mother >= 8 & edu_mother <= 11
// // replace edu_group = 4 if edu_mother >= 12
// 
// 
// // 3-year fertility rate by age
// // The 3-year period is what is used by NFHS reports for TFR
// // Births in the month of interview are not included as in DHS
// // See "Guide to DHS Statistics 5.2 (~ p 186)
// forvalues parity = 1/4 {
//     assert interview_cmc >= b`parity'_born_cmc if b`parity'_born_cmc != .
// 	// birth of parity `parity' in 3 years before survey date
// 	gen birth_3yr_`parity' = (interview_cmc - b`parity'_born_cmc) >= 1 & ///
// 	    (interview_cmc - b`parity'_born_cmc) <= 36
// 	// birth of parity `parity' in 1 year before survey date
// 	gen birth_1yr_`parity' = (interview_cmc - b`parity'_born_cmc) >= 1 & ///
// 	    (interview_cmc - b`parity'_born_cmc) <= 12
// }
// 
// 
// gen births_3yr_1_to_4 = birth_3yr_1 + birth_3yr_2 + birth_3yr_3 + birth_3yr_4
// gen births_1yr_1_to_4 = birth_1yr_1 + birth_1yr_2 + birth_1yr_3 + birth_1yr_4
// 
// 
// // 
// collapse  (count) num_women = fertility ///
//     (sum) num_births_3yr_bo_1 = birth_3yr_1 ///
//     (sum) num_births_3yr_bo_2 = birth_3yr_2 ///
//     (sum) num_births_3yr_bo_3 = birth_3yr_3 ///
//     (sum) num_births_3yr_bo_4 = birth_3yr_4 ///
//     (sum) num_births_3yr = births_3yr_1_to_4 ///
//     (sum) num_births_1yr = births_1yr_1_to_4, ///
// 	by(urban edu_group age_group)
// 
// 
// // age-specific birth rate (Convert back to births by year for 3-year)
// forvalues bo = 1/4 {
//     gen asbr_3yr_bo_`bo' = 5 * (num_births_3yr_bo_`bo' / 3) / num_women 
// }
// gen asbr_3yr = 5 * (num_births_3yr / 3) / num_women 
// gen asbr_1yr = 5 * num_births_1yr / num_women 
// 
// 
// // Calculate "TFR" for parities 2 through 4 and 
// // combined "TFR" based on 3 and 1 year births
// // (See Bongaarts 1999
// collapse ///
//     (sum) tfr_3yr_bo_1 = asbr_3yr_bo_1 ///
//     (sum) tfr_3yr_bo_2 = asbr_3yr_bo_2 ///
//     (sum) tfr_3yr_bo_3 = asbr_3yr_bo_3 ///
//     (sum) tfr_3yr_bo_4 = asbr_3yr_bo_4 ///
//     (sum) tfr_3yr=asbr_3yr ///
//     (sum) tfr_1yr=asbr_1yr , ///
// 	by(urban edu_group)
// 
// list
// save `data'/predicted_tfr_round_4, replace



// NFHS-3

// use v001-v012 v024 v026 ///
//    v102 v104 v105 v130-v135 v155  ///
//    bidx_01-b16_20 ///
//    v224 ///
//    using `rawdata'/iair52fl, clear
// 
// // keep if v135 == 1 // usual resident in hh
// // drop if v104 == 96 // visitor to hh
// 
// // urban-rural
// gen urban = v102 == 1
// gen rural = v102 == 2
// ren v102 urban_rural
// 
// // religion
// gen hindu = v130 == 1
// 
// ren v008 interview_cmc
// ren v012 mother_age   
// 
// ren v133 edu_mother
// drop if edu_mother > 30
// 
// ren v224 fertility
// 
// // Useful variables:
// // interview_cmc 	date of interview (cmc)
// // edu_mother 		Wife's education in years
// // urban 			Live in urban area
// // fertility		Number of children ever born
// // bX_born_cmc		Date of parity X child born (cmc)
// // mother_age		Respondent's current age at survey
// 
// // Restrict to match hazard model sample
// // keep if fertility > 0
// keep if hindu 
// keep if mother_age >= 15 & mother_age < 46
// 
// // drop women with multiple births if birth order 4 or lower
// forvalues i = 1/20 {
//     if `i' < 10 {
//         loc var = "0`i'"
//     } 
//     else {
//         loc var = "`i'"
//     }
//     drop if b0_`var' > 0 & bord_`var' < 5
// }
// 
// 
// // birth variables
// 
// // first spacing (marriage to first birth or interview)
// gen b1_born_cmc = .
// forvalues i = 1/20 {
//     if `i' < 10 {
//         loc var = "0`i'"
//     } 
//     else {
//         loc var = "`i'"
//     }
//     replace b1_born_cmc = b3_`var' if bord_`var' == 1
// }
// 
// // second and higher spacing
// forvalues bo = 2/20 {
//     loc bom1 = `bo'-1
//     gen b`bo'_born_cmc = .
//     forvalues i = 1/20 {
//         if `i' < 10 {
//             loc var = "0`i'"
//         }
//         else {
//             loc var = "`i'"
//         }
//         replace b`bo'_born_cmc = b3_`var' if bord_`var' == `bo'
//     }
// }
// 
// 
// // 5-year age groups
// egen age_group = cut(mother_age ) , at(15(5)40 46)
// 
// // Education groupings
// gen edu_group = 1 if edu_mother == 0
// replace edu_group = 2 if edu_mother >= 1 & edu_mother <= 7
// replace edu_group = 3 if edu_mother >= 8 
// 
// 
// // replace edu_group = 3 if edu_mother >= 8 & edu_mother <= 11
// // replace edu_group = 4 if edu_mother >= 12
// 
// 
// // 3-year fertility rate by age
// // The 3-year period is what is used by NFHS reports for TFR
// // Births in the month of interview are not included as in DHS
// // See "Guide to DHS Statistics 5.2 (~ p 186)
// forvalues parity = 1/4 {
//     assert interview_cmc >= b`parity'_born_cmc if b`parity'_born_cmc != .
// 	// birth of parity `parity' in 3 years before survey date
// 	gen birth_3yr_`parity' = (interview_cmc - b`parity'_born_cmc) >= 1 & ///
// 	    (interview_cmc - b`parity'_born_cmc) <= 36
// 	// birth of parity `parity' in 1 year before survey date
// 	gen birth_1yr_`parity' = (interview_cmc - b`parity'_born_cmc) >= 1 & ///
// 	    (interview_cmc - b`parity'_born_cmc) <= 12
// }
// 
// 
// gen births_3yr_1_to_4 = birth_3yr_1 + birth_3yr_2 + birth_3yr_3 + birth_3yr_4
// gen births_1yr_1_to_4 = birth_1yr_1 + birth_1yr_2 + birth_1yr_3 + birth_1yr_4
// 
// 
// // 
// collapse  (count) num_women = fertility ///
//     (sum) num_births_3yr_bo_1 = birth_3yr_1 ///
//     (sum) num_births_3yr_bo_2 = birth_3yr_2 ///
//     (sum) num_births_3yr_bo_3 = birth_3yr_3 ///
//     (sum) num_births_3yr_bo_4 = birth_3yr_4 ///
//     (sum) num_births_3yr = births_3yr_1_to_4 ///
//     (sum) num_births_1yr = births_1yr_1_to_4, ///
// 	by(urban edu_group age_group)
// 
// 
// // age-specific birth rate (Convert back to births by year for 3-year)
// forvalues bo = 1/4 {
//     gen asbr_3yr_bo_`bo' = 5 * (num_births_3yr_bo_`bo' / 3) / num_women 
// }
// gen asbr_3yr = 5 * (num_births_3yr / 3) / num_women 
// gen asbr_1yr = 5 * num_births_1yr / num_women 
// 
// 
// // Calculate "TFR" for parities 2 through 4 and 
// // combined "TFR" based on 3 and 1 year births
// // (See Bongaarts 1999
// collapse ///
//     (sum) tfr_3yr_bo_1 = asbr_3yr_bo_1 ///
//     (sum) tfr_3yr_bo_2 = asbr_3yr_bo_2 ///
//     (sum) tfr_3yr_bo_3 = asbr_3yr_bo_3 ///
//     (sum) tfr_3yr_bo_4 = asbr_3yr_bo_4 ///
//     (sum) tfr_3yr=asbr_3yr ///
//     (sum) tfr_1yr=asbr_1yr , ///
// 	by(urban edu_group)
// 
// list
// save `data'/predicted_tfr_round_3, replace




// NFHS-2
// Have to combine both the individual recode and the hh roster to get TFR
// Retherford and Vinod (2001) show displacement in children's ages, which biases
// downward the estimated TFR. Displacement occurred because interviewers could lower
// their workload by counting children as older.
// https://pdfs.semanticscholar.org/a989/b7581891c69d107cdd200328ecfd598fcc99.pdf


// All women from household recode data
// Need to match to individual recode - use respondent's line number: hvidx_XX
// hv001    : cluster number
// hv002    : household number
// hv008    : interview date (cmc)
// hv024    : state
// hvidx_XX : line number
// hv102_XX : usual resident
// hv104_XX : sex of household member
// hv105_XX : age of household member
// hv108_XX : years of education in single years


// use hhid hv001 hv002 hv008 hv024 hv025 sh39 ///
//     hvidx_* hv102_* hv103_* hv104_* hv105_* hv108_* hv117_* ///
//     using `rawdata'/iahr42fl , clear
// 
// keep if sh39 == 1 // Hindu only
// // drop sh39
// 
// // gen urban = hv025 == 1
// // gen rural = hv025 == 2
// 
// // need string to get 01, 02, 03, etc
// reshape long hvidx_ hv102_ hv103_ hv104_ hv105_ hv108_ hv117_, ///
//     i(hhid) j(hh_member) string
// 
// drop hh_member
// drop if hvidx == . // 
// keep if hv104 == 2 // females only
// keep if hv117 == 0 // Only need those not interviewed for female interview
// keep if hv105 >= 15 & hv105 < 46 // 15 to 45 years of age
// drop if hv108 == . // missing information on education
// keep if hv102 == 1 // Usual residents only
// keep if hv103 == 1 // Here last night
// 
// rename hv001 v001
// rename hv002 v002
// rename hv024 v024
// rename hvidx v003
// 
// count
// 
// save `data'/temp_nfhs_2_hh, replace
// 
// // Women's recode data
// // v001: cluster number
// // v002: household number
// // v003: respondent's line number
// // v024: state
// 
// use caseid v001-v012 v024 ///
//    v102 v104 v105 v130-v135 ///
//    bidx_01-b15_18 ///
//    v224 ///
//    using `rawdata'/iair42fl, clear
// 
// // keep if v135 == 1 // usual resident in hh
// // drop if v104 == 96 // visitor to hh
// 
// 
// // urban-rural
// gen urban = v102 == 1
// gen rural = v102 == 2
// ren v102 urban_rural
// 
// // religion
// gen hindu = v130 == 1
// 
// ren v008 interview_cmc
// ren v012 mother_age   
// 
// ren v133 edu_mother
// drop if edu_mother > 30
// 
// ren v224 fertility
// 
// // Useful variables:
// // interview_cmc 	date of interview (cmc)
// // edu_mother 		Wife's education in years
// // urban 			Live in urban area
// // fertility		Number of children ever born
// // bX_born_cmc		Date of parity X child born (cmc)
// // mother_age		Respondent's current age at survey
// 
// // Restrict to match hazard model sample
// // keep if fertility > 0
// keep if hindu 
// keep if mother_age >= 15 & mother_age < 46
// 
// 
// // Merge data
// merge 1:1 v024 v001 v002 v003 using `data'/temp_nfhs_2_hh
// 
// replace edu_mother    = hv108_ if edu_mother == .
// replace mother_age    = hv105 if mother_age == .
// replace interview_cmc = hv008 if interview_cmc == .
// replace urban         = hv025 == 1 if urban == .
// 
// 
// // // drop women with multiple births if birth order 4 or lower
// // forvalues i = 1/18 {
// //     if `i' < 10 {
// //         loc var = "0`i'"
// //     } 
// //     else {
// //         loc var = "`i'"
// //     }
// //     drop if b0_`var' > 0 & bord_`var' < 5 & b0_`var' != .
// // }
// 
// 
// // birth variables
// 
// // first spacing (marriage to first birth or interview)
// gen b1_born_cmc = .
// forvalues i = 1/18 {
//     if `i' < 10 {
//         loc var = "0`i'"
//     } 
//     else {
//         loc var = "`i'"
//     }
//     replace b1_born_cmc = b3_`var' if bord_`var' == 1
// }
// 
// // second and higher spacing
// forvalues bo = 2/18 {
//     loc bom1 = `bo'-1
//     gen b`bo'_born_cmc = .
//     forvalues i = 1/18 {
//         if `i' < 10 {
//             loc var = "0`i'"
//         }
//         else {
//             loc var = "`i'"
//         }
//         replace b`bo'_born_cmc = b3_`var' if bord_`var' == `bo'
//     }
// }
// 
// 
// // 5-year age groups
// egen age_group = cut(mother_age ) , at(15(5)40 46)
// 
// // Education groupings
// gen edu_group = 1 if edu_mother == 0
// replace edu_group = 2 if edu_mother >= 1 & edu_mother <= 7
// replace edu_group = 3 if edu_mother >= 8 
// 
// 
// // replace edu_group = 3 if edu_mother >= 8 & edu_mother <= 11
// // replace edu_group = 4 if edu_mother >= 12
// 
// 
// // 3-year fertility rate by age
// // The 3-year period is what is used by NFHS reports for TFR
// // Births in the month of interview are not included as in DHS
// // See "Guide to DHS Statistics 5.2 (~ p 186)
// forvalues parity = 1/4 {
//     assert interview_cmc >= b`parity'_born_cmc if b`parity'_born_cmc != .
// 	// birth of parity `parity' in 3 years before survey date
// 	gen birth_3yr_`parity' = (interview_cmc - b`parity'_born_cmc) >= 1 & ///
// 	    (interview_cmc - b`parity'_born_cmc) <= 36
// 	// birth of parity `parity' in 1 year before survey date
// 	gen birth_1yr_`parity' = (interview_cmc - b`parity'_born_cmc) >= 1 & ///
// 	    (interview_cmc - b`parity'_born_cmc) <= 12
// }
// 
// 
// gen births_3yr_1_to_4 = birth_3yr_1 + birth_3yr_2 + birth_3yr_3 + birth_3yr_4
// gen births_1yr_1_to_4 = birth_1yr_1 + birth_1yr_2 + birth_1yr_3 + birth_1yr_4
// 
// 
// // 
// collapse  (count) num_women = interview_cmc ///
//     (sum) num_births_3yr_bo_1 = birth_3yr_1 ///
//     (sum) num_births_3yr_bo_2 = birth_3yr_2 ///
//     (sum) num_births_3yr_bo_3 = birth_3yr_3 ///
//     (sum) num_births_3yr_bo_4 = birth_3yr_4 ///
//     (sum) num_births_3yr = births_3yr_1_to_4 ///
//     (sum) num_births_1yr = births_1yr_1_to_4, ///
// 	by(urban edu_group age_group)
// 
// 
// // age-specific birth rate (Convert back to births by year for 3-year)
// forvalues bo = 1/4 {
//     gen asbr_3yr_bo_`bo' = 5 * (num_births_3yr_bo_`bo' / 3) / num_women 
// }
// gen asbr_3yr = 5 * (num_births_3yr / 3) / num_women 
// gen asbr_1yr = 5 * num_births_1yr / num_women 
// 
// 
// // Calculate "TFR" for parities 2 through 4 and 
// // combined "TFR" based on 3 and 1 year births
// // (See Bongaarts 1999
// collapse ///
//     (sum) tfr_3yr_bo_1 = asbr_3yr_bo_1 ///
//     (sum) tfr_3yr_bo_2 = asbr_3yr_bo_2 ///
//     (sum) tfr_3yr_bo_3 = asbr_3yr_bo_3 ///
//     (sum) tfr_3yr_bo_4 = asbr_3yr_bo_4 ///
//     (sum) tfr_3yr=asbr_3yr ///
//     (sum) tfr_1yr=asbr_1yr , ///
// 	by(urban edu_group)
// 
// list
// save `data'/predicted_tfr_round_2, replace


// NFHS-1
// Have to combine both the individual recode and the hh roster to get TFR
// Retherford and Vinod (2001) show displacement in children's ages, which biases
// downward the estimated TFR. Displacement occurred because interviewers could lower
// their workload by counting children as older.
// https://pdfs.semanticscholar.org/a989/b7581891c69d107cdd200328ecfd598fcc99.pdf

// No religion information in NFHS-1 HH recode so use raw
use  `rawdata'/iahh21fl
gen hv001   = hhstate * 1000 + hhpsu
gen hv002   = hhnumber
sort hv001 hv002

rename h032 religion_head 

keep hv001 hv002 religion_head
duplicates drop
save `data'/temp_religion, replace


// All women from household recode data
// Need to match to individual recode - use respondent's line number: hvidx_XX
// hv001    : cluster number
// hv002    : household number
// hv008    : interview date (cmc)
// hv024    : state
// hvidx_XX : line number
// hv102_XX : usual resident
// hv104_XX : sex of household member
// hv105_XX : age of household member
// hv108_XX : years of education in single years


use hhid hv001 hv002 hv008 hv024 hv025 ///
    hvidx_* hv102_* hv103_* hv104_* hv105_* hv108_* hv117_* ///
    using `rawdata'/iahr23fl , clear

merge 1:1 hv001 hv002 using `data'/temp_religion
keep if _merge == 3
drop _merge

keep if religion_head == 1 // Hindu only
// drop sh39

// gen urban = hv025 == 1
// gen rural = hv025 == 2

// need string to get 01, 02, 03, etc
reshape long hvidx_ hv102_ hv103_ hv104_ hv105_ hv108_ hv117_, ///
    i(hhid) j(hh_member) string

drop hh_member
drop if hvidx == . // 
keep if hv104 == 2 // females only
keep if hv117 == 0 // Only need those not interviewed for female interview
keep if hv105 >= 15 & hv105 < 46 // 15 to 45 years of age
drop if hv108 == . // missing information on education
keep if hv102 == 1 // Usual residents only
keep if hv103 == 1 // Here last night

rename hv001 v001
rename hv002 v002
rename hv024 v024
rename hvidx v003

count

save `data'/temp_nfhs_1_hh, replace

// Women's recode data
// v001: cluster number
// v002: household number
// v003: respondent's line number
// v024: state

use caseid v001-v012 v024 ///
   v102 v104 v105 v130-v135 ///
   bidx_01-b13_20 ///
   v224 ///
   using `rawdata'/iair23fl, clear

// keep if v135 == 1 // usual resident in hh
// drop if v104 == 96 // visitor to hh


// urban-rural
gen urban = v102 == 1
gen rural = v102 == 2
ren v102 urban_rural

// religion
gen hindu = v130 == 0 // Different from the other rounds, where it is one

ren v008 interview_cmc
ren v012 mother_age   

ren v133 edu_mother
drop if edu_mother > 30

ren v224 fertility

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


// Merge data
merge 1:1 v024 v001 v002 v003 using `data'/temp_nfhs_2_hh

replace edu_mother    = hv108_ if edu_mother == .
replace mother_age    = hv105 if mother_age == .
replace interview_cmc = hv008 if interview_cmc == .
replace urban         = hv025 == 1 if urban == .


// // drop women with multiple births if birth order 4 or lower
// forvalues i = 1/18 {
//     if `i' < 10 {
//         loc var = "0`i'"
//     } 
//     else {
//         loc var = "`i'"
//     }
//     drop if b0_`var' > 0 & bord_`var' < 5 & b0_`var' != .
// }


// birth variables

// first spacing (marriage to first birth or interview)
gen b1_born_cmc = .
forvalues i = 1/18 {
    if `i' < 10 {
        loc var = "0`i'"
    } 
    else {
        loc var = "`i'"
    }
    replace b1_born_cmc = b3_`var' if bord_`var' == 1
}

// second and higher spacing
forvalues bo = 2/18 {
    loc bom1 = `bo'-1
    gen b`bo'_born_cmc = .
    forvalues i = 1/18 {
        if `i' < 10 {
            loc var = "0`i'"
        }
        else {
            loc var = "`i'"
        }
        replace b`bo'_born_cmc = b3_`var' if bord_`var' == `bo'
    }
}


// 5-year age groups
egen age_group = cut(mother_age ) , at(15(5)40 46)

// Education groupings
gen edu_group = 1 if edu_mother == 0
replace edu_group = 2 if edu_mother >= 1 & edu_mother <= 7
replace edu_group = 3 if edu_mother >= 8 


// replace edu_group = 3 if edu_mother >= 8 & edu_mother <= 11
// replace edu_group = 4 if edu_mother >= 12


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
collapse  (count) num_women = interview_cmc ///
    (sum) num_births_3yr_bo_1 = birth_3yr_1 ///
    (sum) num_births_3yr_bo_2 = birth_3yr_2 ///
    (sum) num_births_3yr_bo_3 = birth_3yr_3 ///
    (sum) num_births_3yr_bo_4 = birth_3yr_4 ///
    (sum) num_births_3yr = births_3yr_1_to_4 ///
    (sum) num_births_1yr = births_1yr_1_to_4, ///
	by(urban edu_group age_group)


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
	by(urban edu_group)

list
save `data'/predicted_tfr_round_1, replace


