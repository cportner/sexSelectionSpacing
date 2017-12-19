// Table of spell lengths with bootstrapped standard errors

version 13.1
clear all

capture program drop _all
do bootspell.do
do baseline_hazards/bh_low.do
do baseline_hazards/bh_med.do
do baseline_hazards/bh_high.do


// Weird Stata behavior; you can write my_matrix[1,2], but not my_matrix[1,"var_name"]
// Need to get col number first using variable name, then call matrix (grumble, grumble)
// program that takes a matrix and a name and returns the column number
program find_col, rclass
    version 13
    args matrix name
    local col_names : colfullnames A
    tokenize `col_names'
    local i = 1
    local found = 0
    while "``i''" != "" & `found' == 0 {
        dis "`name'    ``i''  " 
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

use `data'/base

tempfile main low med high
save "`main'"

// Restricting sample and data manipulations

// foreach educ in "low" "med" "high" {
foreach educ in  "high" {

    use "`main'", clear

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
    
    save "``educ''" // Need double ` because the name that comes from educ is itself a local variable

    forvalues spell = 3/3 {
        use "``educ''" , clear
        if `spell' == 1 {
            global b1space ""
            loc girlvar ""
        } 
        else {
            loc girlvar " girl* "
        }
        run genSpell`spell'.do
        // need to have a way of setting up the required statistics
        loc stats = ""
        foreach where in "urban" "rural" {
            forvalues prior = 1/`spell' {
                loc girls = `spell' - `prior'
                // Remember p is percent left!!
                loc stats = "`stats' p75_`where'_g`girls' = r(p75_`where'_g`girls')"
                loc stats = "`stats' p50_`where'_g`girls' = r(p50_`where'_g`girls')"
                loc stats = "`stats' p25_`where'_g`girls' = r(p25_`where'_g`girls')"
                loc stats = "`stats' pct_`where'_g`girls' = r(pct_`where'_g`girls')"
            } 
        }
        forvalues group = 2/2 {
            preserve
            keep if group == `group'

            keep id b`spell'_space b`spell'_sex b`spell'_cen `girlvar' ///
                urban $b1space $parents $hh $caste // remove unnecessary variables to speed bootstrap
        
            // Bootstrapping
            bootstrap `stats' , reps(5) seed(100669) nowarn : bootspell `spell' `group' `educ'
      
            // Relevant matrices to extract
            // point estimates e(b)
            matrix b_s`spell'_g`group'_`educ' = e(b)
            // standard errors e(se)
            matrix se_s`spell'_g`group'_`educ' = e(se)
        
            restore
        }
    }
}

exit

// Table stuff here

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

    file open table using `tables'/median_sex_ratio_`educ'.tex, write replace
    file write table "\begin{table}[hp!]" _n
    file write table "\begin{center}" _n
    file write table "\begin{small}" _n
    file write table "\begin{threeparttable}" _n
    file write table "\caption{Estimated Median Duration and Sex Ratio for Women with `char'}" _n
    file write table "\label{tab:median_sex_ratio_`educ'}" _n
    file write table "\begin{tabular}{@{} l l D{.}{.}{2.0} D{.}{.}{2.1}  D{.}{.}{2.0} D{.}{.}{2.1} D{.}{.}{2.0}  D{.}{.}{2.1}  @{}}" _n
    file write table "\toprule" _n
    file write table "                   &                            & \mct{1972-1984}                 &\mct{1985-1994}                  & \mct{1995-2006}                         \\ \cmidrule(lr){3-4} \cmidrule(lr){5-6} \cmidrule(lr){7-8}" _n
    file write table "                   & \mco{Composition of}       & \mco{Duration}  & \mco{Percent} & \mco{Duration}  & \mco{Percent} & \mco{Duration}  & \mco{Percent}         \\ " _n
    file write table " \mco{Spell}       & \mco{Prior Children}       & \mco{(Months)}  & \mco{Boys}    & \mco{(Months)}  & \mco{Boys}    & \mco{(Months)}  & \mco{Boys}            \\ \midrule" _n

    // Loop over area
    foreach where in "Urban" "Rural" {
        if "`where'" == "Urban" {
            loc area = "urban"
        }
        if "`where'" == "Rural" {
            loc area = "!urban"
        }
        file write table " &  & \multicolumn{6}{c}{`where'} \\" _n

        forvalues spell = 1/4 {

            file write table "\multirow{`spell'}{*}{`spell'} "

            forvalues prior = 1/`spell' {

                // Conditions for sex composition
                if `spell' == 1 {
                    file write table _col(20)    "&                            "
                    loc  sexcomp " if `area' "
                } 
                if `spell' == 2 {
                    if `prior' == 1 {
                        file write table _col(20) "& \mco{One girl}             "
                        loc sexcomp " if girl & `area' "
                    }
                    if `prior' == 2 {
                        file write table _col(20) "& \mco{One boy}              "
                        loc sexcomp " if !girl & `area' "
                    }    
                }
                if `spell' == 3 {
                    if `prior' == 1 {
                        file write table _col(20) "& \mco{Two girls}            "
                        loc sexcomp " if girl2 & `area' "
                    }
                    if `prior' == 2 {
                        file write table _col(20) "& \mco{One boy / one girl}   "
                        loc sexcomp " if girl1 & `area' "
                    }    
                    if `prior' == 3 {
                        file write table _col(20) "& \mco{Two boys}             "
                        loc sexcomp " if !girl1 & !girl2 & `area' "
                    }    
                }
                if `spell' == 4 {
                    if `prior' == 1 {
                        file write table _col(20) "& \mco{Three girls}          "
                        loc sexcomp " if girl3 & `area' "
                    }
                    if `prior' == 2 {
                        file write table _col(20) "& \mco{One boy / two girls}  "
                        loc sexcomp " if girl2 & `area' "
                    }    
                    if `prior' == 3 {
                        file write table _col(20) "& \mco{Two boys / one girl}  "
                        loc sexcomp " if girl1 & `area' "
                    }    
                    if `prior' == 4 {
                        file write table _col(20) "& \mco{Three boys}           "
                        loc sexcomp " if !girl1 & !girl2 & !girl3 & `area' "
                    }    
                }



            
                // Loop over sex composition
                forvalues period = 1/3 {
                
                

                    // Add results to table
                    
                    // Need a loop over both estimates and standard errors
                    
                    
                    
                    
                    
                    file write table "& " %2.0fc ()
                    
                    
                    sum num_birth `sexcomp'
                    if `r(mean)' > 100 {
                    	if `r(mean)' <= 500 {
                    		loc low "^{\dagger}"
                    	}
                    	else {
                    		loc low "          "
                    	}
                        sum median `sexcomp'
                        file write table "& " %2.0fc (`r(mean)') "      "
                        sum pct_sons `sexcomp'
                        file write table "& " %3.1fc (`r(max)') "`low'     "
                    } 
                    else {
                        file write table "&    .    "
                        file write table "&    .     "                    
                    }
                }
                file write table " \\" _n
            }
            file write table "\addlinespace " _n
        }

    }

    // Table endnotes
    file write table "\bottomrule" _n
    file write table "\end{tabular}" _n
    file write table "\begin{tablenotes} \footnotesize" _n
    file write table "\item \hspace*{-0.5em} \textbf{Note.}" _n
    file write table "Predictions are based on the characteristics detailed in the main text." _n
    file write table "Duration is the predicted median number of months it takes for a woman to have a child," _n
    file write table "starting at marriage for spell 1 or at 9 months after the birth of the prior child for all other spells." _n
    file write table "The prediction is conditional on eventual parity progression." _n
    file write table "That is, if, say, 80 percent of women with the given set of characteristics are predicted to have a child" _n
    file write table "by the end of the spell, the median duration is the number of months it is predicted to take before 40 percent of women have had a child." _n
    file write table "Percent boys is the predicted percent of births that result in a son" _n
    file write table "for women with the given set of characteristics over the entire spell length used for estimations." _n
//     file write table "Predictions based on estimation of cells with 100 or fewer births are not shown." _n
//     file write table "\item[$\dagger$] Cell has 500 or fewer births in sample used for estimation. "
    file write table "\end{tablenotes}" _n
    file write table "\end{threeparttable}" _n
    file write table "\end{small}" _n
    file write table "\end{center}" _n
    file write table "\end{table}" _n

    file close table

}




