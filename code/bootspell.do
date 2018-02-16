
program bootspell, rclass
    version 13
    args spell group educ
    preserve
    
    // Need to generate a new id because of sampling with replacement and use that id instead
    replace id = _n
    
    // GENERATE TIME VARIABLES
    expand b`spell'_space 
    bysort id: gen t = _n
    // the b3_cen == 0 is needed since I restrict the duration to `lastm' above
    // b3_sex is the child born as end of spell 2
    gen byte birth = 0
    bysort id (t): replace birth = 1 if b`spell'_sex == 1 & b`spell'_cen == 0 & _n == _N // exit with a son
    bysort id (t): replace birth = 2 if b`spell'_sex == 2 & b`spell'_cen == 0 & _n == _N // exit with a daugther

    // PIECE-WISE LINEAR HAZARDS
    if `spell' == 1 | `spell' == 2 | `spell' == 3 {
        tab t, gen(dur)
        loc i = $lastm    
    }
    else if `spell' == 4 {
        loc i = 1
        gen dur`i' = t >= 1 & t <= 5
        loc ++i
        gen dur`i' = t >= 6 & t <= 10
        loc ++i
        gen dur`i' = t >= 11
    }


    // NON-PROPORTIONALITY
    loc npvar = "urban "
    loc spell_m1 = `spell'-1
    forvalues j = 1/`spell_m1' {
        loc npvar = "`npvar' girl`j' girl`j'Xurban "
    }
    foreach var of var `npvar' {
        forval x = 1/`i' {
            gen np`x'X`var'  = dur`x' * `var' 
        }
    }

    loc np "  np*X* "

    // ESTIMATION
    mlogit birth dur* $b1space ///
        $parents $hh $caste `np'  ///
        , baseoutcome(0) noconstant iterate(15)
        
    if `e(converged)' == 0 {
        dis "Multinomial logit did not converge!"
        exit
    }
        
    // PREDICTIONS BASED ON SAMPLE
    // 25, 50, and 75% spacing, sex ratio, and parity progression likelihood
    
    // Revert to only one observation and then expand to max t
    bysort id (t): keep if _n == 1
    capture drop dur* np* t
    expand $lastm
    bysort id: gen t = _n
    gen months = t * 3

    // PIECE-WISE LINEAR HAZARDS
    if `spell' == 1 | `spell' == 2 | `spell' == 3 {
        tab t, gen(dur)
        loc i = $lastm    
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
    capture predictnl pcbg = predict(outcome(1))/(predict(outcome(1)) + predict(outcome(2))) if p2 > 0.0000001

    // survival curves
    bysort id (t): gen double s = exp(sum(ln(p0)))
    
    // survival curves conditional on parity progression
    bysort id (t): gen double pps = (s - s[_N]) / (1.00 - s[_N])    

    // probability of kid
    gen     prob_kid = 1 - s if t == 1
    replace prob_kid = s[_n-1] - s[_n] if t != 1
    bysort id (t): gen double prob_any_birth = 1 - s[_N] // probability of having a birth by end of spell

    // Sons born
    gen ratio_sons = pcbg * prob_kid
    bysort id (t): egen num_sons = total(ratio_sons)
    bysort id (t): gen  pct_sons = (num_sons / (1 - s[_N])) * 100

    //----------------------------------------------------//
    // Median duration conditional on parity progression  //
    //----------------------------------------------------//

    gen below = pps < 0.5
    gen median = (months - ((0.5 - pps) / (pps[_n-1] - pps)) * 3) ///
        if below & !below[_n-1] 
        // Because each t is 3 months long, this creates a "weighted" average. 
        // All other obs are missing.

    replace below = pps < 0.25
    gen p25 = (months - ((0.25 - pps) / (pps[_n-1] - pps)) * 3) ///
        if below & !below[_n-1] 

    replace below = pps < 0.75
    gen p75 = (months - ((0.75 - pps) / (pps[_n-1] - pps)) * 3) ///
        if below & !below[_n-1] 
    
    // This part depends on spell 
    foreach where in "urban" "rural" {
        if "`where'" == "urban" {
            loc area = "urban"
        }
        if "`where'" == "rural" {
            loc area = "!urban"
        }

        forvalues prior = 1/`spell' {

            // Conditions for sex composition
            if `spell' == 1 {
                loc  sexcomp " if `area' "
            } 
            if `spell' == 2 {
                if `prior' == 1 {
                    loc sexcomp " if girl1 & `area' "
                }
                if `prior' == 2 {
                    loc sexcomp " if !girl1 & `area' "
                }    
            }
            if `spell' == 3 {
                if `prior' == 1 {
                    loc sexcomp " if girl2 & `area' "
                }
                if `prior' == 2 {
                    loc sexcomp " if girl1 & `area' "
                }    
                if `prior' == 3 {
                    loc sexcomp " if !girl1 & !girl2 & `area' "
                }    
            }
            if `spell' == 4 {
                if `prior' == 1 {
                    loc sexcomp " if girl3 & `area' "
                }
                if `prior' == 2 {
                    loc sexcomp " if girl2 & `area' "
                }    
                if `prior' == 3 {
                    loc sexcomp " if girl1 & `area' "
                }    
                if `prior' == 4 {
                    loc sexcomp " if !girl1 & !girl2 & !girl3 & `area' "
                }    
            }

            // Number of girls
            loc girls = `spell' - `prior' // means 0 girls (or boys) in first spell
            
            // Median spell length at sex composition and area
            sum median `sexcomp' [iweight = prob_any_birth]
            return scalar p50_`where'_g`girls' = `r(mean)'

            // 25 percentile spell length - remember 25% left!!
            sum p25 `sexcomp' [iweight = prob_any_birth]
            return scalar p25_`where'_g`girls' = `r(mean)'

            // 75 percentile spell length - remember 75% left!!
            sum p75 `sexcomp' [iweight = prob_any_birth]
            return scalar p75_`where'_g`girls' = `r(mean)'

            // Percent boys
            sum pct_sons `sexcomp' [iweight = prob_any_birth]
            return scalar pct_`where'_g`girls' = `r(mean)'
            
            // Likelihood of birth by spell end
            sum prob_any_birth `sexcomp'
            return scalar any_`where'_g`girls' = `r(mean)'
            
            // can add more statistics here
        }
    }

    restore
end



