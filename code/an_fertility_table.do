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
file write table "\begin{scriptsize}" _n
file write table "\begin{threeparttable}" _n
file write table "\caption{Predicted Fertility based on Fertility Rate and on Hazard Model}" _n
file write table "\label{tab:fertility}" _n
file write table "\begin{tabular}{@{} l D{.}{.}{2.2} D{.}{.}{2.2} D{.}{.}{2.2} D{.}{.}{2.2}  @{}}" _n
file write table "\toprule" _n
file write table "                   & \mco{NFHS--1}   & \mco{NFHS--2}   & \mco{NFHS--3}   & \mco{NFHS--4}   \\" _n
file write table "                   & \mco{1992--93}  & \mco{1998--99}  & \mco{2005}      & \mco{NFHS--4}   \\" _n
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
    file write table " & \multicolumn{4}{c}{`where'} \\ \cmidrule(lr){2-5}" _n

    foreach educ in "low" "med" "high" {

        if "`educ'" == "low" {
            loc char "No Education"
            loc educ_val = 1
        }
        if "`educ'" == "med" {
            loc char "One to Seven Years of Education"
            loc educ_val = 2
        }
        if "`educ'" == "high" {
            loc char "Eight or More Years of Education"
            loc educ_val = 3
        }

        // Education group 
        file write table " & \multicolumn{4}{c}{`char'} \\" _n

        // Get "TFR"
        file write table "TFR\tnote{a}       "
        forvalues round = 1/4 {
            use `data'/predicted_tfr_round_`round'.dta, clear
            sum(tfr_3yr) if urban == `area_val' & edu_group == `educ_val'
            loc result = `r(mean)'
            file write table "&      " %3.2fc (`result') "       "
        }
        file write table "\\" _n
        
        // Hazard prediction
        file write table "Model\tnote{b}     "
        forvalues round = 1/4 {
            use `data'/predicted_fertility_hazard_g`round'_`educ'_r`round'.dta
            sum(pred_fertility) if urban == `area_val'
            loc result = `r(mean)'
            file write table "&      " %3.2fc (`result') "       "
        }
        file write table "\\" _n
        file write table "\addlinespace " _n
    }
    
}    

// Table endnotes
file write table "\bottomrule" _n
file write table "\end{tabular}" _n
file write table "\begin{tablenotes} \tiny" _n
file write table "\item \hspace*{-0.5em} \textbf{Note.}" _n
file write table "All predictions based on births up to and including parity four births" _n
file write table "for both \`\`Total Fertility Rate'' and model predictions." _n
file write table "NFHS-1 was collected 1992--93 and model results for 1972--1984 were" _n
file write table "applied for the predictions." _n
file write table "NFHS-2 was collected 1998--99 and model results for 1985--1994 were" _n
file write table "applied for the predictions." _n
file write table "NFHS-3 was collected 2005--06 and model results for 1995--2004 were" _n
file write table "applied for the predictions." _n
file write table "NFHS-4 was collected 2015--16 and model results for 2005--2016 were" _n
file write table "applied for the predictions." _n

file write table "\item[a] " _n
file write table "TFR is based on five-year age groups counting births that occurred 1 to" _n
file write table "36 months before the survey months." _n
file write table "For NFHS-1 and NFHS-2 the total number of women in the five-year age" _n
file write table "groups is based on the household roster since only ever-married women" _n
file write table "are in the individual recode sample." _n
file write table "For NFHS-3 and NFHS-4 the total number of women is based on the individual" _n
file write table "recode sample since all women were interviewed." _n

file write table "\item[b] " _n
file write table "The model predictions for fertility are the average predicted fertility" _n
file write table "across all women in a given sample, using their age of marriage as the" _n
file write table "starting point and adding two years for each spell." _n
file write table "Observed fertility is not taken into account for the predictions." _n
file write table "For each spell, the predicted probability is the likelihood of having a" _n
file write table "next birth given sex composition multiplied with probability of that" _n
file write table "sex composition and the likelihood of getting to the spell." _n

file write table "\end{tablenotes}" _n
file write table "\end{threeparttable}" _n
file write table "\end{scriptsize}" _n
file write table "\end{center}" _n
file write table "\end{table}" _n

file close table

   
