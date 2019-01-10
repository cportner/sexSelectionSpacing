* Create base data set for NFHS-3
* Is based on my original work
* crBase3.do
* begun.: 2017-06-02
* edited: 2017-06-02


// THIS FILES ASSUMES THAT YOU RUN IT USING THE FILE STRUCTURE DESCRIBED IN
// THE MAIN README FILE AND THAT THE WORKING ECTORY IS "./code"

clear
version 13.1
set more off

// Generic set of locations
loc rawdata "../rawData"
loc data    "../data"
loc figures "../figures"
loc tables  "../tables"


/*----------------------------------------------------------------------*/
/* WOMEN'S RECODE 							*/
/*----------------------------------------------------------------------*/

use v001-v012 v024 v026 ///
   v102 v130-v135 v155 v190 v191 ///
   bidx_01-b16_20 ///
   v211 v213 v214 v221 v222 v224 ///
   v312 v317 ///
   v501 v503 v509 ///
   v603 v613 v616 v627-v629 v715 ///
   v104 v105 ///
   s60 s61 s118  using `rawdata'/iair52fl
des, short // for data description in paper
drop b15_* b16_* // not in NFHS-2 (nor in NFHS-1)
drop v004 b6_* b8_* b9_* b10_* b13_* v131 // not needed or na in survey
keep if v135 == 1 // usual resident in hh
drop if v104 == 96 // visitor to hh
drop if v501 == 0 // never married women
keep if v503 == 1 // only married once
ren v190 wlthind5
ren v191 wlthindf
replace wlthindf = wlthindf/100000
compress
drop v135 v503
save `data'/temp3_women, replace

/*----------------------------------------------------------------------*/
/* COMBINE DATA SETS							*/
/*----------------------------------------------------------------------*/

sort v024 v026
// merge v024 v026 using `work'/locale3
// tab _merge
// keep if _merge == 3
// drop _merge v026
drop v026

compress

/*----------------------------------------------------------------------*/
/* ENSURE CONSISTENTY IN VARIABLES AND NAMES                            */
/*----------------------------------------------------------------------*/

recode v024   ///
       (28 =  2 "Andhra Pradesh") ///
       (18 =  3 Assam) ///
       (10 20 =  4 Bihar) ///
       (30 =  5 Goa) ///
       (24 =  6 Gujarat) ///
       ( 6 =  7 Haryana) ///
       ( 2 =  8 "Himachal Pradesh") ///
       ( 1 =  9 Jammu) ///
       (29 = 10 Karnataka) ///
       (32 = 11 Kerala) ///
       (22 23 = 12 "Madhya Pradesh") ///
       (27 = 13 Maharashtra) ///
       (14 = 14 Manipur) ///
       (17 = 15 Meghalaya) ///
       (15 = 16 Mizoram) ///
       (13 = 17 Nagaland) ///
       (21 = 18 Orissa) ///
       ( 3 = 19 Punjab) ///
       ( 8 = 20 Rajasthan) ///
       (11 = 21 Sikkim) ///
       (33 = 22 "Tamil Nadu") ///
       (19 = 23 "West Bengal") ///
       (5 9 = 24 "Uttar Pradesh") ///
       ( 7 = 30 Delhi) ///
       (12 = 34 "Arunachal Pradesh") ///
       (16 = 35 Tripura) ///
       , gen(state)
drop v024

// religion
gen hindu = v130 == 1
gen muslim = v130 == 2
gen christian = v130 == 3
gen sikh = v130 == 4
gen buddhist = v130 == 5
gen jain = v130 == 6
gen other = v130 >= 7
drop v130

// ethnicity
gen scheduled_caste = s118 == 1
gen scheduled_tribe = s118 == 2
drop s118

// education
ren v133 edu_mother
drop if edu_mother > 30
ren v715 edu_father

// marriage to first birth interval
ren v221 space_0_1

// male or female sterilization
gen sterilisation = v317 if v312 == 6 | v312 == 7
drop v312 v317

// marriage timing
ren v509 marriage_cmc

// literacy
gen literate = v155 == 2
drop v155

// land
recode s61 (999.5 999.8 999.9 . = 0)
recode s60 (999.8 999.9 . = 0)
gen land_own = s61 | s60
gen land_irr = s61
gen land_nir = s60
drop s60 s61

// fertility-sex preferences
ren v627 want_boys
ren v628 want_girls
ren v629 want_either

// urban-rural
gen urban = v102 == 1
gen rural = v102 == 2
ren v102 urban_rural

// place of residence
gen resid_large   = v134 == 0
gen resid_small   = v134 == 1
gen resid_town    = v134 == 2
gen resid_country = v134 == 3
ren v134 place_type

// migration question
ren v104 placeYearLived
ren v105 placePrevious
recode placePrevious (2=1) (3=2)
label def place 1 "Urban" 2 "Rural"
label val placePrevious place 

// renaming variables
ren v007 interview_year
ren v008 interview_cmc
ren v009 mother_month
ren v010 mother_year
ren v011 mother_cmc
ren v012 mother_age   
ren v211 first_cmc
ren v213 pregnant_now
ren v214 pregnant_duration
ren v222 space_last_int
ren v224 fertility
ren v501 marital_status
ren v603 pref_waiting  
ren v613 pref_fertility
ren v616 pref_space

compress
save `data'/base3, replace

