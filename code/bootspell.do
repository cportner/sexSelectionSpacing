
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
        
    bh_s`spell'_g`group'_`educ'
    loc i = `r(numPer)'

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

    loc np "  np*X* "

    // ESTIMATION
    eststo: mlogit birth dur* $b1space ///
        $parents $hh $caste `np'  ///
        , baseoutcome(0) noconstant 

    // PREDICTIONS BASED ON SAMPLE
    // 25, 50, and 75% spacing, sex ratio, and parity progression likelihood
    
    // Revert to only one observation and then expand to max t
    bysort id (t): keep if _n == 1
    capture drop dur* np* t
    expand $lastm
    bysort id: gen t = _n
    gen months = t * 3

    // PIECE-WISE LINEAR HAZARDS
    bh_s`spell'_g`group'_`educ'
    loc i = `r(numPer)'
    
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

    // Sons born
    gen ratio_sons = pcbg * prob_kid
    bysort id (t): egen num_sons = total(ratio_sons)
    bysort id (t): gen  pct_sons = (num_sons / (1 - s[_N])) * 100

    //----------------------------------------------------//
    // Median duration conditional on parity progression  //
    //----------------------------------------------------//

    gen below = pps < 0.5
    gen median = int(months - ((0.5 - pps) / (pps[_n-1] - pps)) * 3) ///
        if below & !below[_n-1] 
        // Because each t is 3 months long, this creates a "weighted" average and then 
        // rounds to get a month. All other obs are missing.
    
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

            // Calculation for median at sex composition and area
            sum median `sexcomp'
            loc girls = `spell' - `prior' // means 0 girls (or boys) in first spell
            return scalar p50_`where'_g`girls' = `r(mean)'
            // can add more statistics here
        }
    }

    restore
end



