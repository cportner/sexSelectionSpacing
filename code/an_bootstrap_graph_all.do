// Experimental graph generation for bootstrap results

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
foreach educ in "low" "med" "high" {
    forvalues spell = 2/4 {
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
 
foreach educ in "low" "med" "high" {
    forvalues spell = 2/4 {

        // Set up data from matrix
        clear // Needed because we are generating new data sets based on matrices in svmat below
        matrix tmp_mat = (1, b_s`spell'_g1_`educ' \ 2, b_s`spell'_g2_`educ' \ 3, b_s`spell'_g3_`educ' \  4, b_s`spell'_g4_`educ')
        svmat tmp_mat, names( col )
        
        foreach where in "urban" "rural" {
            // Generate y variables in reverse order to match line pattern
            foreach stat in "avg" "pct" "any" {
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
            
            twoway line `avg' c1, sort  ///
                lpattern(`pattern') lwidth(medthick..) lcolor(black...) ///
                legend(off) plotregion(style(none)) xscale(off) ///
                ytitle("Expected Spacing" "(months)") yscale(r(15 45)) ylabel(15(10)45 ,grid) ///
                name(p50, replace)  fysize(80)

            twoway line `pct' c1, sort ///
                lpattern(`pattern') lwidth(medthick..) lcolor(black...) ///
                legend(off) plotregion(style(none)) xscale(off) ///
                ytitle("Sex Ratio" "(Percent Boys)") yscale(r(45 75)) ylabel(45(10)75, grid) ///
                yline(51.2195122) ///
                name(pct, replace) fysize(80)

            twoway line `any' c1, sort ///
                lpattern(`pattern') lwidth(medthick..) lcolor(black...) ///
                legend(off) plotregion(style(none)) ///
                xtitle("") ///
                xlabel(1 `" "1972-" "1984" "' 2 `" "1985-" "1994" "' 3 `" "1995-" "2004" "' 4 `" "2005-" "2016" "') ///
                ytitle("Probability of" "a Next Birth") yscale(range(0 1)) ylabel(0.25(0.25)1, grid) ///
                name(any, replace) fysize(100)

            gr combine p50 pct any , ///
                iscale(1.7) col(1) xcommon imargin(0 2 1 1) ysize(12) 

            graph export `figures'/bs_spell`spell'_`educ'_`where'_all.eps, replace fontface(Palatino) 

        }
        
    }
}
