
version 15.1
clear all
set more off
file close _all

include directories


/*-------------------------------------------------------------------*/
/* LOADING DATA AND CREATING NEW VARIABLES                           */
/*-------------------------------------------------------------------*/

use `data'/base

keep if hindu 
drop if observation_age_m >= 22 & round == 1
drop if observation_age_m >= 22 & round == 2
drop if observation_age_m >= 22 & round == 3
drop if observation_age_m >= 22 & round == 4

lab var land_own "Owns land"

gen b0_born_year = int((marriage_cmc-1)/12)
gen b1_born_year = int((b1_born_cmc-1)/12) if fertility >= 1
gen b2_born_year = int((b2_born_cmc-1)/12) if fertility >= 2
gen b3_born_year = int((b3_born_cmc-1)/12) if fertility >= 3


gen edu_group = 1 if edu_mother == 0
replace edu_group = 2 if edu_mother >= 1 & edu_mother <= 7
replace edu_group = 3 if edu_mother >= 8 & edu_mother <= 11
replace edu_group = 4 if edu_mother >= 12

replace scheduled_caste = 1 if scheduled_tribe


//------------------------------//
// Sterilization decision       //
//------------------------------//

// * SPELL 2
// 
// preserve
// keep if fertility >= 1
// create_groups b1_born_year
// 
// gen mom_age    = b2_mom_age
// 
// gen girl1 = b1_sex == 2 if b1_sex != .
// gen girl1Xurban = girl1 * urban
// 
// // Sterilization and censoring
// gen cen_sterilisation = b1_born_cmc + b2_space == sterilisation & ///
//     sterilisation != . & b2_space <= 105 & fertility == 1
//     
// sum cen_sterilisation    
// table edu_group group urban , cont(mean cen_sterilisation) 
// 
// // bysort edu_group group: tab b2_space if cen_sterilisation
// 
// gen sterile = cen_sterilisation & b2_space < 9
// 
// bysort edu_group group : logit sterile girl1 girl1Xurban urban mom_age scheduled_caste land_own
// restore
// 
// exit


// * SPELL 3
// 
// preserve
// keep if fertility >= 2
// create_groups b2_born_year
// 
// gen mom_age    = b3_mom_age
// 
// gen girl1 = (b1_sex == 2 | b2_sex == 2) & !(b1_sex == 2 & b2_sex == 2) ///
//     if b1_sex != . & b2_sex != . 
// gen girl2 = (b1_sex == 2 & b2_sex == 2) ///
//     if b1_sex != . & b2_sex != . 
// 
// gen girl1Xurban = girl1 * urban
// gen girl2Xurban = girl2 * urban
// 
// // Sterilization and censoring
// gen cen_sterilisation = b2_born_cmc + b3_space == sterilisation & ///
//     sterilisation != . & b3_space <= 105 & fertility == 2
//     
// sum cen_sterilisation    
// table edu_group group urban , cont(mean cen_sterilisation) 
// 
// // bysort edu_group group: tab b2_space if cen_sterilisation
// 
// gen sterile = cen_sterilisation & b3_space < 9
// 
// bysort edu_group group : logit sterile girl1 girl2 girl1Xurban girl2Xurban ///
//     urban mom_age scheduled_caste land_own
// restore



// * SPELL 4
// 
// keep if fertility >= 3
// create_groups b3_born_year
// 
// gen mom_age    = b4_mom_age
// 
// egen numgirls = anycount(b1_sex b2_sex b3_sex), v(2)
// gen girl1 = numgirls == 1 if b1_sex != . & b2_sex != . & b3_sex != .
// gen girl2 = numgirls == 2 if b1_sex != . & b2_sex != . & b3_sex != .
// gen girl3 = numgirls == 3 if b1_sex != . & b2_sex != . & b3_sex != .
// 
// gen girl1Xurban = girl1 * urban
// gen girl2Xurban = girl2 * urban
// gen girl3Xurban = girl3 * urban
// 
// // Sterilization and censoring
// gen cen_sterilisation = b3_born_cmc + b4_space == sterilisation & ///
//     sterilisation != . & b4_space <= 105 & fertility == 3
//     
// sum cen_sterilisation    
// table edu_group group urban , cont(mean cen_sterilisation) 
// 
// // bysort edu_group group: tab b2_space if cen_sterilisation
// 
// gen sterile = cen_sterilisation & b4_space < 9
// 
// bysort edu_group group : logit sterile girl1 girl2 girl3 girl1Xurban girl2Xurban girl3Xurban ///
//     urban mom_age scheduled_caste land_own
// 


// Loop version across spells

forvalues spell = 3/4 {

    preserve
    loc spell_m1 = `spell' - 1
    keep if fertility >= `spell_m1'
    create_groups b`spell_m1'_born_year

    gen mom_age    = b`spell'_mom_age

    // prior sex composition
    if `spell' == 2 {
        gen girl1 = b1_sex == 2 if b1_sex != .
        gen girl1Xurban = girl1 * urban
        loc girls " girl1 girl1Xurban "
    }
    else if `spell' == 3 {
        gen girl1 = (b1_sex == 2 | b2_sex == 2) & !(b1_sex == 2 & b2_sex == 2) ///
            if b1_sex != . & b2_sex != . 
        gen girl2 = (b1_sex == 2 & b2_sex == 2) ///
            if b1_sex != . & b2_sex != . 

        gen girl1Xurban = girl1 * urban
        gen girl2Xurban = girl2 * urban
        loc girls " girl1 girl2 girl1Xurban girl2Xurban "
    
    }
    else if `spell' == 4 {
        egen numgirls = anycount(b1_sex b2_sex b3_sex), v(2)
        gen girl1 = numgirls == 1 if b1_sex != . & b2_sex != . & b3_sex != .
        gen girl2 = numgirls == 2 if b1_sex != . & b2_sex != . & b3_sex != .
        gen girl3 = numgirls == 3 if b1_sex != . & b2_sex != . & b3_sex != .

        gen girl1Xurban = girl1 * urban
        gen girl2Xurban = girl2 * urban
        gen girl3Xurban = girl3 * urban
        loc girls " girl1 girl2 girl3 girl1Xurban girl2Xurban girl3Xurban "
    }

    // Sterilization and censoring
    gen cen_sterilisation = b`spell_m1'_born_cmc + b`spell'_space == sterilisation & ///
        sterilisation != . & b`spell'_space <= 105 & fertility == `spell_m1'

    gen sterile = cen_sterilisation & b`spell'_space < 9

    foreach educ in "highest" "high" "med" "low" {
        if "`educ'" == "low" {
            loc ed_group 1
        }
        else if "`educ'" == "med" {
            loc ed_group 2
        }
        else if "`educ'" == "high" {
            loc ed_group 3
        }
        else if "`educ'" == "highest" {
            loc ed_group 4
        }

        forvalues group = 1/4 {
    
            // Estimation results for highest education group in the 1972-84 period unreliable
            // because of too small sample size
//             if "`educ'" == "highest" & `group' == 1 {
//                 continue
//             }

            logit sterile `girls' ///
                urban mom_age scheduled_caste land_own if edu_group == `ed_group' & group == `group'
            
            estimates save `data'/sterilization_results_spell`spell'_g`group'_`educ', replace
        }
    }
    restore
}


