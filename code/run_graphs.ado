// Programs for survival and percentage boys graphs

program run_graphs
    version 13
    args spell period educ
    
    include directories
    
    drop _all
    gen id = .
    // `e(estimates_note1)'
    estimates use `data'/results_spell`spell'_g`period'_`educ'
    
    // create fake obs for graphs
    loc newn = 0
    loc lastm = `e(estimates_note2)'
    loc lastk = `spell' * 2
    forvalues k = 1/`lastk' {
        loc newn = `newn' + `lastm'
        set obs `newn'
        replace id = `k' if id == .
    }
    sort id
    bysort id: gen t = _n
    
    tokenize `e(estimates_note1)'
    loc i = 1
    while "``i''" != "" {
        loc var = substr("``i++''",3,.)
        capture gen `var' = .
    }
    capture gen birth = .
    
    // Common variables for representative woman
    recode scheduled* (.=0)
    recode land_own (.=0) 
    gen months = t * 3    
    gen     urban = 0 if mod(id, 2) == 1 // Odd is rural
    replace urban = 1 if mod(id, 2) == 0 // Even is urban
    
    // Variables for representative woman that vary by spell
    loc spell_m1 = `spell' - 1
    // Note: spell 1 will never enter the loop
    forvalues j = 1/`spell_m1' {
        gen girl`j' = 0
    }
    if `spell' == 1 {
        if "`educ'" == "low" {
            replace mom_age = 16
        }
        else if "`educ'" == "med" {
            replace mom_age = 17      
        }
        else if "`educ'" == "high" {        
            replace mom_age = 20
        }
    }
    else {
        replace b1space = 16
        replace b1space2 = b1space^2/100   
        replace girl1 = 1 if id == 3 | id == 4
        if `spell' > 2 {
            replace girl2 = 1 if id == 5 | id == 6
            if `spell' > 3 {
                replace girl3 = 1 if id == 7 | id == 8
            }
        }
    
        if `spell' == 2 {
            if "`educ'" == "low" {
                replace mom_age = 18
            }
            else if "`educ'" == "med" {
                replace mom_age = 19      
            }
            else if "`educ'" == "high" {        
                replace mom_age = 22
            }
        }
        else if `spell' == 3 {
            if "`educ'" == "low" {
                replace mom_age = 20
            }
            else if "`educ'" == "med" {
                replace mom_age = 21      
            }
            else if "`educ'" == "high" {        
                replace mom_age = 24
            }
        }
        else if `spell' == 4 {
            if "`educ'" == "low" {
                replace mom_age = 23
            }
            else if "`educ'" == "med" {
                replace mom_age = 24      
            }
            else if "`educ'" == "high" {        
                replace mom_age = 25
            }
        }
        else {
            dis "Something went wrong with representative women variables"
        }
    }
    forvalues j = 1/`spell_m1' {
        gen girl`j'Xurban = girl`j' * urban
    }

    
    capture drop dur* 
    capture drop d1-d21
    tab t, gen(d)
    
    // PIECE-WISE LINEAR HAZARDS     
    bh_`educ' `spell' `period'
    loc i = `r(numPer)'
    
    
    // CREATE INTERACTIONS BASED ON SPELL NUMBER
    // Note: spell 1 will never enter the loop
    capture drop np*
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
    
    predict p0, pr outcome(0) // no child
    predict p1, pr outcome(1) // boy
    predict p2, pr outcome(2) // girl


    // percentage 
    capture predictnl pcbg = predict(outcome(1))/(predict(outcome(1)) + predict(outcome(2))) if p2 > 0.000001, ci(pcbg_l pcbg_u)
    gen pc   = pcbg   * 100
    gen pc_l = pcbg_l * 100
    gen pc_u = pcbg_u * 100
    
    graph_spell`spell' `period' `educ'

end

// Individual spell graph programs

program graph_spell1
    version 13
    args period educ
    include directories

    set scheme s1mono
    loc goptions "xtitle(Months) xlabel(0(6)72) clpattern("l" "-" "-") legend(off) clwidth(medthick..) mlwidth(medthick..) yline(51.2 , lstyle(foreground) extend)"

    line pc pc_l pc_u months if urban, sort `goptions' ylabel(40(5)75)
    graph export `figures'/spell1_g`period'_`educ'_urban_pc.eps, replace fontface(Palatino) 

    line pc pc_l pc_u months if !urban, sort `goptions' ylabel(40(5)75)
    graph export `figures'/spell1_g`period'_`educ'_rural_pc.eps, replace fontface(Palatino) 


    // survival curves
    bysort id (t): gen s = exp(sum(ln(p0)))
    set scheme s1mono
    loc goptions "xtitle(Months) xlabel(0(6)72) ytitle("") legend(off) clwidth(medthick..) mlwidth(medthick..) ylabel(0.0(0.2)1.0, grid glw(medthick)) "

    line s months if urban, sort `goptions'
    graph export `figures'/spell1_g`period'_`educ'_urban_s.eps, replace fontface(Palatino) 

    line s months if !urban, sort `goptions'
    graph export `figures'/spell1_g`period'_`educ'_rural_s.eps, replace fontface(Palatino) 


    // data for survival curves conditional on parity progression
    bysort id (t): gen double pps = (s - s[_N]) / (1.00 - s[_N])
    gen period = `period'
    gen educ   = "`educ'"
    // Merge in observation data
    merge m:1 urban using `data'/obs_spell1_`period'_`educ'
    sort id t
    drop _merge
    save `data'/spell1_g`period'_`educ' , replace

