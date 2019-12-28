// Program for estimations

program run_analysis_all
    args spell period educ
    
    include directories

    log using run_analysis_all_`spell'_`period'_`educ'.log, replace

    use `data'/base, clear


    // keep only those in education group
    if "`educ'" == "low" {
        keep if edu_mother == 0
    }
    else if "`educ'" == "med" {
        keep if edu_mother >= 1 & edu_mother < 8
    }
    else if "`educ'" == "high" {
        keep if edu_mother >= 8
    }
    else {
        dis "Something went wrong with education level"
        exit
    }

    // data manipulation
    if `spell' == 1 {
        global b1space ""
        loc girlvar ""
    } 
    else {
        loc girlvar " girl* "
    }
    do genSpell`spell'

    keep if group == `period'
    count
    sum $parents $hh $caste 
    estpost tab gu_group
    esttab using `tables'/mainObs_spell`spell'_g`period'_`educ'.tex, replace ///
        cells("b(label(N))") ///
        nonumber nomtitle noobs
    eststo clear

    // GENERATE TIME VARIABLES
    expand b`spell'_space 
    bysort id: gen t = _n
    
    // the b2_cen == 0 is needed since I restrict the duration to `lastm' above
    // b2_sex is the child born as end of spell 2
    gen byte birth = 0
    bysort id (t): replace birth = 1 if b`spell'_sex == 1 & b`spell'_cen == 0 & _n == _N // exit with a son
    bysort id (t): replace birth = 2 if b`spell'_sex == 2 & b`spell'_cen == 0 & _n == _N // exit with a daugther
    tab t, gen(d)

    // Save number of observation data
    preserve
    bysort id (t): egen any_birth = max(birth)
    bysort id (t): keep if _n == 1
    gen had_birth = any_birth == 1 | any_birth == 2 // gave birth to a boy or a girl
    collapse (count) num_obs = had_birth (sum) num_births = had_birth , by(`girlvar' urban) 
    save `data'/obs_spell`spell'_`period'_`educ', replace
    restore
    
    // PIECE-WISE LINEAR HAZARDS
        
    bh_`educ'  `spell' `period'
    loc i = `r(numPer)'

    // CREATE INTERACTIONS BASED ON SPELL NUMBER
    // Note: spell 1 will never enter the loop
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
    eststo clear
    eststo: mlogit birth dur* $b1space ///
        $parents $hh $caste `np'  ///
        , baseoutcome(0) noconstant 

    local names : colfullnames e(b)
    estimates notes: `names'
    estimates notes: $lastm
    estimates save `data'/results_spell`spell'_g`period'_`educ', replace
    
    log close
    
end




    
