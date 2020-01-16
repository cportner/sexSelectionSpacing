// Predictions based on hazard model results
// Probability of boy and parity progression
// Depends on an_fertility_hazard.do


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
    capture estimates use `data'/fertility_results_spell`spell'_g`period'_`educ'
    if _rc != 0 {
        // Exit if estimation results missing
        dis "Estimation results for spell `spell', period `period', and `educ' do not exist"
        exit
    }
 
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

// dropping those with too much recall error
drop if observation_age_m >= 22 & round == 1
drop if observation_age_m >= 22 & round == 2
drop if observation_age_m >= 22 & round == 3
drop if observation_age_m >= 22 & round == 4

gen id = _n

replace scheduled_caste = 1 if scheduled_tribe

// Predictions
// Girl variable, id, and mom_age (code from genSpellX.do)

// loc round = 4  // Survey round used for predictions
// loc period = 4 // Fourth set of estimation results, not necessarily the same as survey round

// Mom age increases
loc mom_age_2 = 3
loc mom_age_3 = 6
loc mom_age_4 = 9


forvalues period = 1/4 {
    loc round = `period'
    foreach educ in "highest" "high" "med" "low" {
    
        # Estimation results for highest education group in the 1972-84 period unreliable
        # because of too small sample size
        if "`educ'" == "highest" & `period' == 1 {
            continue
        }

        preserve

        keep if round == `round'
    
        // keep only those in education group
        if "`educ'" == "low" {
            keep if edu_mother == 0
        }
        else if "`educ'" == "med" {
            keep if edu_mother >= 1 & edu_mother < 8
        }
        else if "`educ'" == "high" {
            keep if edu_mother >= 8 & edu_mother <= 11
        }
        else if "`educ'" == "highest" {
            keep if edu_mother >= 12
        }
        else {
            dis "Something went wrong with education level"
            exit
        }

        // 1st spell 
        gen mom_age = b1_mom_age

        dis "1st spell in period `period' for `educ'"
        predict_fertility 1 `period' `educ'
        gen prob_1st_birth = prob_any_birth
        gen prob_1st_son   = pct_sons / 100


        // 2nd spell if 1st child boy
        drop mom_age
        gen girl1 = 0
        gen girl1Xurban = girl1 * urban
        gen mom_age    = b1_mom_age + `mom_age_2'

        dis "2nd spell in period `period' for `educ' with 1 boy"        
        predict_fertility 2 `period' `educ'
        gen prob_2nd_birth_b = prob_any_birth 
        gen prob_2nd_son_b   = pct_sons / 100

        // 2nd spell if 1st child girl
        drop girl* mom_age
        gen girl1 = 1
        gen girl1Xurban = girl1 * urban
        gen mom_age    = b1_mom_age + `mom_age_2'

        dis "2nd spell in period `period' for `educ' with 1 girl"                
        predict_fertility 2 `period' `educ'
        gen prob_2nd_birth_g = prob_any_birth 
        gen prob_2nd_son_g   = pct_sons / 100


        // 3rd spell if two boys
        drop girl* mom_age
        gen girl1 = 0
        gen girl2 = 0 
        gen girl1Xurban = girl1 * urban
        gen girl2Xurban = girl2 * urban
        gen mom_age = b1_mom_age + `mom_age_3'

        dis "3rd spell in period `period' for `educ' with 2 boys"        
        predict_fertility 3 `period' `educ'
        gen prob_3rd_birth_bb = prob_any_birth
        gen prob_3rd_son_bb   = pct_sons / 100

        // 3rd spell if 1 boy / 1 girl
        drop girl* mom_age
        gen girl1 = 1
        gen girl2 = 0
        gen girl1Xurban = girl1 * urban
        gen girl2Xurban = girl2 * urban
        gen mom_age = b1_mom_age + `mom_age_3'

        dis "3rd spell in period `period' for `educ' with 1 boy / 1 girl"
        predict_fertility 3 `period' `educ'
        gen prob_3rd_birth_bg = prob_any_birth
        gen prob_3rd_son_bg   = pct_sons / 100

        // 3rd spell if 2 girls
        drop girl* mom_age
        gen girl1 = 0
        gen girl2 = 1
        gen girl1Xurban = girl1 * urban
        gen girl2Xurban = girl2 * urban
        gen mom_age = b1_mom_age + `mom_age_3'

        dis "3rd spell in period `period' for `educ' with 2 girls"        
        predict_fertility 3 `period' `educ'
        gen prob_3rd_birth_gg = prob_any_birth
        gen prob_3rd_son_gg   = pct_sons / 100


        // 4th spell if three boys
        drop girl* mom_age
        gen girl1 = 0
        gen girl2 = 0 
        gen girl3 = 0
        gen girl1Xurban = girl1 * urban
        gen girl2Xurban = girl2 * urban
        gen girl3Xurban = girl3 * urban
        gen mom_age = b1_mom_age + `mom_age_4'

        dis "4th spell in period `period' for `educ' with 3 boys"
        predict_fertility 4 `period' `educ'
        gen prob_4th_birth_bbb = prob_any_birth
        gen prob_4th_son_bbb   = pct_sons / 100

        // 4th spell if two boys / 1 girl
        drop girl* mom_age
        gen girl1 = 1
        gen girl2 = 0 
        gen girl3 = 0
        gen girl1Xurban = girl1 * urban
        gen girl2Xurban = girl2 * urban
        gen girl3Xurban = girl3 * urban
        gen mom_age = b1_mom_age + `mom_age_4'

        dis "4th spell in period `period' for `educ' with 2 boys / 1 girl"
        predict_fertility 4 `period' `educ'
        gen prob_4th_birth_bbg = prob_any_birth
        gen prob_4th_son_bbg   = pct_sons / 100

        // 4th spell if 1 boys / 2 girls
        drop girl* mom_age
        gen girl1 = 0
        gen girl2 = 2 
        gen girl3 = 0
        gen girl1Xurban = girl1 * urban
        gen girl2Xurban = girl2 * urban
        gen girl3Xurban = girl3 * urban
        gen mom_age = b1_mom_age + `mom_age_4'

        dis "4th spell in period `period' for `educ' with 1 boy / 2 girls"
        predict_fertility 4 `period' `educ'
        gen prob_4th_birth_bgg = prob_any_birth
        gen prob_4th_son_bgg   = pct_sons / 100

        // 4th spell if three girls
        drop girl* mom_age
        gen girl1 = 0
        gen girl2 = 0 
        gen girl3 = 1
        gen girl1Xurban = girl1 * urban
        gen girl2Xurban = girl2 * urban
        gen girl3Xurban = girl3 * urban
        gen mom_age = b1_mom_age + `mom_age_4'

        dis "4th spell in period `period' for `educ' with 3 girls"
        predict_fertility 4 `period' `educ'
        gen prob_4th_birth_ggg = prob_any_birth
        gen prob_4th_son_ggg   = pct_sons / 100



        gen pred_1 = prob_1st_birth

        gen pred_2 = prob_1st_birth * (             ///
            prob_1st_son * prob_2nd_birth_b +       ///
            (1 - prob_1st_son) * prob_2nd_birth_g   ///
        )

        gen pred_3 = prob_1st_birth * (                     ///
            prob_1st_son * prob_2nd_birth_b * (             ///
                prob_2nd_son_b       * prob_3rd_birth_bb +  ///
                (1 - prob_2nd_son_b) * prob_3rd_birth_bg    ///
            )                                               ///
            +                                               ///
            (1 - prob_1st_son) * prob_2nd_birth_g * (       ///
                prob_2nd_son_g       * prob_3rd_birth_bg +  ///
                (1 - prob_2nd_son_g) * prob_3rd_birth_gg    ///
            )                                               ///
        )

        gen pred_4 = prob_1st_birth * (                             ///
            prob_1st_son * prob_2nd_birth_b * (                     ///
                prob_2nd_son_b       * prob_3rd_birth_bb * (        ///
                    prob_3rd_son_bb       * prob_4th_birth_bbb +    ///
                    (1 - prob_3rd_son_bb) * prob_4th_birth_bbg      ///
                )                                                   ///
                +                                                   ///
                (1 - prob_2nd_son_b) * prob_3rd_birth_bg * (        ///
                    prob_3rd_son_bg       * prob_4th_birth_bbg +    ///
                    (1 - prob_3rd_son_bg) * prob_4th_birth_bgg      ///
                )                                                   ///
            )                                                       ///
            +                                                       ///
            (1 - prob_1st_son) * prob_2nd_birth_g * (               ///
                prob_2nd_son_g       * prob_3rd_birth_bg * (        ///
                    prob_3rd_son_bg       * prob_4th_birth_bbg +    ///
                    (1 - prob_3rd_son_bg) * prob_4th_birth_bgg      ///
                )                                                   ///
                +                                                   ///
                (1 - prob_2nd_son_g) * prob_3rd_birth_gg * (        ///
                    prob_3rd_son_gg       * prob_4th_birth_bgg +    ///
                    (1 - prob_3rd_son_gg) * prob_4th_birth_ggg      ///
                )                                                   ///
            )                                                       ///
        )

        gen pred_fertility = pred_1 + pred_2 + pred_3 + pred_4

        // Save prediction results
        collapse (mean) pred_fertility pred_1 pred_2 pred_3 pred_4 ///
            (min) min_pred_fertility = pred_fertility ///
            (max) max_pred_fertility = pred_fertility ///
            , by(urban)
            
        list

        save `data'/predicted_fertility_hazard_g`period'_`educ'_r`round', replace

        restore
    }
}
