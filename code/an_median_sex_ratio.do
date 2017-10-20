// Tables on median duration and sex ratios

version 13.1
clear all

// Generic set of locations
loc rawdata "../rawData"
loc data    "../data"
loc figures "../figures"
loc tables  "../tables"

file close _all

/////////////////////////////////////////////////
// Tables                                      //
/////////////////////////////////////////////////

file open table using `tables'/median_sex_ratio.tex, write replace
file write table "\begin{table}[htbp]" _n
file write table "\begin{center}" _n
file write table "\begin{small}" _n
file write table "\begin{threeparttable}" _n
file write table "\caption{Estimated Median Duration and Sex Ratio}" _n
file write table "\label{tab:median_sex_ratio_high}" _n
file write table "\begin{tabular}{@{} l l D{.}{.}{2.0} D{.}{.}{2.1}  D{.}{.}{2.0} D{.}{.}{2.1} D{.}{.}{2.0}  D{.}{.}{2.1}  @{}}" _n
file write table "\toprule" _n
file write table "                   & \mco{Sex}                  & \mct{1972-1984}                &\mct{1985-1994}                 & \mct{1995-2006}                        \\ \cmidrule(lr){3-4} \cmidrule(lr){5-6} \cmidrule(lr){7-8}" _n
file write table " \mco{Spell}       & \mco{Composition}          & \mco{Duration}  & \mco{\% Boys} & \mco{Duration}  & \mco{\% Boys} & \mco{Duration}  & \mco{\% Boys}         \\ \midrule" _n

// need to loop over area as well
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
                use `data'/spell`spell'_g`period'_high , clear
                gen months = t * 3

                //-----------------------------//
                // Percentage boys             //
                //-----------------------------//

                // probability of kid
                gen     prob_kid = 1 - s if t == 1
                replace prob_kid = s[_n-1] - s[_n] if t != 1

                // Sons born
                gen ratio_sons = pcbg * prob_kid
                bysort id (t): egen num_sons = total(ratio_sons)
                bysort id (t): gen  pct_sons = (num_sons / (1 - s[_N])) * 100

                //----------------------------------------------------//
                // Median duration conditional on parity progression  //
                //----------------------------------------------------//

                bysort id (t): gen below = pps < 0.5
                gen median = int(months - ((0.5 - pps) / (pps[_n-1] - pps)) * 3) if below & !below[_n-1] 

                // Add results to table
                sum median `sexcomp'
                file write table "& \mco{" %2.0fc (`r(mean)') "} "
                sum pct_sons `sexcomp'
                file write table "& \mco{" %3.1fc (`r(max)') "}  "
            }
            file write table " \\" _n
        }
        file write table "\addlinespace " _n
    }
}
file close table


