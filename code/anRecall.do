// Recall error estimations

version 13.1
clear all

include directories

/*-------------------------------------------------------------------*/
/* LOADING DATA AND CREATING NEW VARIABLES                           */
/*-------------------------------------------------------------------*/

use `data'/base

// survey information
gen survey = round // Round is now calculated in crBase.do

loc i = 88
forvalues k = 1/3 {
    gen b`k'_son = b`k'_sex == 1 if fertility >= `k'
    gen b`k'_born_year = int((b`k'_born_cmc-1)/12) if fertility >= `k'
    gen b`k'_born_year_2 = b`k'_born_year^2  / 100
    gen b`k'_after`i' = b`k'_born_year > `i'
    gen b`k'_mom_age_2 = b`k'_mom_age^2 / 100
}
gen mar_year = int((marriage_cmc-1)/12)+1900
gen mar_after`i' = mar_year > `i'

// local variables
loc caste    "scheduled_caste scheduled_tribe "
loc hh       "land_irr land_nir resid_large resid_small resid_town "
loc parents  "edu_mother* edu_father* "
loc region   "i.state "
loc region   " "


/*-------------------------------------------------------------------*/
/* DEVELOPMENT IN SEX RATIOS							             */
/*-------------------------------------------------------------------*/

// prepares data for analysis
//preserve
keep round survey urban mar_year observation_age* mom_id b*_sex b*_born_cmc
reshape long b@_sex b@_born_cmc, i(mom_id) j(bo)
drop if b_sex == .
gen born_year = int((b_born_cmc-1)/12)+1900
// drop if born_year < `startyear'
recode b_sex (2=0)

// generate categorical variable for 5 year groups
// first obs is born in 1954
egen yearGroupBirth = cut(born_year) , at(1950,1960(5)2010, 2017) 
egen yearGroupMarriage = cut(mar_year) , at(1950,1960(5)2010, 2017) 

label define years ///
    1950 "1950--1959" ///
    1960 "1960--1964" ///
    1965 "1965--1969" ///
    1970 "1970--1974" ///
    1975 "1975--1979" ///
    1980 "1980--1984" ///
    1985 "1985--1989" ///
    1990 "1990--1994" ///
    1995 "1995--1999" ///
    2000 "2000--2004" ///
    2005 "2005--2009" ///
    2010 "2010--2016"
    
label values yearGroupBirth yearGroupMarriage years

// // tabulate yearGroupBirth survey if bo < 3, sum(b_sex)
tabulate yearGroupBirth survey if bo < 4, sum(b_sex) // best illustrates the recall problem, weighing sample size and outcome
// 
// // tabulate yearGroupMarriage survey if bo < 3, sum(b_sex)
tabulate yearGroupMarriage survey if bo < 4, sum(b_sex)
// 
// // Also need a "first-born" version of each
// tabulate yearGroupBirth survey if bo == 1, sum(b_sex)
// tabulate yearGroupMarriage survey if bo == 1, sum(b_sex)
// 
// tabulate yearGroupBirth survey if bo == 2, sum(b_sex)
// tabulate yearGroupMarriage survey if bo == 2, sum(b_sex)
// 
// tabulate yearGroupBirth survey if bo == 3, sum(b_sex)
// tabulate yearGroupMarriage survey if bo == 3, sum(b_sex)

