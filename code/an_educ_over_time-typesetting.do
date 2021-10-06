// Describe changes in female education and labor force participation

// Use household recode for female education to get all women

clear
version 15.1
set more off

// Generic set of locations
include directories

// NFHS-1

// No religion information in NFHS-1 HH recode so use raw
use  `rawdata'/iahh21fl
gen cluster_number   = hhstate * 1000 + hhpsu
gen household_number = hhnumber
sort cluster_number household_number

rename h032 religion_head 

keep cluster_number household_number religion_head
duplicates drop
save `data'/temp_religion, replace


// Regular HH recode data
use hhid hv001 hv002 hv005 hv006 hv007 hv025 ///
    hv102_* hv104_* hv105_* hv108_* ///
    using `rawdata'/iahr23fl

rename hv001 cluster_number
rename hv002 household_number
rename hv005 sample_weight
rename hv006 interview_month
rename hv007 interview_year
rename hv025 place_type

merge 1:1 cluster_number household_number using `data'/temp_religion
keep if religion_head == 1 // Hindu only
keep if _merge == 3
drop _merge religion_head

// need string to get 01, 02, 03, etc
reshape long hv102_ hv104_ hv105_ hv108_, ///
    i(hhid) j(hh_member) string

destring hh_member, replace

// Usual residents and females over the age of 19 with a valid age
keep if hv102 == 1 & hv104 == 2 & hv105 > 19 & hv105 < 98

rename hv105 age_years
rename hv108 educ_years

drop hv102 hv104
compress
save `data'/temp_hh1, replace




// NFHS-2
use hhid hv001 hv002 hv005 hv006 hv007 hv025 sh39 ///
    hv102_* hv104_* hv105_* hv108_* ///
    using `rawdata'/iahr42fl

keep if sh39 == 1 // Hindu only
drop sh39

// need string to get 01, 02, 03, etc
reshape long hv102_ hv104_ hv105_ hv108_, ///
    i(hhid) j(hh_member) string

destring hh_member, replace

// Usual residents and females over the age of 19 with a valid age
keep if hv102 == 1 & hv104 == 2 & hv105 > 19 & hv105 < 98

rename hv001 cluster_number
rename hv002 household_number
rename hv005 sample_weight
rename hv006 interview_month
rename hv007 interview_year
rename hv025 place_type
rename hv105 age_years
rename hv108 educ_years

drop hv102 hv104
compress
save `data'/temp_hh2, replace



// NFHS-3
use hhid hv001 hv002 hv005 hv006 hv007 hv025 sh44 ///
    hv102_* hv104_* hv105_* hv108_* ///
    using `rawdata'/iahr52fl

keep if sh44 == 1 // Hindu only
drop sh44

// need string to get 01, 02, 03, etc
reshape long hv102_ hv104_ hv105_ hv108_, ///
    i(hhid) j(hh_member) string

destring hh_member, replace

// Usual residents and females over the age of 19 with a valid age
keep if hv102 == 1 & hv104 == 2 & hv105 > 19 & hv105 < 98

rename hv001 cluster_number
rename hv002 household_number
rename hv005 sample_weight
rename hv006 interview_month
rename hv007 interview_year
rename hv025 place_type
rename hv105 age_years
rename hv108 educ_years

drop hv102 hv104
compress
save `data'/temp_hh3, replace



// NFHS-4
use hhid hv001 hv002 hv005 hv006 hv007 hv025 sh34 ///
    hv102_* hv104_* hv105_* hv108_* ///
    using `rawdata'/iahr71fl

keep if sh34 == 1 // Hindu only
drop sh34

// need string to get 01, 02, 03, etc
reshape long hv102_ hv104_ hv105_ hv108_, ///
    i(hhid) j(hh_member) string

destring hh_member, replace

// Usual residents and females over the age of 19 with a valid age
keep if hv102 == 1 & hv104 == 2 & hv105 > 19 & hv105 < 98

rename hv001 cluster_number
rename hv002 household_number
rename hv005 sample_weight
rename hv006 interview_month
rename hv007 interview_year
rename hv025 place_type
rename hv105 age_years
rename hv108 educ_years

