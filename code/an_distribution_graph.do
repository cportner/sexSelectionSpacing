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
    forvalues spell = 2/4 {

		// Do not run the fourth spell for the highest education group; too few obs in the earlier years
		if "`educ'" == "highest" & `spell' == 4 {
			continue
		}
            
        // Set up data from matrix
        clear // Needed because we are generating new data sets based on matrices in svmat below
        matrix tmp_mat = (1, b_s`spell'_g1_`educ' \ 2, b_s`spell'_g2_`educ' \ 3, b_s`spell'_g3_`educ' \  4, b_s`spell'_g4_`educ')
        svmat tmp_mat, names( col )
        
        foreach where in "urban" "rural" {
            // Generate y variables in reverse order to match line pattern
            // p25 is 25% left (75th percentile)
            foreach stat in "p25" "p50" "p75" "avg" {  
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
                local label "label(1 1 Girl) label(2 1 Boy) cols(1) " 
            }
            else if `spell' == 3 {
                local label "label(1 2 Girls) label(2 1 Boy, 1 Girl) label(3 2 Boys) cols(2) "
            } 
            else if `spell' == 4 {
                local label "label(1 3 Girls) label(2 1 Boy, 2 Girls) label(3 2 Boys, 1 Girl) label(4 3 Boys) cols(2) "
            }
    
            if "`educ'" == "low" {
                local set_label "`label'  ring(0) position(10) region(margin(vsmall))"
            } 
            else {
                local set_label "off"
            }

            // 75th percentile
            loc spacing_low  = 30
            loc spacing_high = 70

            twoway line `p25' c1, sort  ///
                lpattern(`pattern') lwidth(medthick..) lcolor(black...) ///
                legend(`set_label') /// 
                plotregion(style(none)) ///
                xtitle("") ///
                xlabel(1 `" "1972-" "1984" "' 2 `" "1985-" "1994" "' 3 `" "1995-" "2004" "' 4 `" "2005-" "2016" "') ///
                ytitle("75th Percentile Spacing" "(months)") yscale(r(`spacing_low' `spacing_high')) ylabel(`spacing_low'(6)`spacing_high' ,grid) ///
                fysize(80)

            graph export `figures'/p75_spell`spell'_`educ'_`where'.eps, replace fontface(Palatino) 
            
            // 50th percentile
            loc spacing_low  = 24
            loc spacing_high = 48
                                    
            twoway line `p50' c1, sort  ///
                lpattern(`pattern') lwidth(medthick..) lcolor(black...) ///
                legend(`set_label') /// 
                plotregion(style(none)) ///
                xtitle("") ///
                xlabel(1 `" "1972-" "1984" "' 2 `" "1985-" "1994" "' 3 `" "1995-" "2004" "' 4 `" "2005-" "2016" "') ///
                ytitle("50th Percentile Spacing" "(months)") yscale(r(`spacing_low' `spacing_high')) ylabel(`spacing_low'(6)`spacing_high' ,grid) ///
                fysize(80)
            
            graph export `figures'/p50_spell`spell'_`educ'_`where'.eps, replace fontface(Palatino) 
            

            // 25th percentile
            loc spacing_low  = 12
            loc spacing_high = 36

            twoway line `p75' c1, sort  ///
                lpattern(`pattern') lwidth(medthick..) lcolor(black...) ///
                legend(`set_label') /// 
                plotregion(style(none)) ///
                xtitle("") ///
                xlabel(1 `" "1972-" "1984" "' 2 `" "1985-" "1994" "' 3 `" "1995-" "2004" "' 4 `" "2005-" "2016" "') ///
                ytitle("25th Percentile Spacing" "(months)") yscale(r(`spacing_low' `spacing_high')) ylabel(`spacing_low'(6)`spacing_high' ,grid) ///
                fysize(80)

            graph export `figures'/p25_spell`spell'_`educ'_`where'.eps, replace fontface(Palatino) 


            // Average
            loc spacing_low  = 30
            loc spacing_high = 54

            twoway line `avg' c1, sort  ///
                lpattern(`pattern') lwidth(medthick..) lcolor(black...) ///
                legend(`set_label') /// 
                plotregion(style(none)) ///
                xtitle("") ///
                xlabel(1 `" "1972-" "1984" "' 2 `" "1985-" "1994" "' 3 `" "1995-" "2004" "' 4 `" "2005-" "2016" "') ///
                ytitle("Expected Spacing" "(months)") yscale(r(`spacing_low' `spacing_high')) ylabel(`spacing_low'(5)`spacing_high' ,grid) ///
                fysize(80)

            graph export `figures'/avg_spell`spell'_`educ'_`where'.eps, replace fontface(Palatino) 




            // Combined 25th and 75th percentile
                        
            // Generate labels for legends
            if `spell' == 2 {
                local order "order(1 "1 Girl" 2 "1 Boy") cols(1) " 
            }
            else if `spell' == 3 {
                local order "order(1 "2 Girls" 2 "1 Boy, 1 Girl" 3 "2 Boys") cols(2) "
            } 
            else if `spell' == 4 {
                local order "order(1 "3 Girls" 2 "1 Boy, 2 Girls" 3 "2 Boys, 1 Girl" 4 "3 Boys") cols(2) "
            }

            if "`educ'" == "low" {
                local set_label "`order'  ring(0) position(10) region(margin(vsmall))"
            } 
            else {
                local set_label "off"
            }
            
            loc spacing_low  = 16
            loc spacing_high = 72

            twoway line `p25' c1, sort  ///
                lpattern(`pattern' ) lwidth(medthick..) lcolor(black...) ///
                plotregion(style(none)) ///
                xtitle("") ///
                xlabel(1 `" "1972-" "1984" "' 2 `" "1985-" "1994" "' 3 `" "1995-" "2004" "' 4 `" "2005-" "2016" "') ///
                ytitle("25th and 75th Percentile Spacing" "(months)") yscale(r(`spacing_low' `spacing_high')) ylabel(`spacing_low'(6)`spacing_high' ,grid) ///
                fysize(80) ///
                 || ///
            line `p75' c1, sort  ///
                lpattern(`pattern') lwidth(medthick..) lcolor(black...) ///
                plotregion(style(none)) ///
                xtitle("") ///
                xlabel(1 `" "1972-" "1984" "' 2 `" "1985-" "1994" "' 3 `" "1995-" "2004" "' 4 `" "2005-" "2016" "') ///
                ytitle("25th and 75th Percentile Spacing" "(months)") yscale(r(`spacing_low' `spacing_high')) ylabel(`spacing_low'(6)`spacing_high' ,grid) ///
                 || ///
                 , legend(`set_label') /// 

            graph export `figures'/combined_p25_p75_spell`spell'_`educ'_`where'.eps, replace fontface(Palatino) 

        }
        
    }
}
