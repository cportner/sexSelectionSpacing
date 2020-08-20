// Graph generation for bootstrap results
// Birth intervals rather than spell lengths

version 15.1
clear all

file close _all // easier, in case something went wrong with last file write (Stata does not close files gracefully)

// Weird Stata behavior; you can write my_matrix[1,2], but not my_matrix[1,"var_name"]
// when you want to extract a scalar.
// Need to get col number first using variable name, then call matrix (grumble, grumble)
// program that takes a matrix and a name and returns the column number
capture program drop _all
program find_col, rclass
    args mat_name name
    local col_names : colfullnames `mat_name'
    tokenize `col_names'
    local i = 1
    local found = 0
    while "``i''" != "" & `found' == 0 {
        if "`name'" == "``i''" {
            return scalar col_num = `i' 
            local found = 1
        }
        local i = `i' + 1
    }
end

include directories

// Load bootstrap results and create matrices.
foreach educ in "low" "med" "high" "highest" {
    forvalues spell = 2/4 {
    
		// Do not run the fourth spell for the highest education group; too few obs in the earlier years
		if "`educ'" == "highest" & `spell' == 4 {
			continue
		}
            
        forvalues period = 1/4 {

    
            // Load bootstrap generated data and call bstat to replay results
            clear results // Stupid Stata - calling bstat after using the data does not clear old bstat
            use `data'/bs_s`spell'_g`period'_`educ'_all, clear
            quietly bstat
        
            // Relevant matrices to extract
            // point estimates e(b)
            matrix b_s`spell'_g`period'_`educ' = e(b)
            // standard errors e(se)
//                 matrix se_s`spell'_g`period'_`educ' = e(se)
            // Number of observations - assumes implicitly that all have the
            // same number of repetitions; last run will be used. In practice
            // this should not be a problem as long as all within an education
            // group are run at the same time using the an_bootstrap file.
            loc num_reps = e(N_reps)            
        }        
    }
}


set scheme s1mono

// Design choices:
// More likely to use sex selection -> more solid line
// Hence, 
// all girls: solid line, 
// one girl less: long dash
// two girls less: dash
// three girls less: short dash
// Always start with solid line, so if no children the line is solid
// All three graphs have same legend
// Only bottom graph (likelihood of next birth) have an x axis
// There are no confidence intervals in graphs (refer to tables for those)
 
foreach educ in "low" "med" "high" "highest" {
    foreach where in "urban" "rural" {
    
        // Graph names for combining
        loc gr_interval ""
        loc gr_pct ""
        loc gr_any ""

        forvalues spell = 2/4 {

            // Do not run the fourth spell for the highest education group; too few obs in the earlier years
            if "`educ'" == "highest" & `spell' == 4 {
                continue
            }
            
            // Set up data from matrix
            clear // Needed because we are generating new data sets based on matrices in svmat below
            matrix tmp_mat = (1, b_s`spell'_g1_`educ' \ 2, b_s`spell'_g2_`educ' \ 3, b_s`spell'_g3_`educ' \  4, b_s`spell'_g4_`educ')
            svmat tmp_mat, names( col )
        
            // Generate y variables in reverse order to match line pattern
            foreach stat in "p25" "p50" "p75" "pct" "any" {
                loc `stat' = ""
                forval i = `spell'(-1)1 {
                    loc g = `i' - 1
                    loc `stat' = "``stat'' `stat'_`where'_g`g' "
                }
            }
            // Generate line patterns - more solid to less solid as likelihood of ssa declines
            loc pattern = ""                
            forval i = 1/`spell' {
                if `i' == 1 loc pattern = "solid"
                if `i' == 2 loc pattern = "`pattern' longdash"
                if `i' == 3 loc pattern = "`pattern' dash"
                if `i' == 4 loc pattern = "`pattern' shortdash"
            }
            // Generate labels for legends
            if `spell' == 2 {
                local label "order(1 "1 Girl" 2 "1 Boy") cols(1) " 
                local title "Second Spell"
                local bi_title1 "25th/50th/75th Percentile" 
                local bi_title2 "Birth Intervals (months)"
                local sr_title1 "Sex Ratio" 
                local sr_title2 "(Percent Boys)"
                local pp_title1 "Probability of" 
                local pp_title2 "a Next Birth"
                if "`educ'" == "highest" {
                    local fxsize "fxsize(70)"
                }
                else {
                    local fxsize "fxsize(70)"
                }
            }
            else if `spell' == 3 {
                local label "order(1 "2 Girls" 2 "1 Boy/" "1 Girl" 3 "2 Boys") cols(2) span "
                local title "Third Spell"
                local bi_title1 ""
                local bi_title2 ""
                local sr_title1 "" 
                local sr_title2 ""
                local pp_title1 "" 
                local pp_title2 ""
//                 if "`educ'" == "highest" {
                    local fxsize    "fxsize(64)"
