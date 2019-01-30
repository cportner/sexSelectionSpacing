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
// foreach educ in "low" "med" "high" {
foreach educ in "high" {
//     forvalues region = 1/4 {
    forvalues region = 1/1 {
        forvalues spell = 1/4 {
            forvalues period = 1/4 {
        
                // Load bootstrap generated data and call bstat to replay results
                clear results // Stupid Stata - calling bstat after using the data does not clear old bstat
                use `data'/bs_s`spell'_g`period'_`educ'_r`region', clear
                quietly bstat
            
                // Relevant matrices to extract
                // point estimates e(b)
                matrix b_s`spell'_g`period'_`educ'_r`region' = e(b)
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
}



set scheme s1mono


// Matrix of results by period 
clear // Needed because we are generating new data sets based on matrices in svmat below
matrix r1_s4_high = (1, b_s4_g1_high_r1 \ 2, b_s4_g2_high_r1 \ 3, b_s4_g3_high_r1 \  4, b_s4_g4_high_r1)
svmat r1_s4_high, names( col )

clear // Needed because we are generating new data sets based on matrices in svmat below
matrix r1_s3_high = (1, b_s3_g1_high_r1 \ 2, b_s3_g2_high_r1 \ 3, b_s3_g3_high_r1 \  4, b_s3_g4_high_r1)
svmat r1_s3_high, names( col )


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
 

twoway line p50_urban_g2 p50_urban_g1 p50_urban_g0 c1, sort  ///
    lpattern(solid longdash dash) lwidth(medthick..) lcolor(black...) ///
    legend(off) plotregion(style(none)) xscale(off) ///
    ytitle("Median Spacing" "(months)") yscale(r(15 45)) ylabel(15(10)45 ,grid) ///
    name(s3_p50, replace)  fysize(80)

twoway line pct_urban_g2 pct_urban_g1 pct_urban_g0 c1, sort ///
    lpattern(solid longdash dash) lwidth(medthick..) lcolor(black...) ///
    legend(off) plotregion(style(none)) xscale(off) ///
    ytitle("Sex Ratio" "(Percent Boys)") yscale(r(45 75)) ylabel(45(10)75, grid) ///
    yline(51.2195122) ///
    name(s3_pct, replace) fysize(80)

twoway line any_urban_g2 any_urban_g1 any_urban_g0 c1, sort ///
    lpattern(solid longdash dash) lwidth(medthick..) lcolor(black...) ///
    legend(off) plotregion(style(none)) ///
    xtitle("") ///
    xlabel(1 `" "1972-" "1984" "' 2 `" "1985-" "1994" "' 3 `" "1995-" "2004" "' 4 `" "2005-" "2016" "') ///
    ytitle("Probability of" "a Next Birth") yscale(range(0 1)) ylabel(0.25(0.25)1, grid) ///
    name(s3_any, replace) fysize(100)


gr combine s3_p50 s3_pct s3_any , ///
    iscale(1.7) col(1) xcommon imargin(0 2 1 1) ysize(12) 
    
graph export `figures'/bs_spell3_high_urban.eps, replace fontface(Palatino) 


