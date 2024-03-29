* Create base data set for NFHS - combine all surveys

// Revisions
* 25/02/09 No longer deleting old obs (20 yrs +), but marking them
* 06/03/09 Fix interview year to 19XX and 20XX and gen round variables
* 08/11/09 Vars for age at marriage + birth and drop inconsistent vars
*          Fix beginning point for first spell - now at 11 years old
* 06/02/10 Create new residence variables now city, town, rural
* 07/03/10 Corrected wrong definition for town (doh!)
* 2015-03-16 - dropping women divorced or not living together with husband
* 2015-03-17 - dropped bad observation. Those normally dropped from analysis files anyway

clear all
version 13.1
set more off

// Generic set of locations
include directories

/*-------------------------------------------------------------------*/
/* APPENDING DATA SETS                                               */
/*-------------------------------------------------------------------*/

use `data'/base2 // better - more labels
append using `data'/base1
append using `data'/base3
append using `data'/base4

des , short

// labels
label val state state // no idea why this is needed
label val b0_19 B0
label val b0_20 B0
label val b4_19 B4
label val b4_20 B4
label val b5_19 B5
label val b5_20 B5

/*--------------------------------------------------------------------*/
/* DROPPING PROBLEMATIC VARIABLES/OBSERVATIONS                        */
/*--------------------------------------------------------------------*/

// drop women with multiple births if birth order 4 or lower
forvalues i = 1/20 {
    if `i' < 10 {
        loc var = "0`i'"
    } 
    else {
        loc var = "`i'"
    }
    drop if b0_`var' > 0 & bord_`var' < 5
}

// drop women with sterilisation before marriage
drop if sterilisation <= marriage_cmc

// drop if negative interval between marriage and first birth
// drop if space_0_1 == 996

// drop if marital status is not currently married or widowed (divorced or not living together)
drop if marital_status == 4 | marital_status == 5

/*--------------------------------------------------------------------*/
/* IDENTIFYING OLD OBSERVATIONS                                       */
/*--------------------------------------------------------------------*/

// Calculate how long ago first recorded birth and how long since married
gen observation_age   = int((interview_cmc - first_cmc) / 12)
gen observation_age_m = int((interview_cmc - marriage_cmc) / 12)

/*-------------------------------------------------------------------*/
/* FIX INTERVIEW YEAR AND SURVEY ROUNDS 		             */
/*-------------------------------------------------------------------*/

replace interview_year = interview_year + 100 if interview_year == 0
replace interview_year = interview_year + 1900 if interview_year < 2000

gen round  = 1 if interview_year == 1992 | interview_year == 1993
replace round = 2 if interview_year == 1998 | interview_year == 1999 | interview_year == 2000
replace round = 3 if interview_year == 2005 | interview_year == 2006
replace round = 4 if interview_year == 2015 | interview_year == 2016

/*--------------------------------------------------------------------*/
/* CREATING BIRTH AND SPACING VARIABLES                               */
/*--------------------------------------------------------------------*/

gen mom_id = _n // assign id

// first spacing (marriage to first birth or interview)
// Relevant space is not from marriage but from menarche
// but not available so use age 12
gen b1_mom_age = int((marriage_cmc-mother_cmc)/12) // age at marriage
label var b1_mom_age "Mother's age at marriage"
gen b1_cen = fertility == 0
gen b1_space = space_0_1
gen b1_sex = .
gen b1_dead_cmc = .
gen b1_born_cmc = .
forvalues i = 1/20 {
    if `i' < 10 {
        loc var = "0`i'"
    } 
    else {
        loc var = "`i'"
    }
    replace b1_sex = b4_`var' if bord_`var' == 1
    replace b1_dead_cmc = b3_`var' + b7_`var' if bord_`var' == 1 & b7_`var' != .
    replace b1_born_cmc = b3_`var' if bord_`var' == 1
}
gen start_cmc = marriage_cmc
replace start_cmc = mother_cmc + 12*12 if b1_mom_age < 12 // start at age 12
replace b1_space = b1_born_cmc - start_cmc if b1_mom_age < 12
replace b1_space = interview_cmc - start_cmc if fertility == 0
replace b1_space = sterilisation - start_cmc if fertility == 0 & sterilisation != .
replace b1_mom_age = 12 if b1_mom_age < 12