//                 }
            } 
            else if `spell' == 4 {
                local label "order(1 "3 Girls" 2 "1 Boy/" "2 Girls" 3 "2 Boys/" "1 Girl" 4 "3 Boys") cols(2) span "
                local title "Fourth Spell"
                local bi_title1 ""
                local bi_title2 ""
                local sr_title1 "" 
                local sr_title2 ""
                local pp_title1 "" 
                local pp_title2 ""
//                 if "`educ'" == "highest" {
                    local fxsize    "fxsize(64)"
//                     }
            }

            // Scales by education level
            loc spacing_low  = 18
            loc spacing_high = 72
//             if "`educ'" == "highest" {
//                 loc spacing_high = 45
//             }
            
            loc sr_low  = 40
            loc sr_high = 70
            if "`educ'" == "highest" {
                loc sr_low  = 30
                loc sr_high = 80            
            }
            
//             if "`educ'" == "highest" & `spell' == 3 & "`where'" == "urban" {
//                 loc position = 10
//             }
//             else {
//                 loc position = 7
//             }
            
            twoway line `p25' c1, sort  ///
                lpattern(`pattern') lwidth(medthin..) lcolor(black...) ///
                 || ///
            line `p50' c1, sort  ///
                lpattern(`pattern') lwidth(medthin..) lcolor(black...) ///
                 || ///
            line `p75' c1, sort  ///
                lpattern(`pattern') lwidth(medthin..) lcolor(black...) ///
                 || ///
                 , name(interval_`spell', replace) ///
                 title(`title', size(medium)) ///
                 legend(`label' symxsize(*1) size(small) linegap(0.75) ring(1) position(12) region(margin(vsmall) lwidth(none)) colgap(1.5) keygap(0.5) symysize(6.5) forcesize) ///
                 ytitle("`bi_title1'" "`bi_title2'") yscale(r(`spacing_low' `spacing_high')) ///
                 ylabel(`spacing_low'(6)`spacing_high' ,grid)  ///
                 plotregion(style(none)) xscale(off) ///
                 fysize(120) `fxsize'

            
            twoway line `pct' c1, sort ///
                lpattern(`pattern') lwidth(medthin..) lcolor(black...) ///
                legend(off) plotregion(style(none)) xscale(off) ///
                ytitle("`sr_title1'" "`sr_title2'") yscale(r(`sr_low' `sr_high')) ylabel(`sr_low'(10)`sr_high', grid) ///
                yline(51.2195122) ///
                name(pct_`spell', replace) fysize(60) `fxsize'

            twoway line `any' c1, sort ///
                lpattern(`pattern') lwidth(medthin..) lcolor(black...) ///
                legend(off) ///
                plotregion(style(none)) ///
                xtitle("") ///
                xlabel(1 `" "1972-" "1984" "' 2 `" "1985-" "1994" "' 3 `" "1995-" "2004" "' 4 `" "2005-" "2016" "') ///
                ytitle("`pp_title1'" "`pp_title2'") yscale(range(0 1)) ylabel(0.25(0.25)1, grid) ///
                name(any_`spell', replace) fysize(80) `fxsize'

//                 legend(`label' symxsize(*.95) size(small) ring(0) position(`position') region(margin(vsmall) lwidth(none)) colgap(2) keygap(0.5) forcesize) ///



//             gr combine interval pct any , ///
//                 iscale(1.4) col(1) xcommon imargin(0 2 1 1) ysize(12) 
// 
//             graph export `figures'/bs_spell`spell'_`educ'_`where'_all.eps, replace fontface(Palatino) 

            // To account for differences in number of spells covered
            // Stata graph combine does not support wildcards
            loc gr_interval "`gr_interval' interval_`spell'"
            loc gr_pct      "`gr_pct' pct_`spell'"
            loc gr_any      "`gr_any' any_`spell'"

        }

        // Combine by variable across spells first, then combine all variables    
        gr combine `gr_interval' , /// 
            row(1) ycommon name(interval, replace) fysize(70) imargin(0 2 0 0)
    
        gr combine `gr_pct' , ///
            row(1) ycommon  name(pct, replace) fysize(25) imargin(0 2 0 0)
    
        gr combine `gr_any' , ///
            row(1) ycommon  name(any, replace) fysize(32) imargin(0 2 0 0)

        gr combine interval pct any  , ///
            col(1) xcommon ysize(9) xsize(6.5) imargin(0 0 3 0) iscale(*1.2)
    
        graph export `figures'/bs_`educ'_`where'.eps, replace fontface(Palatino) 

    }
    
}
