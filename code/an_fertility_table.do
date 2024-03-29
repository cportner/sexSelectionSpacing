// Table of TFR and predicted cohort fertility
// Depends on results from an_fertility_hazard_predict and an_fertility_rate.do

version 15.1
clear all

file close _all // easier, in case something went wrong with last file write (Stata does not close files gracefully)

include directories

// Table of TFR and fertility predictions

file open table using `tables'/fertility.tex, write replace

file write table "\begin{table}[hp!]" _n
file write table "\begin{center}" _n
file write table "\begin{footnotesize}" _n
file write table "\begin{threeparttable}" _n
file write table "\caption{Four-parity fertility rate versus predicted cohort fertility based on hazard model}" _n
file write table "\label{tab:fertility}" _n
file write table "\begin{tabular}{@{} l D{.}{.}{2.2} D{.}{.}{2.2} D{.}{.}{2.2} D{.}{.}{2.2} D{.}{.}{2.2}  @{}}" _n
file write table "\toprule" _n
file write table "                       &            \mct{NFHS--1}          & \mco{NFHS--2}   & \mco{NFHS--3}   & \mco{NFHS--4}   \\" _n
file write table "Fertility Rate Period  & \mco{1987--1988}  & \mco{1992--1993}  & \mco{1998--1999}  & \mco{2005--2006}  & \mco{2015--2016}  \\" _n
file write table "Hazard Model Period    & \mco{1972--1984}  &                 & \mco{1985--1994}  & \mco{1995--2004}  & \mco{2004--2016}  \\" _n
file write table "\midrule" _n

// Loop over area
foreach where in "Urban" "Rural" {
    if "`where'" == "Urban" {
        loc area = "urban"
        loc area_val = 1
    }
    if "`where'" == "Rural" {
        loc area = "rural"
        loc area_val = 0
    }
    file write table " & \multicolumn{5}{c}{`where'} \\ \cmidrule(lr){2-6}" _n

    foreach educ in "low" "med" "high" "highest" {

        if "`educ'" == "low" {
            loc char "No Education"
            loc educ_val = 1
        }
        if "`educ'" == "med" {
            loc char "1--7 Years of Education"
            loc educ_val = 2
        }
        if "`educ'" == "high" {
            loc char "8--11 Years of Education"
            loc educ_val = 3
        }
        if "`educ'" == "highest" {
            loc char "12 or More Years of Education"
            loc educ_val = 4
        }

        // Education group 
        file write table " & \multicolumn{5}{c}{`char'} \\" _n

        // Get "TFR"
        file write table "Fertility Rate\tnote{a}   "
        // Early TFR numbers
        use `data'/predicted_tfr_round_1.dta, clear
        sum(prior_tfr_3yr) if urban == `area_val' & edu_group == `educ_val'
        loc result = `r(mean)'
        file write table "&      " %3.2fc (`result') "       "
        forvalues round = 1/4 {
            use `data'/predicted_tfr_round_`round'.dta, clear
            sum(tfr_3yr) if urban == `area_val' & edu_group == `educ_val'
            loc result = `r(mean)'
            file write table "&      " %3.2fc (`result') "       "
        }
        file write table "\\" _n
        
        // Hazard prediction
        file write table "Hazard Model\tnote{b}     "
        forvalues round = 1/4 {            
//             # Estimation results for highest education group in the 1972-84 period unreliable
//             # because of too small sample size
//             if `round' == 1 & "`educ'" == "highest" {
//                 file write table "&        .        &                 "
//                 continue
//             }
            use `data'/predicted_fertility_hazard_g`round'_`educ'_r`round'.dta
            sum(pred_fertility) if urban == `area_val'
            loc result = `r(mean)'
            file write table "&      " %3.2fc (`result') "       "
            if `round' == 1 {
                        file write table "&                 "
            }
        }
        file write table "\\" _n
        file write table "\addlinespace " _n
    }
    
}    

// Table endnotes
file write table "\bottomrule" _n
file write table "\end{tabular}" _n
file write table "\begin{tablenotes} \scriptsize" _n
file write table "\item \hspace*{-0.5em} \textbf{Note.}" _n
file write table "All predictions based on births up to and including parity four births" _n
file write table "for both fertility rate and model predictions." _n
file write table "NFHS-1 was collected in 1992--1993, and model results for 1972--1984 were" _n
file write table "applied for the predictions." _n
file write table "NFHS-2 was collected in 1998--1999, and model results for 1985--1994 were" _n
file write table "applied for the predictions." _n
file write table "NFHS-3 was collected in 2005--2006, and model results for 1995--2004 were" _n
file write table "applied for the predictions." _n
file write table "NFHS-4 was collected in 2015--2016, and model results for 2005--2016 were" _n
file write table "applied for the predictions." _n

file write table "\item[a] " _n
file write table "The fertility rate is based on five-year age groups, counting births that " _n
file write table "occurred 1--36 months before the survey months." _n
file write table "For NFHS-1 and NFHS-2, the total number of women in the five-year age" _n
file write table "groups is based on the household roster because only ever-married women" _n
file write table "are in the individual recode sample." _n
file write table "For NFHS-3 and NFHS-4, the total number of women is based on the individual" _n
file write table "recode sample because all women were interviewed." _n

file write table "\item[b] " _n
file write table "The model predictions for fertility are the average predicted fertility" _n
file write table "across all women in a given sample, using their age of marriage as the" _n
file write table "starting point and adding three years for each spell." _n
file write table "Observed births are not taken into account for the predictions." _n
file write table "For each spell, the predicted probability is the likelihood of having a" _n
file write table "next birth given sex composition multiplied with the probability of that" _n
file write table "sex composition and the likelihood of getting to the spell," _n
file write table "corrected for the probability of sterilization." _n


file write table "\end{tablenotes}" _n
file write table "\end{threeparttable}" _n
file write table "\end{footnotesize}" _n
file write table "\end{center}" _n
file write table "\end{table}" _n

file close table

   
