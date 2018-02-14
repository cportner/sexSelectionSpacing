* Recall error estimations
* anRecall.do
* begun.: 09/08/07
* edited: 2015-01-22

// Notes:
// Part of this is based on andescribe.do

version 13.1
clear all

loc root "/net/proj"
loc work "`root'/India_NFHS/base"
loc graphs "`root'/India_NFHS/graphs"
loc results "~/data/india/sexSelection/results"
// loc results "`root'/India_NFHS/base" // for testing purposes

/*-------------------------------------------------------------------*/
/* LOADING DATA AND CREATING NEW VARIABLES                           */
/*-------------------------------------------------------------------*/

use `work'/base

keep if hindu

// survey information
gen survey  = 1 if interview_year == 1992 | interview_year == 1993
replace survey = 2 if interview_year == 1998 | interview_year == 1999 | interview_year == 2000
replace survey = 3 if interview_year == 2005 | interview_year == 2006

loc i = 88
forvalues k = 1/3 {
    gen b`k'_son = b`k'_sex == 1 if fertility >= `k'
    gen b`k'_born_year = int((b`k'_born_cmc-1)/12) if fertility >= `k'
    gen b`k'_born_year_2 = b`k'_born_year^2  / 100
    gen b`k'_after`i' = b`k'_born_year > `i'
    gen b`k'_mom_age_2 = b`k'_mom_age^2 / 100
}
gen edu_mother_2 = edu_mother^2 / 10
gen edu_father_2 = edu_father^2 / 10
gen mar_year = int((marriage_cmc-1)/12)+1900
gen mar_after`i' = mar_year > `i'

// local variables
loc religion "hindu muslim sikh buddhist jain other "
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
egen yearGroupBirth = cut(born_year) , at(1950,1960(5)2000, 2007) 
egen yearGroupMarriage = cut(mar_year) , at(1950,1960(5)2000, 2007) 

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
    2000 "2000--2006" 
    
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
    forvalues year = 1960(5)2000 {
        local value : label (`groupVar') `year'
        local cohortCompare = ""
        // Descriptive stats and test for sex ratio higher than expected
        forvalue survey = 1/3 {
            capture noisily bitest b_sex == 106/206 if (survey == `survey') & bo `birthOrderCond' & `groupVar' == `year', detail
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
        // need three comparisons 1 vs 2, 1 vs 3, 2 vs 3 
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
        if `N2' != . & `N3' != . {  // check whether missing
            prtesti `N2' `sexRatio2' `N3' `sexRatio3'
            if normal(`r(z)') < `level' {
                loc cohortCompare = "`cohortCompare'" + "C"
            }
        }
        // write out results
        file write tmpFile "`value'" 
        forvalues survey = 1/3 {
            local where = 20 * `survey'
            file write tmpFile _column(`where') "& " %6.4f  (`sexRatio`survey'') "\sym{`stars`survey''}"
        }
        file write tmpFile _column(80) "& `cohortCompare'"
        file write tmpFile _column(90) "\\"  _n
        forvalues survey = 1/3 {
            local where = 20 * `survey'
            file write tmpFile _column(`where') "& (" %6.4f  (`pVal`survey'') ")"
        }
        file write tmpFile _column(80) "&" _column(90) "\\"  _n
        forvalues survey = 1/3 {
            local where = 20 * `survey'
            file write tmpFile _column(`where') "& \mco{[`numObs`survey'']}"
        }
        file write tmpFile _column(80) "&" _column(90) "\\"  _n
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
sexRatioTest `results'/recallBirthBO1 yearGroupBirth "== 1"
restore

// parity 1, year of marriage 
preserve 
drop if yearGroupMarriage == 1960 & survey == 3
drop if yearGroupMarriage == 2000 & survey == 2
replace yearGroupMarriage = 1960 if yearGroupMarriage == 1950 & survey == 1
replace yearGroupMarriage = 1965 if yearGroupMarriage == 1960 & survey == 2
replace yearGroupMarriage = 1970 if yearGroupMarriage == 1965 & survey == 3
sexRatioTest `results'/recallMarriageBO1 yearGroupMarriage "== 1"
restore

// parity 2, year of birth 
preserve 
drop if yearGroupBirth == 1950
drop if yearGroupBirth == 1960 & survey == 2
drop if yearGroupBirth == 1965 & survey == 3
replace yearGroupBirth = 1995 if survey == 2 & yearGroupBirth == 2000
sexRatioTest `results'/recallBirthBO2 yearGroupBirth "== 2"
restore

// parity 2, year of marriage 
preserve 
drop if yearGroupMarriage == 1960 & survey == 3
replace yearGroupMarriage = 1960 if yearGroupMarriage == 1950 & survey == 1
replace yearGroupMarriage = 1965 if yearGroupMarriage == 1960 & survey == 2
replace yearGroupMarriage = 1970 if yearGroupMarriage == 1965 & survey == 3
sexRatioTest `results'/recallMarriageBO2 yearGroupMarriage "== 2"
restore

// parity 1-4, year of birth
preserve
drop if yearGroupBirth == 1950
drop if yearGroupBirth == 1960 & survey == 2
drop if yearGroupBirth == 1965 & survey == 3
replace yearGroupBirth = 1995 if survey == 2 & yearGroupBirth == 2000
sexRatioTest `results'/recallBirthBO4less yearGroupBirth "< 4"
restore

// parity 1-4, year of marriage
preserve 
drop if yearGroupMarriage == 1960 & survey == 3
drop if yearGroupMarriage == 2000 & survey == 2
replace yearGroupMarriage = 1960 if yearGroupMarriage == 1950 & survey == 1
replace yearGroupMarriage = 1965 if yearGroupMarriage == 1960 & survey == 2
replace yearGroupMarriage = 1970 if yearGroupMarriage <= 1965 & survey == 3
sexRatioTest `results'/recallMarriageBO4less yearGroupMarriage "< 4"
restore


exit

// - Need to make this into latex format  - DONE
// - fine tune table to ensure no small cell sizes - DONE
// - duplicate for different combinations - DONE
// - test of differences - DONE
- graph of results




exit

     2 "Andhra Pradesh"
     3 "Assam"
     4 "Bihar"
     5 "Goa"
     6 "Gujarat"
     7 "Haryana"
     8 "Himachal Pradesh"
     9 "Jammu"
    10 "Karnataka"
    11 "Kerala"
    12 "Madhya Pradesh"
    13 "Maharashtra"
    14 "Manipur"
    15 "Meghalaya"
    16 "Mizoram"
    17 "Nagaland"
    18 "Orissa"
    19 "Punjab"
    20 "Rajasthan"
    21 "Sikkim"
    22 "Tamil Nadu"
    23 "West Bengal"
    24 "Uttar Pradesh"
    30 "New Delhi"
    34 "ArunachalPradesh"
    35 "Tripura"
