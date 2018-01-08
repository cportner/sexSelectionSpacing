// Table of spell lengths with bootstrapped standard errors

version 13.1
clear all

loc num_reps = 10
file close _all // easier, in case something went wrong with last file write (Stata does not close files gracefully)

// Weird Stata behavior; you can write my_matrix[1,2], but not my_matrix[1,"var_name"]
// when you want to extract a scalar.
// Need to get col number first using variable name, then call matrix (grumble, grumble)
// program that takes a matrix and a name and returns the column number
capture program drop _all
program find_col, rclass
    version 13
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

// Generic set of locations
loc rawdata "../rawData"
loc data    "../data"
loc figures "../figures"
loc tables  "../tables"


// Load bootstrap results and create matrices.
foreach educ in "low" "med" "high" {
    forvalues spell = 1/4 {
        forvalues period = 1/3 {
        
            // Load bootstrap generated data and call bstat to replay results
            clear results // Stupid Stata - calling bstat after using the data does not clear old bstat
            use `data'/bs_s`spell'_g`period'_`educ', clear
            quietly bstat
            
            // Relevant matrices to extract
            // point estimates e(b)
            matrix b_s`spell'_g`period'_`educ' = e(b)
            // standard errors e(se)
            matrix se_s`spell'_g`period'_`educ' = e(se)
            // Number of observations - assumes implicitly that all have the
            // same number of repetitions; last run will be used. In practice
            // this should not be a problem as long as all within an education
            // group are run at the same time using the an_bootstrap file.
            loc num_reps = e(N_reps)            
        }        
    }
}


// Loop over education
foreach educ in "low" "med" "high" {

    if "`educ'" == "low" {
        loc char "No Education"
    }
    if "`educ'" == "med" {
        loc char "1 to 7 Years of Education"
    }
    if "`educ'" == "high" {
        loc char "8 or More Years of Education"
    }

    file open table using `tables'/bootstrap_duration_sex_ratio_`educ'.tex, write replace
    file write table "\begin{table}[hp!]" _n
    file write table "\begin{center}" _n
    file write table "\begin{scriptsize}" _n
    file write table "\begin{threeparttable}" _n
    file write table "\caption{Estimated Median Duration and Sex Ratio for Women with `char'}" _n
    file write table "\label{tab:median_sex_ratio_`educ'}" _n
    file write table "\begin{tabular}{@{} c l D{.}{.}{2.0} D{.}{.}{2.1}  D{.}{.}{2.0} D{.}{.}{2.1} D{.}{.}{2.0}  D{.}{.}{2.1}  @{}}" _n
    file write table "\toprule" _n
    file write table "                   &                            & \mct{1972-1984}                 &\mct{1985-1994}                  & \mct{1995-2006}                         \\ \cmidrule(lr){3-4} \cmidrule(lr){5-6} \cmidrule(lr){7-8}" _n
    file write table "                   & \mco{Composition of}       & \mco{Duration\tnote{a}}  & \mco{Percent\tnote{b}} & \mco{Duration\tnote{a}}  & \mco{Percent\tnote{b}} & \mco{Duration\tnote{a}}  & \mco{Percent\tnote{b}}         \\ " _n
    file write table " \mco{Spell}       & \mco{Prior Children}       & \mco{(Months)}  & \mco{Boys}    & \mco{(Months)}  & \mco{Boys}    & \mco{(Months)}  & \mco{Boys}            \\ \midrule" _n

    // Loop over area
    foreach where in "Urban" "Rural" {
        if "`where'" == "Urban" {
            loc area = "urban"
        }
        if "`where'" == "Rural" {
            loc area = "rural"
        }
        file write table " &  & \multicolumn{6}{c}{`where'} \\" _n

        forvalues spell = 1/4 {
            
            // Double the lines to allow for both statistics and standard errors
            local double = 2 * `spell' - 1
            if `spell' == 1 {
                local double = `double' + 1
            }
            file write table "\multirow[c]{`double'}{*}{`spell'} "

            forvalues prior = 1/`spell' {

                // Number of girls in prior spell and part of column name
                loc girls = `spell' - `prior'
                loc part_col_name "_`area'_g`girls'"
                
                // Conditions for sex composition to call matrix values
                if `spell' == 1 {
                        file write table _col(20) "&                            "
                } 
                if `spell' == 2 {
                    if `prior' == 1 {
                        file write table _col(20) "& \mco{One girl}             "
                    }
                    if `prior' == 2 {
                        file write table _col(20) "& \mco{One boy}              "
                    }    
                }
                if `spell' == 3 {
                    if `prior' == 1 {
                        file write table _col(20) "& \mco{Two girls}            "
                    }
                    if `prior' == 2 {
                        file write table _col(20) "& \mco{One boy / one girl}   "
                    }    
                    if `prior' == 3 {
                        file write table _col(20) "& \mco{Two boys}             "
                    }    
                }
                if `spell' == 4 {
                    if `prior' == 1 {
                        file write table _col(20) "& \mco{Three girls}          "
                    }
                    if `prior' == 2 {
                        file write table _col(20) "& \mco{One boy / two girls}  "
                    }    
                    if `prior' == 3 {
                        file write table _col(20) "& \mco{Two boys / one girl}  "
                    }    
                    if `prior' == 4 {
                        file write table _col(20) "& \mco{Three boys}           "
                    }    
                }


                // Loop over both estimates and standard errors
                foreach type in b se {
                
                    // move in enough to match up with first line
                    if "`type'" == "se" {
                        file write table _col(20) "&                            "
                    }
                    
                    // Loop over periods
                    forvalues period = 1/3 {
                                       
                        // loop over statistics (p50 and pct here)
                        foreach stats in p50 pct {
                    
                            // Format 
                            if "`stats'" == "pct" {
                                local stat_format = "%3.1fc"
                            }
                            else {
                                local stat_format = "%3.1fc"                        
                            }

                            // Find column number for matrix 
                            local full_name = "`stats'`part_col_name'"                    
                            find_col `type'_s`spell'_g`period'_`educ' `full_name'
                
                            // Add results to table  
                            file write table "&   " 
                            if "`type'" == "se" {
                                file write table " ("
                            }
                            else {
                                file write table " "
                            }
                            file write table `stat_format' (`type'_s`spell'_g`period'_`educ'[1,`r(col_num)'])        
                            if "`type'" == "se" {
                                file write table ")"
                            }
                            else {
                                file write table " "
                            }
                            file write table "      " 
                        }
                
                    }
                    file write table " \\" _n
                }            
            }
            file write table "\addlinespace " _n
        }
    }

    // Table endnotes
    file write table "\bottomrule" _n
    file write table "\end{tabular}" _n
    file write table "\begin{tablenotes} \tiny" _n
    file write table "\item \hspace*{-0.5em} \textbf{Note.}" _n
    file write table "The statistics for each spell/period combination are calculated based on the regression" _n
    file write table "model for that combination as described in the main text, using bootstrapping to find the " _n
    file write table "standard errors shown in parentheses. " _n
    file write table "For bootstrapping, the original sample is resampled, the regression model run on the " _n
    file write table "resampled data, and the statistics calculated. " _n
    file write table "This process is repeated `num_reps' times and the standard errors calculated." _n
    
    file write table "\item[a] " _n
    file write table "Median duration is calculated as follows." _n
    file write table "For each woman in a given spell/period combination sample, I calculate the time point" _n
    file write table "at which there is a 50\% chance that she will have given birth, conditional on the " _n
    file write table "probability that she will eventually give birth in that spell." _n
    file write table "For example, if there is an 80\% chance that a woman will give birth by the end of the" _n
    file write table "spell, her median duration is the predicted number of months before she passes the 40\% " _n
    file write table "mark on her survival curve." _n
    file write table "The reported statistics is the average of this median duration across all women in a given sample." _n 
    file write table "Duration begins at marriage for spell 1 or at 9 months after the birth of the prior child " _n
    file write table "for all other spells." _n

    file write table "\item[b] " _n
    file write table "Percent boys is calculated as follows." _n
    file write table "For each woman in a given spell/period combination sample, I calculate the predicted" _n
    file write table "percent boys for each month and sum this across the length of the spell using the" _n
    file write table "likelihood of having a child in each month as the weight. " _n
    file write table "The individual percent boys is then averaged across all women in the given sample." _n
    file write table "The result is the predicted percent boys that will be born to women in the sample once " _n
    file write table "child bearing for that spell is over." _n

    file write table "\end{tablenotes}" _n
    file write table "\end{threeparttable}" _n
    file write table "\end{scriptsize}" _n
    file write table "\end{center}" _n
    file write table "\end{table}" _n

    file close table

}