end

program graph_spell2
    version 13
    args period educ
    include directories

    set scheme s1mono
    loc goptions "xtitle(Months)  xlabel(0(6)72) clpattern("l" "-" "-") legend(off) clwidth(medthick..) mlwidth(medthick..) yline(51.2 , lstyle(foreground) extend) ylabel(35(5)75)"

    line pc pc_l pc_u months if urban & girl1, sort `goptions' 
    graph export `figures'/spell2_g`period'_`educ'_urban_g_pc.eps, replace fontface(Palatino) 

    line pc pc_l pc_u months if urban & !girl1, sort `goptions'
    graph export `figures'/spell2_g`period'_`educ'_urban_b_pc.eps, replace fontface(Palatino) 

    line pc pc_l pc_u months if !urban & girl1, sort `goptions'
    graph export `figures'/spell2_g`period'_`educ'_rural_g_pc.eps, replace fontface(Palatino) 

    line pc pc_l pc_u months if !urban & !girl1, sort `goptions'
    graph export `figures'/spell2_g`period'_`educ'_rural_b_pc.eps, replace fontface(Palatino) 

    

    // survival curves
    bysort id (t): gen s = exp(sum(ln(p0)))
    set scheme s1mono
    loc goptions "xtitle(Months) xlabel(0(6)72) ytitle("") legend(off) clwidth(medthick..) mlwidth(medthick..) ylabel(0.0(0.2)1.0, grid glw(medthick)) "


    line s months if urban & girl1, sort `goptions'
    graph export `figures'/spell2_g`period'_`educ'_urban_g_s.eps, replace fontface(Palatino) 

    line s months if urban & !girl1, sort `goptions'
    graph export `figures'/spell2_g`period'_`educ'_urban_b_s.eps, replace fontface(Palatino) 

    line s months if !urban & girl1, sort `goptions'
    graph export `figures'/spell2_g`period'_`educ'_rural_g_s.eps, replace fontface(Palatino) 

    line s months if !urban & !girl1, sort `goptions'
    graph export `figures'/spell2_g`period'_`educ'_rural_b_s.eps, replace fontface(Palatino) 


    // data for survival curves conditional on parity progression
    bysort id (t): gen double pps = (s - s[_N]) / (1.00 - s[_N])
    gen period = `period'
    gen educ   = "`educ'"
    // Merge in observation data
    merge m:1 girl1 urban using `data'/obs_spell2_`period'_`educ'
    sort id t
    drop _merge
    save `data'/spell2_g`period'_`educ' , replace

