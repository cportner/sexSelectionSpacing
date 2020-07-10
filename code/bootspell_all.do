
program bootspell_all, rclass
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

    // PIECE-WISE LINEAR HAZARDS - REMEMBER TO CHANGE BELOW IF ANY CHANGES HERE!
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
        forvalues per = 1(2)6 {
            gen dur`i' = t >= `per' & t <= `per' + 1
            loc ++i
        }
        gen dur`i' = t >= 7 & t <= 9
        loc ++i
        gen dur`i' = t >= 10 & t <= 14
        loc ++i
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
    // + 9 to get to birth intervals rather than spell lengths
    gen months = t * 3 + 9 
    gen mid_months = (t-1)*3 + 1.5 + 9

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
        forvalues per = 1(2)6 {
            gen dur`i' = t >= `per' & t <= `per' + 1
            loc ++i
        }
        gen dur`i' = t >= 7 & t <= 9
        loc ++i
        gen dur`i' = t >= 10 & t <= 14
        loc ++i
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
    
    // PPS probability
    gen double prob_pps = 1 - pps if t == 1
    replace prob_pps = pps[_n-1] - pps[_n] if t != 1
    
    //------------------------------------------------------//
    // Duration measures conditional on parity progression  //
    //------------------------------------------------------//

    bysort id (t): asgen average_duration = mid_months, w(prob_pps)

    foreach percent of numlist 25 50 75 {
        loc percentile = `percent' / 100
        gen percentile`percent' = ///
            (months - ((`percentile' - pps) / (pps[_n-1] - pps)) * 3) ///
            if pps < `percentile' & pps[_n-1] > `percentile'                
    }
    xfill percentile* , i(id)

    //------------------------------------------------------//
    // Generate return values                               //
    //------------------------------------------------------//
    
    bysort id (t): keep if _n == _N    

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
            
            // Average spell lengths at sex composition and area
            sum average_duration `sexcomp' [iweight = prob_any_birth]
            local avg_`where'_g`girls' = `r(mean)'
            return scalar avg_`where'_g`girls' = `avg_`where'_g`girls''                
            
            // Percentile spell lengths at sex composition and area
            foreach percent of numlist 25 50 75  {
                sum percentile`percent' `sexcomp' [iweight = prob_any_birth]
                local p`percent'_`where'_g`girls' = `r(mean)'
                return scalar p`percent'_`where'_g`girls' = `p`percent'_`where'_g`girls''                
            }
            
            // Percent boys
            sum pct_sons `sexcomp' [iweight = prob_any_birth]
            return scalar pct_`where'_g`girls' = `r(mean)'
            
            // Likelihood of birth by spell end
            sum prob_any_birth `sexcomp'
            return scalar any_`where'_g`girls' = `r(mean)'
                        
            // can add more statistics here
        }

        // Differences for testing - only girls against each of the other sex compositions
        loc all_girls = `spell' - 1
        loc end = `spell' - 2
        forvalues comp = 0 / `end' {
            return scalar diff_avg_`where'_g`all_girls'_vs_g`comp' = `avg_`where'_g`all_girls'' - `avg_`where'_g`comp''
            foreach per of numlist 25 50 75 {
                return scalar diff_p`per'_`where'_g`all_girls'_vs_g`comp' = `p`per'_`where'_g`all_girls'' - `p`per'_`where'_g`comp''
            } 
        }

    }

    restore
end



