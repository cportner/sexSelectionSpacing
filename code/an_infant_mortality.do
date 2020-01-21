// Infant mortality and birth spacing

clear all
version 15.1
set more off

file close _all // easier, in case something went wrong with last file write (Stata does not close files gracefully)
capture program drop _all

include directories

program predict_fertility
    args spell period educ
    
    include directories
    
    // Load results
    estimates use `data'/fertility_results_spell`spell'_g`period'_`educ'
    loc lastm = `e(estimates_note2)'
 
    capture drop dur* np* t months mid_months
    capture drop p0 p1 p2 pcbg s pps prob_kid prob_any_birth ratio_sons num_sons pct_sons

    // Duration variables
    expand `lastm'
    bysort id: gen t = _n
    gen months = t * 3
    gen mid_months = (t-1)*3 + 1.5

    // PIECE-WISE LINEAR HAZARDS
    if `spell' == 1 | `spell' == 2  {
        loc i = 1
        forvalues per = 1/19 {
            gen dur`i' = t == `per'
            loc ++i
        }
        gen dur`i' = t >= 20 & t <= 24
        loc ++i
        gen dur`i' = t >= 25
    }
    else if `spell' == 3 {
        loc i = 1
        forvalues per = 1(2)14 {
            gen dur`i' = t >= `per' & t <= `per' + 1    
            loc ++i
        }
        gen dur`i' = t >= 15 & t <= 19
        loc ++i
        gen dur`i' = t >= 20 
    }
    else if `spell' == 4 {
        loc i = 1
        gen dur`i' = t >= 1 & t <= 5
        loc ++i
        gen dur`i' = t >= 6 & t <= 10
        loc ++i
        gen dur`i' = t >= 11
    }
    
    // [THIS PART DEPENDS ON SPELL!]        
    loc npvar = "urban "
    loc spell_m1 = `spell'-1
    forvalues j = 1/`spell_m1' {
        loc npvar = "`npvar' girl`j' girl`j'Xurban "
    }
    // NON-PROPORTIONALITY
    foreach var of var `npvar' {
        forval x = 1/`i' {
            gen np`x'X`var'  = dur`x' * `var' 
        }
    }

    // Predictions 
    predict double p0, pr outcome(0) // no child
    predict double p1, pr outcome(1) // boy
    predict double p2, pr outcome(2) // girl
    
    // percentage 
    capture predictnl double pcbg = predict(outcome(1))/(predict(outcome(1)) + predict(outcome(2))) if p2 > 0.0000001

    // survival curves
    bysort id (t): gen double s = exp(sum(ln(p0)))
    
    // survival curves conditional on parity progression
    bysort id (t): gen double pps = (s - s[_N]) / (1.00 - s[_N])    

    // probability of kid
    gen double     prob_kid = 1 - s if t == 1
    replace prob_kid = s[_n-1] - s[_n] if t != 1
    bysort id (t): gen double prob_any_birth = 1 - s[_N] // probability of having a birth by end of spell

    // Sons born
    gen double ratio_sons = pcbg * prob_kid
    bysort id (t): egen double num_sons = total(ratio_sons)
    bysort id (t): gen double pct_sons = (num_sons / (1 - s[_N])) * 100
    
    // Only need the final values 
    bysort id (t): keep if _n == _N    

end

use `data'/base, clear
drop bidx_01-b12_18 bidx_19-b12_20

// dropping those with too much recall error
drop if observation_age_m >= 22 & round == 1
drop if observation_age_m >= 22 & round == 2
drop if observation_age_m >= 22 & round == 3
drop if observation_age_m >= 22 & round == 4

// Base data already has most of the information
// b2_space 1st -> 2nd birth
// b2_sex 2nd child sex
// b2_dead_cmc CMC dated month of death
// b2_born_cmc CMC birth month

// Create variables to match hazard models
gen id = _n
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

egen b2_d_space = cut(b2_space), at(0 15 27 39 51 63 75 100)


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

gen mom_age = b2_mom_age
gen girl1 = b2_girl
gen girl1Xurban = girl1 * urban
predict_fertility 2 4 highest

reg b2_died_as_infant b1_girl b1_mom_age scheduled_caste land_own urban ///
    c.pct_sons##i.b2_girl##i.b2_d_space 
margins b2_d_space#b2_girl , at(pct_sons == (51.2 58)
marginsplot, x(b2_d_space)