// Testing whether proportion significantly different from natural ratio
// estout does not seem well suited for this, so use file directly instead
// Need two tests:  1. whether sex ratio in given period is higher than expected
//                  2. whether sex ratios across survey for same cohorts is different (higher?)
capture program drop sexRatioTest
program sexRatioTest
    args fileName groupVar birthOrderCond
    file open tmpFile using "`fileName'.tex", write text replace
    forvalues year = 1960(5)2010 {
        local value : label (`groupVar') `year'
        local cohortCompare = ""
        // Descriptive stats and test for sex ratio higher than expected
        forvalue survey = 1/4 {
            capture noisily bitest b_sex == 105/205 if (survey == `survey') & bo `birthOrderCond' & `groupVar' == `year', detail
            if _rc == 0 { // need this because some cells do not have any observations in them
                loc sexRatio`survey' = `r(k)'/`r(N)'
                loc pVal`survey'     = `r(p_u)' // use this for testing if sex ratio higher than expected
    //             loc pVal`survey'     = `r(p)' // use this to test for differences between cohorts
                loc N`survey'        = `r(N)'
                loc tmp              : display %8.0fc `r(N)' // a not very pretty way of getting around that \mco is displayed as text
                loc numObs`survey'   = trim("`tmp'") // and I need to make sure that the brackets are tight around the number
                if `pVal`survey'' < 0.01 & `pVal`survey'' != . {
                    loc stars`survey' = "***"
                }
                else if `pVal`survey'' >= 0.01 & `pVal`survey'' < 0.05 {
                    loc stars`survey' = "**"
                }
                else if `pVal`survey'' >= 0.05 & `pVal`survey'' < 0.10 {
                    loc stars`survey' = "*"
                }
                else {
                    loc stars`survey' = ""
                }
            }
            else {
                loc sexRatio`survey' = .
                loc pVal`survey' = .
                loc numObs`survey' = .
                loc stars`survey' = ""
                loc N`survey' = .
            }  
        }
        // Test for whether sex ratio differ across surveys for same cohort
        // need six comparisons 1 vs 2, 1 vs 3, 1 vs 4, 2 vs 3, 2 vs 4, 3 vs 4
        loc level = 0.10
        if `N1' != . & `N2' != . {  // check whether missing
            prtesti `N1' `sexRatio1' `N2' `sexRatio2'
            if normal(`r(z)') < `level' {
                loc cohortCompare = "`cohortCompare'" + "A"
            }
        }
        if `N1' != . & `N3' != . {  // check whether missing
            prtesti `N1' `sexRatio1' `N3' `sexRatio3'
            if normal(`r(z)') < `level' {
                loc cohortCompare = "`cohortCompare'" + "B"
            }
        }
        if `N1' != . & `N4' != . {  // check whether missing
            prtesti `N1' `sexRatio1' `N4' `sexRatio4'
            if normal(`r(z)') < `level' {
                loc cohortCompare = "`cohortCompare'" + "C"
            }
        }
        if `N2' != . & `N3' != . {  // check whether missing
            prtesti `N2' `sexRatio2' `N3' `sexRatio3'
            if normal(`r(z)') < `level' {
                loc cohortCompare = "`cohortCompare'" + "D"
            }
        }
        if `N2' != . & `N4' != . {  // check whether missing
            prtesti `N2' `sexRatio2' `N4' `sexRatio4'
            if normal(`r(z)') < `level' {
                loc cohortCompare = "`cohortCompare'" + "E"
            }
        }
        if `N3' != . & `N4' != . {  // check whether missing
            prtesti `N3' `sexRatio3' `N4' `sexRatio4'
            if normal(`r(z)') < `level' {
                loc cohortCompare = "`cohortCompare'" + "F"
            }
        }
            
        // write out results
        file write tmpFile "`value'" 
        forvalues survey = 1/4 {
            local where = 20 * `survey'
            file write tmpFile _column(`where') "& " %6.4f  (`sexRatio`survey'') "\sym{`stars`survey''}"
        }
        file write tmpFile _column(100) "& `cohortCompare'"
        file write tmpFile _column(110) "\\"  _n
        forvalues survey = 1/4 {
            local where = 20 * `survey'
            file write tmpFile _column(`where') "& (" %6.4f  (`pVal`survey'') ")"
        }
        file write tmpFile _column(100) "&" _column(110) "\\"  _n
        forvalues survey = 1/4 {
            local where = 20 * `survey'
            file write tmpFile _column(`where') "& \mco{[`numObs`survey'']}"
        }
        file write tmpFile _column(100) "&" _column(110) "\\"  _n
    }
    file close tmpFile
end


// Making tables of results for paper
// easier to write a program (maybe)
// need to pass:
// - filename/output
// - whether birth or marriage for age groups
// - possibly birth order condition 1, 2, <4 etc

