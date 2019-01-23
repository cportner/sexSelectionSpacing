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
    forvalues region = 1/4 {
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

clear // Needed because we are generating new data sets based on matrices in svmat below

// Matrix of results by period 
matrix r1_s4_high = (1, b_s4_g1_high_r1 \ 2, b_s4_g2_high_r1 \ 3, b_s4_g3_high_r1 \  4, b_s4_g4_high_r1)
svmat r1_s4_high, names( col )

twoway line p50_urban_g3 c1, sort  legend(label(1 "3 girls")) lpattern(solid) lwidth(medthick..) lcolor(black) ///
    || line p50_urban_g2 c1, sort  legend(label(2 "2 girls")) lpattern(dash) lwidth(medthick..) lcolor(black) ///
    || line p50_urban_g1 c1, sort  legend(label(3 "1 girl")) lpattern(shortdash) lwidth(medthick..) lcolor(black) ///
    || line p50_urban_g0 c1, sort  legend(label(4 "0 girls")) lpattern(dash_dot) lwidth(medthick..) lcolor(black) 


