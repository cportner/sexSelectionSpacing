// Predictions based on sample
// Probability of boy, duration, and parity progression


clear all
version 15.1
set more off

file close _all // easier, in case something went wrong with last file write (Stata does not close files gracefully)
capture program drop _all


// Generic set of locations
include directories

program predict_fertility
    args spell period educ
    
    include directories
    
    // Load results
    estimates use `data'/fertility_results_spell`spell'_g`period'_`educ'
 
    capture drop dur* np* t months mid_months
    capture drop p0 p1 p2 pcbg s pps prob_kid prob_any_birth ratio_sons num_sons pct_sons

    // Duration variables
    expand $lastm
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
        forvalues per = 1/14 {
            gen dur`i' = t == `per'
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

keep if fertility >= 1

// dropping those with too much recall error
drop if observation_age_m >= 22 & round == 1
drop if observation_age_m >= 22 & round == 2
drop if observation_age_m >= 22 & round == 3
drop if observation_age_m >= 22 & round == 4


replace scheduled_caste = 1 if scheduled_tribe


loc spell = 2
loc period = 4
loc educ = "high"



// Predictions

gen id = _n
keep if edu_mother >= 8
keep if round == 4

// 2nd spell
// Girl variable, id, and mom_age (code from genSpellX.do)
gen girl1 = b1_sex == 2 if b1_sex != .
gen girl1Xurban = girl1 * urban
gen mom_age    = b2_mom_age
        
predict_fertility 2 4 `educ'
gen prob_2nd_birth = prob_any_birth 
gen prob_2nd_son   = pct_sons / 100

// 3rd spell if 2nd child boy
drop girl* mom_age
gen girl1 = (b1_sex == 2) ///
    if b1_sex != . // Since 2nd child assumed boy whether 1 girl depends on first birth
gen girl2 = 0 ///
    if b1_sex != . // Since 2nd child assumed boy cannot have two girls
gen girl1Xurban = girl1 * urban
gen girl2Xurban = girl2 * urban
gen mom_age = b2_mom_age + 2 

predict_fertility 3 4 `educ'
gen prob_3rd_birth_prior_b = prob_any_birth
gen prob_3rd_son_prior_b   = pct_sons / 100

// 3rd spell if 2nd child girl
drop girl* mom_age
gen girl1 = (b1_sex == 1) ///
    if b1_sex != . // Since 2nd child assumed girl 1 girl can only happen if first child a boy
gen girl2 = (b1_sex == 2) ///
    if b1_sex != . // Since 2nd child assumed girl will have two girls if first a girl
gen girl1Xurban = girl1 * urban
gen girl2Xurban = girl2 * urban
gen mom_age = b2_mom_age + 2 

predict_fertility 3 4 `educ'
gen prob_3rd_birth_prior_g = prob_any_birth
gen prob_3rd_son_prior_g   = pct_sons / 100