// second and higher spacing
forvalues bo = 2/20 {
    loc bom1 = `bo'-1
    gen b`bo'_cen = fertility == `bo'-1
    replace b`bo'_cen = . if fertility < `bom1'
    gen b`bo'_space = space_last_int if b`bo'_cen == 1 // censored
    replace b`bo'_space = sterilisation - b`bom1'_born_cmc if b`bo'_cen == 1 & sterilisation != .
    drop if b`bo'_space < 0  & b`bo'_cen == 1  & sterilisation != . // sterilization occurred before birth
    gen b`bo'_sex = .
    gen b`bo'_dead_cmc = .
    gen b`bo'_born_cmc = .
    gen b`bo'_mom_age = .
    forvalues i = 1/20 {
        if `i' < 10 {
            loc var = "0`i'"
        }
        else {
            loc var = "`i'"
        }
        replace b`bo'_space = b11_`var' if bord_`var' == `bo'
        replace b`bo'_sex = b4_`var' if bord_`var' == `bo'
        replace b`bo'_dead_cmc = b3_`var' + b7_`var' if bord_`var' == `bo' & b7_`var' != .
        replace b`bo'_born_cmc = b3_`var' if bord_`var' == `bo'
        replace b`bo'_mom_age = int((b`bom1'_born_cmc-mother_cmc)/12) // age at previous birth
        
    }
    label var b`bo'_mom_age "Mother's age at birth of child `bom1'"
}

// drop if negative spacing - cannot just drop less than 9 because of censoring
forvalues i = 2/4 {
    drop if b`i'_space < 9 & b`i'_cen == 0
}

// drop if age inconsistencies by birth
drop if b2_mom_age < b1_mom_age
drop if b3_mom_age < b2_mom_age
drop if b4_mom_age < b3_mom_age

// surviving children
// could subtract 9 from bX_born_cmc to allow for pregnancy

// forvalues dur = 2/11 {
// dis "Duration number `dur'"
//     loc durm1 = `dur'-1
//     // first child
//        gen b`dur'_boys  = b1_sex == 1 & b1_dead_cmc == . if fertility >= `dur'-1
//        gen b`dur'_girls = b1_sex == 2 & b1_dead_cmc == . if fertility >= `dur'-1
//        replace b`dur'_boys  = b1_sex == 1 & b1_dead_cmc > b`dur'_born_cmc if b`dur'_sex != .
//        replace b`dur'_girls = b1_sex == 2 & b1_dead_cmc > b`dur'_born_cmc if b`dur'_sex != .
//     // second child and above
//     forvalues i = 2/`durm1' {
// dis "Duration number `dur' - child number `i'"
//         replace b`dur'_boys  = b`dur'_boys  + 1 if (b`i'_sex == 1 & b`i'_dead_cmc == .) ///
//             | (b`i'_sex == 1 & b`i'_dead_cmc > b`dur'_born_cmc & b`dur'_sex != .) 
//         replace b`dur'_girls = b`dur'_girls + 1 if (b`i'_sex == 2 & b`i'_dead_cmc == .) ///
//             | (b`i'_sex == 2 & b`i'_dead_cmc > b`dur'_born_cmc & b`dur'_sex != .)
//     }
// }


/*--------------------------------------------------------------------*/
/* GENERATING VARIABLES AND ADDING LABELS                             */
/*--------------------------------------------------------------------*/

gen edu_mother2 = edu_mother^2 / 10
gen edu_father2 = edu_father^2 / 10
gen city = resid_large
gen town = resid_small + resid_town

egen region1 = anymatch(state), values(7 19 6 30 13 8 5 9 20) // High sex selection
egen region2 = anymatch(state), values(24 4 12) // High fertility, high son preference
egen region3 = anymatch(state), values(3 18 23 34 15 23 16 14 17 35 21) // Moderate son preference
egen region4 = anymatch(state), values(11 10 22 2) // Low son preference
assert region1 + region2 + region3 + region4 == 1
gen region = .
forvalues r = 1/4 {
    replace region = `r' if region`r' == 1
}
assert region == 1 | region == 2 | region == 3 | region == 4

lab var edu_mother   "Wife's education"
lab var edu_mother2  "Wife's education$^2$/10"
lab var edu_father   "Husband's education"
lab var edu_father2  "Husband's education$^2$/10"
lab var land_own     "Owns agricultural land"
lab var resid_large  "Large city"
lab var resid_small  "Small city"
lab var resid_town   "Town"
lab var resid_country "Rural area"
lab var hindu        "Hindu"
lab var sikh         "Sikh"
lab var muslim       "Muslim"
lab var scheduled_caste "Scheduled caste"
lab var scheduled_tribe "Scheduled tribe"
lab var city         "City"
lab var town         "Town"
lab var rural        "Rural"

/*--------------------------------------------------------------------*/
/* DROP BAD OBSERVATIONS                                              */
/*--------------------------------------------------------------------*/

drop if b1_mom_age < 12 
drop if b2_mom_age < 12 | b3_mom_age < 14 | b4_mom_age < 15
drop if edu_mother == .
// drop if edu_father == . | edu_father > 30 // not needed since father's edu not used
count

/*--------------------------------------------------------------------*/
/* SAVE BASE FILE                                                     */
/*--------------------------------------------------------------------*/

keep if hindu
compress
save `data'/base, replace

