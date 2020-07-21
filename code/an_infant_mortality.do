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

// No longer needed since I now use birth interval rather than spell
// throughout the paper
// Birth spacing variables to match what I used for hazard model
// replace b2_space = b2_space - 9
// replace b3_space = b3_space - 9
// replace b4_space = b4_space - 9

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


set scheme s1mono

// Estimation by spell

// forvalues spell = 2/3 {
forvalues spell = 2/2 {

    keep if fertility >= `spell'

    loc spell_m1 = `spell' - 1

    egen b`spell'_d_space = cut(b`spell'_space), at(9 21 33 45 57 100)

    forvalues period = 1/4 {

        foreach educ in "highest" "high" "med" "low" {

//             // Estimation results for highest education group in the 1972-84 period unreliable
//             // because of too small sample size
//             if "`educ'" == "highest" & `period' == 1 {
//                 continue
//             }

            preserve
        
            keep if b`spell_m1'_group == `period' // When the spell began

            // Drop those less than 1 year old, without spell births, where the child had
            // not reached 12 months of age by interview, or spell longer than what is used
            // for the hazard estimations
            drop if b`spell'_born_cmc == .
            drop if interview_cmc - b`spell'_born_cmc < 13
            keep if b`spell'_space >= 0 & b`spell'_space <= 96

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

    //         egen b`spell'_d_space = cut(b`spell'_space), group(7) label

    //         gen mom_age = b2_mom_age
    //         gen girl1 = b1_girl
    //         gen girl1Xurban = girl1 * urban
    //         // predict_fertility 2 4 highest

            // prior child(ren) variable
            if `spell' == 2 {
                gen girls = b1_girl
                if `period' == 1 {
//                     local label `" order(3 "1st girl, 2nd boy" 4 "1st girl, 2nd girl" 1 "1st boy, 2nd boy" 2 "1st boy, 2nd girl") col(1) subtitle("First Child, Second Child", size(vsmall)) "'
                    local label `" order(3 "Girl / Boy" 4 "Girl / Girl" 1 "Boy / Boy" 2 "Boy / Girl") subtitle("First Child / Second Child", size(small)) "'
                    local legend " legend(`label' size(small) col(2) colfirst ring(0) position(2) bmargin(tiny) region(margin(tiny) lwidth(none)) keygap(0.5) colgap(1.5) rowgap(0.25)  forcesize ) "
                    }
                else {
                    local legend "legend(off)"
                }
            }
            else if `spell' == 3 {
                gen girls = 0     if !(b1_sex == 2 & b2_sex == 2) & b1_sex != . & b2_sex != . 
                replace girls = 2 if (b1_sex == 2 & b2_sex == 2)  & b1_sex != . & b2_sex != . 
                local label `" order(3 "2 girls, 3rd boy" 4 "2 girls, 3rd girl" 1 "1 or 2 boys, 3rd boy" 2 "1 or 2 boys, 3rd girl") col(1) subtitle("Prior Children, Third Child") "'
            }
            else if `spell' == 4 {
                gen girls = 0     if !(b1_sex == 2 & b2_sex == 2 & b3_sex == 2) & b1_sex != . & b2_sex != . & b3_sex != .
                replace girls = 3 if (b1_sex == 2 & b2_sex == 2 & b3_sex == 2)  & b1_sex != . & b2_sex != . & b3_sex != .
//                 local label `" order(3 "1st girl, 2nd boy" 4 "1st girl, 2nd girl" 1 "1st boy, 2nd boy" 2 "1st boy, 2nd girl") "'
            }
            else {
                dis "Spell not coded yet"
                exit
            }
                        
            if "`educ'" == "low" | "`educ'" == "high" {
                if `period' == 1 {
                    loc y_info `"ytitle("1972-1984")"'
                }
                if `period' == 2 {
                    loc y_info `"ytitle("1985-1994")"'
                }
                if `period' == 3 {
                    loc y_info `"ytitle("1995-2004")"'
                }
                if `period' == 4 {
                    loc y_info `"ytitle("2005-2016")"'
                }
                loc fxsize "fxsize(100)"
            }
            else {
                loc y_info `"ytitle("")"'
                loc fxsize "fxsize(95.75)"
            }

            if `period' == 1 {
                if "`educ'" == "low"     loc mort_title `"title("No Education", size(medium))"'
                if "`educ'" == "med"     loc mort_title `"title("1-7 Years of Education", size(medium))"'
                if "`educ'" == "high"    loc mort_title `"title("8-11 Years of Education", size(medium))"'
                if "`educ'" == "highest" loc mort_title `"title("12- Years of Education", size(medium))"'                
                loc fysize "fysize(95.6)"
            }
            else {
                loc mort_title `"title("")"'
                loc fysize "fysize(87)"
            }
                        
            if `period' == 4 {
                loc x_info `"xlabel(9 "9-20" 21 "21-32" 33 "33-44" 45 "45-56" 57 "57+" ) xtitle("Preceding Birth Interval (Months)")"'
                loc fysize "fysize(100)"
            }
            else {
//                 loc x_info "xscale(off)"
                loc x_info "xtick(9 21 33 45 57) xlabel(none) xtitle("")"
            }

            loc reg_vars = " i.girls##i.b`spell'_girl##i.b`spell'_d_space "
            loc mar_vars = " b`spell'_d_space#girls#b`spell'_girl "
            
            dis _n
            dis "Education: `educ' in period `period' for spell `spell'"
            table b`spell'_d_space  b`spell'_died_as_infant girls , ///
                by(b`spell'_girl) cont(freq) col row

            logit b`spell'_died_as_infant b1_mom_age scheduled_caste land_own urban ///
                `reg_vars' 
            margins `mar_vars' 
            marginsplot, x(b`spell'_d_space) noci /// 
                `mort_title' ///
                `y_info' ///
                `x_info' ///
                `legend' ///
                plotopts( ///
                    msymbol(i) ylabel(0(0.05)0.20, grid) plotregion(margin(zero) style(none)) ///
                    lwidth(medthick..) ///
                    yscale(range(0 0.25)) ///
                ) ///
                plot1opts(lpattern(shortdash)) ///
                plot2opts(lpattern(dash) ) ///
                plot3opts(lpattern(solid) ) ///
                plot4opts(lpattern(longdash) ) ///
                `fysize' `fxsize' ///
                name(mort_`educ'_`period', replace) 


    //         logit b2_died_as_infant b1_mom_age scheduled_caste land_own urban ///
    //             i.b1_girl##i.b2_girl##(c.b2_space c.b2_space#c.b2_space ///
    //             c.b2_space#c.b2_space#c.b2_space c.b2_space#c.b2_space#c.b2_space#c.b2_space)
    //         margins b1_girl#b2_girl , at(b2_space == (1(3)70) )
    //         marginsplot
    //         graph export `figures'/mortality_s`spell'_p`period'_`educ'_continuous.eps, replace fontface(Palatino)

            restore
        }
    }
    
    graph combine mort_low_1 mort_med_1 mort_low_2 mort_med_2 mort_low_3 mort_med_3 mort_low_4 mort_med_4 , ///
        col(2) xcommon ysize(9) xsize(6.5) imargin(0 2 3 0) ///
        iscale(*0.9)
            
    graph export `figures'/mortality_low_med.eps, replace fontface(Palatino)
    
    graph combine mort_high_1 mort_highest_1 mort_high_2 mort_highest_2 mort_high_3 mort_highest_3 mort_high_4 mort_highest_4 , ///
        col(2) xcommon ysize(9) xsize(6.5) imargin(0 2 3 0) ///
        iscale(*0.9)
    
    graph export `figures'/mortality_high_highest.eps, replace fontface(Palatino)
    
}
