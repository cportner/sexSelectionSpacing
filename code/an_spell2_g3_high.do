* Women with high education (8+ years) for both urban and rural
* Competing Discrete Hazard model
* Second spell (from 1st to second birth)
* an_spell2_g3_high.do
* Begun.: 2017-06-04
* Edited: 2017-06-04 


include common

keep if edu_mother >= 8
loc educ = "high"

// data manipulation
do genSpell2

// Group
forvalues group = 3/3 {
    dis _n
    dis "******************************************************"
    dis "*                  THIS IS GROUP `group'                   *"
    dis "******************************************************"    
    dis _n
//         preserve
        keep if group == `group'
        count
        sum $parents $hh $caste 
        estpost tab gu_group
//         esttab using `tables'/mainObs_spell2_g`group'_`educ'.tex, replace ///
//             cells("b(label(N))") ///
//             nonumber nomtitle noobs
        eststo clear

        // GENERATE TIME VARIABLES
        expand b2_space 
        bysort id: gen t = _n
        // the b2_cen == 0 is needed since I restrict the duration to `lastm' above
        // b2_sex is the child born as end of spell 2
        gen byte birth = 0
        bysort id (t): replace birth = 1 if b2_sex == 1 & b2_cen == 0 & _n == _N // exit with a son
        bysort id (t): replace birth = 2 if b2_sex == 2 & b2_cen == 0 & _n == _N // exit with a daugther
        tab t, gen(d)
        // EXITS WITH BIRTH ONLY (NON-CENSORED)
        dis " All "
        tab b2_space if birth == 1 | birth == 2
        tab b2_space gu_group if birth == 1 | birth == 2
        tab t if b2_cen == 0

        // Save number of observation data
        preserve
        bysort id (t): egen any_birth = max(birth)
        bysort id (t): keep if _n == 1
        gen had_birth = any_birth == 1 | any_birth == 2
        collapse (count) num_obs = had_birth (sum) num_births = had_birth , by(girl1 urban) 
        save `data'/obs_spell2_`group'_`educ', replace
        restore
        
        // PIECE-WISE LINEAR HAZARDS
        loc i = 1
        forvalues per = 1(3)3 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 2 // 3 quarter years
            loc i = `i' + 1
        }
        forvalues per = 4(2)6 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 1 // half years
            loc i = `i' + 1
        }
        forvalues per = 8(4)11 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 3 // 3 quarter years
            loc i = `i' + 1
        }
        forvalues per = 12(5)17 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 4 // 3 quarter years
            loc i = `i' + 1
        }
//         gen dur`i' = t >= 16 & t <= 21
//         loc i = `i' + 1
        loc --i // needed because the non-prop below uses `i'
        
        egen sumdur = rowtotal(dur*)
        assert sumdur == 1
        
        // NON-PROPORTIONALITY
        foreach var of var ///
        girl1 urban girl1Xurban {
            forval x = 1/`i' {
                gen np`x'X`var'  = dur`x' * `var' 
            }
        }
        
        loc np "  np*X* "
        
        // ESTIMATION
        eststo clear
        eststo: mlogit birth dur* $b1space ///
            $parents $hh $caste `np'  ///
            , baseoutcome(2) noconstant 

        local names : colfullnames e(b)
        estimates notes: `names'
        estimates notes: $lastm
        estimates save `data'/results_spell2_g`group'_high, replace

//         est store M2
        
//         lrtest M2 M1

//         restore
    
}