drop hv102 hv104
compress
save `data'/temp_hh4, replace


// Combine all 

append using `data'/temp_hh3 `data'/temp_hh2 `data'/temp_hh1
compress

// Cohort
replace interview_year = 1900 + interview_year if interview_year > 0 & interview_year < 100
replace interview_year = 2000 if interview_year == 0
gen cohort = interview_year - age_years
egen cohort_5 = cut(cohort), at (1930(5)1990 2000)

// education group
drop if educ_years > 30 // 98 and 99 Don't know and NA
gen educ_none = educ_years == 0
gen educ_1_7  = educ_years > 0 & educ_years < 8
gen educ_8_11 = educ_years >= 8 & educ_years < 12
gen educ_12_up = educ_years >= 12
egen educ_group = cut(educ_years), at(0 1 8 30)

save `data'/temp_hh_all, replace

// use `data'/temp_hh_all, clear 

// Graph variables
set scheme s1mono
preserve
// Generic set of locations
include directories

collapse educ_none educ_1_7 educ_8_11 educ_12_up , by(cohort place_type)
gen urban = place_type == 1
gen rural = !urban
keep if cohort > 1929
gen null = 0
gen one = 100
gen line_0 = educ_none * 100
gen line_1 = (educ_none + educ_1_7) * 100
gen line_2 = (educ_none + educ_1_7 + educ_8_11) * 100


// Rural
    graph twoway rarea null line_0 cohort if rural, color(gs14)  lwidth(none) ///
        || rarea line_0 line_1 cohort if rural, color(gs10) lwidth(none) ///
        || rarea line_1 line_2 cohort if rural, color(gs6) lwidth(none) ///
        || rarea line_2 one cohort if rural, color(gs2) lwidth(none) ///
        || , legend(label(1 "No education") label(2 "1-7 years") label(3 "8-11 years") label(4 "12 or more years") ring(0) position(8) col(1)) ///
            plotregion(margin(zero)) /// 
			xlabel(1930(10)1990) ylabel(, angle(0)) ///
			xtitle("{bf:Cohort}") ytitle("{bf:Percentage}") title("{bf:Rural}") ///
			name(educ_rural, replace)

// Urban
    graph twoway rarea null line_0 cohort if urban, color(gs14)  lwidth(none) ///
        || rarea line_0 line_1 cohort if urban, color(gs10) lwidth(none) ///
        || rarea line_1 line_2 cohort if urban, color(gs6) lwidth(none) ///
        || rarea line_2 one cohort if urban, color(gs2) lwidth(none) ///
        || , legend(label(1 "No education") label(2 "1-7 years") label(3 "8-11 years") label(4 "12 or more years") ring(0) position(8) col(1)) ///
            plotregion(margin(zero)) /// 
			xlabel(1930(10)1990) ylabel(, angle(0)) ///
			xtitle("{bf:Cohort}") ytitle("{bf:Percentage}") title("{bf:Urban}") ///
			name(educ_urban, replace)

graph combine educ_rural educ_urban, ycommon ///
	ysize(5) xsize(9) imargin(0 2 3 0)
			
graph export `figures'/educ_over_time.eps, replace fontface(Palatino)			
			


// Original - relies on LaTeX for captions

foreach var of varlist urban rural {
    graph twoway rarea null line_0 cohort if `var', color(gs14)  lwidth(none) ///
        || rarea line_0 line_1 cohort if `var', color(gs10) lwidth(none) ///
        || rarea line_1 line_2 cohort if `var', color(gs6) lwidth(none) ///
        || rarea line_2 one cohort if `var', color(gs2) lwidth(none) ///
        || , legend(label(1 "No education") label(2 "1-7 years") label(3 "8-11 years") label(4 "12 or more years") ring(0) position(8) col(1)) ///
            plotregion(margin(zero)) /// 
			xlabel(1930(10)1990) ylabel(, angle(0)) ///
			xtitle("{bf:Cohort}") ytitle("{bf:Percentage}")

    
}


   graph export `figures'/educ_over_time_rural.eps, replace fontface(Palatino)