end

program graph_spell3
    version 13
    args period educ
    include directories

    set scheme s1mono
    loc goptions "xtitle(Months) xlabel(0(6)72) clpattern("l" "-" "-") legend(off) clwidth(medthick..) mlwidth(medthick..) yline(51.2 , lstyle(foreground) extend) ylabel(30(5)85)"

    line pc pc_l pc_u months if urban & girl2, sort `goptions' 
    graph export `figures'/spell3_g`period'_`educ'_urban_gg_pc.eps, replace fontface(Palatino) 

    line pc pc_l pc_u months if urban & girl1, sort `goptions' 
    graph export `figures'/spell3_g`period'_`educ'_urban_bg_pc.eps, replace fontface(Palatino) 

    line pc pc_l pc_u months if urban & !girl1 & !girl2, sort `goptions' 
    graph export `figures'/spell3_g`period'_`educ'_urban_bb_pc.eps, replace fontface(Palatino) 

    line pc pc_l pc_u months if !urban & girl2, sort `goptions' 
    graph export `figures'/spell3_g`period'_`educ'_rural_gg_pc.eps, replace fontface(Palatino) 

    line pc pc_l pc_u months if !urban & girl1, sort `goptions' 
    graph export `figures'/spell3_g`period'_`educ'_rural_bg_pc.eps, replace fontface(Palatino) 

    line pc pc_l pc_u months if !urban & !girl1 & !girl2, sort `goptions' 
    graph export `figures'/spell3_g`period'_`educ'_rural_bb_pc.eps, replace fontface(Palatino) 

    // survival curves
    bysort id (t): gen s = exp(sum(ln(p0)))
    set scheme s1mono
    loc goptions "xtitle(Months) xlabel(0(6)72) ytitle("") legend(off) clwidth(medthick..) mlwidth(medthick..) ylabel(0.0(0.2)1.0, grid glw(medthick)) "

    line s months if urban & girl2, sort `goptions'
    graph export `figures'/spell3_g`period'_`educ'_urban_gg_s.eps, replace fontface(Palatino) 

    line s months if urban & girl1, sort `goptions'
    graph export `figures'/spell3_g`period'_`educ'_urban_bg_s.eps, replace fontface(Palatino) 

    line s months if urban & !girl1 & !girl2, sort `goptions'
    graph export `figures'/spell3_g`period'_`educ'_urban_bb_s.eps, replace fontface(Palatino) 

    line s months if !urban & girl2, sort `goptions'
    graph export `figures'/spell3_g`period'_`educ'_rural_gg_s.eps, replace fontface(Palatino) 

    line s months if !urban & girl1, sort `goptions'
    graph export `figures'/spell3_g`period'_`educ'_rural_bg_s.eps, replace fontface(Palatino) 

    line s months if !urban & !girl1 & !girl2, sort `goptions'
    graph export `figures'/spell3_g`period'_`educ'_rural_bb_s.eps, replace fontface(Palatino) 

    // data for survival curves conditional on parity progression
    bysort id (t): gen double pps = (s - s[_N]) / (1.00 - s[_N])
    gen period = `period'
    gen educ   = "`educ'"
    // Merge in observation data
    merge m:1 girl1 girl2 urban using `data'/obs_spell3_`period'_`educ'
    sort id t
    drop _merge
    save `data'/spell3_g`period'_`educ' , replace

end