// parity 1, year of birth 
preserve 
drop if yearGroupBirth == 1950
replace yearGroupBirth = 1965 if yearGroupBirth == 1960 & survey == 2
replace yearGroupBirth = 1970 if yearGroupBirth == 1965 & survey == 3
replace yearGroupBirth = 1995 if yearGroupBirth == 2000 & survey == 2
replace yearGroupBirth = 1980 if yearGroupBirth == 1975 & survey == 4
sexRatioTest `tables'/recallBirthBO1 yearGroupBirth "== 1"
restore

// parity 1, year of marriage 
preserve 
drop if yearGroupMarriage == 1960 & (survey == 3 | survey == 4)
drop if yearGroupMarriage == 1965 & survey == 4
drop if yearGroupMarriage == 2000 & survey == 2
replace yearGroupMarriage = 1960 if yearGroupMarriage == 1950 & survey == 1
replace yearGroupMarriage = 1965 if yearGroupMarriage == 1960 & survey == 2
replace yearGroupMarriage = 1970 if yearGroupMarriage == 1965 & survey == 3
replace yearGroupMarriage = 2000 if yearGroupMarriage == 2005 & survey == 3
replace yearGroupMarriage = 1975 if yearGroupMarriage == 1970 & survey == 4
sexRatioTest `tables'/recallMarriageBO1 yearGroupMarriage "== 1"
restore

// parity 2, year of birth 
preserve 
drop if yearGroupBirth == 1950
drop if yearGroupBirth == 1960 & survey == 2
drop if yearGroupBirth == 1965 & survey == 3
replace yearGroupBirth = 1995 if survey == 2 & yearGroupBirth == 2000
replace yearGroupBirth = 1980 if survey == 4 & yearGroupBirth == 1975
sexRatioTest `tables'/recallBirthBO2 yearGroupBirth "== 2"
restore

// parity 2, year of marriage 
preserve 
drop if yearGroupMarriage == 1960 & survey == 3
drop if (yearGroupMarriage == 1960 | yearGroupMarriage == 1965) & survey == 4
replace yearGroupMarriage = 1960 if yearGroupMarriage == 1950 & survey == 1
replace yearGroupMarriage = 1965 if yearGroupMarriage == 1960 & survey == 2
replace yearGroupMarriage = 1970 if yearGroupMarriage == 1965 & survey == 3
replace yearGroupMarriage = 1975 if yearGroupMarriage == 1970 & survey == 4
sexRatioTest `tables'/recallMarriageBO2 yearGroupMarriage "== 2"
restore

// parity 1-3, year of birth
preserve
drop if yearGroupBirth == 1950
drop if yearGroupBirth == 1960 & survey == 2
drop if yearGroupBirth == 1965 & survey == 3
replace yearGroupBirth = 1995 if survey == 2 & yearGroupBirth == 2000
replace yearGroupBirth = 1980 if yearGroupBirth == 1975 & survey == 4
sexRatioTest `tables'/recallBirthBO4less yearGroupBirth "< 4"
restore

// parity 1-3, year of marriage
preserve 
drop if (yearGroupMarriage == 1960 | yearGroupMarriage == 1965) & survey == 4
drop if yearGroupMarriage == 1960 & survey == 3
drop if yearGroupMarriage == 2000 & survey == 2
replace yearGroupMarriage = 1960 if yearGroupMarriage == 1950 & survey == 1
replace yearGroupMarriage = 1965 if yearGroupMarriage == 1960 & survey == 2
replace yearGroupMarriage = 1970 if yearGroupMarriage <= 1965 & survey == 3
replace yearGroupMarriage = 2000 if yearGroupMarriage == 2005 & survey == 3
replace yearGroupMarriage = 1975 if yearGroupMarriage == 1970 & survey == 4
sexRatioTest `tables'/recallMarriageBO4less yearGroupMarriage "< 4"
restore


exit

// - Need to make this into latex format  - DONE
// - fine tune table to ensure no small cell sizes - DONE
// - duplicate for different combinations - DONE
// - test of differences - DONE
- graph of results