program graph_spell4
    version 13
    args period educ
    include directories

    set scheme s1mono
    loc goptions "xtitle(Months) xlabel(0(6)54) clpattern("l" "-" "-") legend(off) clwidth(medthick..) mlwidth(medthick..) yline(51.2 , lstyle(foreground) extend) ylabel(25(5)90)"

    line pc pc_l pc_u months if urban & girl3, sort `goptions'
    graph export `figures'/spell4_g`period'_`educ'_urban_ggg_pc.eps, replace fontface(Palatino) 

    line pc pc_l pc_u months if urban & girl2, sort `goptions'
    graph export `figures'/spell4_g`period'_`educ'_urban_bgg_pc.eps, replace fontface(Palatino) 

    line pc pc_l pc_u months if urban & girl1, sort `goptions'
    graph export `figures'/spell4_g`period'_`educ'_urban_bbg_pc.eps, replace fontface(Palatino) 

    line pc pc_l pc_u months if urban & !girl1 & !girl2 & !girl3, sort `goptions'
    graph export `figures'/spell4_g`period'_`educ'_urban_bbb_pc.eps, replace fontface(Palatino) 

    line pc pc_l pc_u months if !urban & girl3, sort `goptions'
    graph export `figures'/spell4_g`period'_`educ'_rural_ggg_pc.eps, replace fontface(Palatino) 

    line pc pc_l pc_u months if !urban & girl2, sort `goptions'
    graph export `figures'/spell4_g`period'_`educ'_rural_bgg_pc.eps, replace fontface(Palatino) 

    line pc pc_l pc_u months if !urban & girl1, sort `goptions'
    graph export `figures'/spell4_g`period'_`educ'_rural_bbg_pc.eps, replace fontface(Palatino) 

    line pc pc_l pc_u months if !urban & !girl1 & !girl2 & !girl3, sort `goptions'
    graph export `figures'/spell4_g`period'_`educ'_rural_bbb_pc.eps, replace fontface(Palatino) 



    // survival curves
    bysort id (t): gen s = exp(sum(ln(p0)))
    set scheme s1mono
    loc goptions "xtitle(Months) xlabel(0(6)54) ytitle("") legend(off) clwidth(medthick..) mlwidth(medthick..) ylabel(0.0(0.2)1.0, grid glw(medthick)) "

    line s months if urban & girl3, sort `goptions'
    graph export `figures'/spell4_g`period'_`educ'_urban_ggg_s.eps, replace fontface(Palatino) 

    line s months if urban & girl2, sort `goptions'
    graph export `figures'/spell4_g`period'_`educ'_urban_bgg_s.eps, replace fontface(Palatino) 

    line s months if urban & girl1, sort `goptions'
    graph export `figures'/spell4_g`period'_`educ'_urban_bbg_s.eps, replace fontface(Palatino) 

    line s months if urban & !girl1 & !girl2 & !girl3, sort `goptions'
    graph export `figures'/spell4_g`period'_`educ'_urban_bbb_s.eps, replace fontface(Palatino) 

    line s months if !urban & girl3, sort `goptions'
    graph export `figures'/spell4_g`period'_`educ'_rural_ggg_s.eps, replace fontface(Palatino) 

    line s months if !urban & girl2, sort `goptions'
    graph export `figures'/spell4_g`period'_`educ'_rural_bgg_s.eps, replace fontface(Palatino) 

    line s months if !urban & girl1, sort `goptions'
    graph export `figures'/spell4_g`period'_`educ'_rural_bbg_s.eps, replace fontface(Palatino) 

    line s months if !urban & !girl1 & !girl2 & !girl3, sort `goptions'
    graph export `figures'/spell4_g`period'_`educ'_rural_bbb_s.eps, replace fontface(Palatino) 


    // data for survival curves conditional on parity progression
    bysort id (t): gen double pps = (s - s[_N]) / (1.00 - s[_N])
    gen period = `period'
    gen educ   = "`educ'"
    // Merge in observation data
    merge m:1 girl1 girl2 girl3 urban using `data'/obs_spell4_`period'_`educ'
    sort id t
    drop _merge
    save `data'/spell4_g`period'_`educ' , replace

end


