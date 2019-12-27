* Create base data set for NFHS-2

// THIS FILES ASSUMES THAT YOU RUN IT USING THE FILE STRUCTURE DESCRIBED IN
// THE MAIN README FILE AND THAT THE WORKING ECTORY IS "./code"

clear
version 13.1
set more off

// Generic set of locations
include directories

/*----------------------------------------------------------------------*/
/* WOMEN'S RECODE 							*/
/*----------------------------------------------------------------------*/

use caseid v001-v012 v024 ///
   v102 v130-v135 ///
   bidx_01-b15_18 ///
   v211 v213 v214 v221 v222 v224 ///
   v317 v501 v503 v509 ///
   v603 v613 v616 v627-v629 v714 v715 v719 v720 v721 ///
   v104 v105 ///
   s119 ssdist using `rawdata'/iair42fl
des, short // for data description in paper
drop b14_* b15_* // not in NFHS-2 (nor in NFHS-1)
drop v004 b6_* b8_* b9_* b10_* b13_* // not needed
keep if v135 == 1 // usual resident in hh
drop if v104 == 96 // visitor to hh
keep if v503 == 1 // only married once
gen temp  = reverse(caseid)
gen temp1 = substr(temp,4,.)
gen whhid = reverse(temp1)
drop temp temp1 caseid v135 v503
sort whhid

save `data'/temp2_women, replace


/*----------------------------------------------------------------------*/
/* WEALTH INDEX                                                         */
/*----------------------------------------------------------------------*/

use `rawdata'/iawi41fl
sort whhid
save `data'/temp2_wlth, replace

/*----------------------------------------------------------------------*/
/* LAND OWNERSHIP                                                  */
/*----------------------------------------------------------------------*/

use `rawdata'/iahr42fl
keep hhid sh43-sh45
ren hhid whhid
sort whhid
save `data'/temp2_land, replace

/*----------------------------------------------------------------------*/
/* COMBINED DATA SETS                                                   */
/*----------------------------------------------------------------------*/

* wealth
use `data'/temp2_women
merge m:1 whhid using `data'/temp2_wlth
tab _merge
drop if _merge != 3
drop _merge 

* land
sort whhid
merge m:1 whhid using `data'/temp2_land
tab _merge
drop if _merge != 3
drop _merge whhid

compress

/*----------------------------------------------------------------------*/
/* ENSURE CONSISTENTY IN VARIABLES AND NAMES                            */
/*----------------------------------------------------------------------*/

gen state = v024 // Have to redefine in NHFS-3
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
gen scheduled_caste = v131 == 1
gen scheduled_tribe = v131 == 2
drop v131

// education
ren v133 edu_mother
drop if edu_mother > 30
ren v715 edu_father

// marriage to first birth interval
ren v221 space_0_1

// male or female sterilization
ren v317 sterilisation

// marriage timing
ren v509 marriage_cmc

// literacy
gen literate = s119 == 1 | edu_mother >= 6
drop s119

// land
ren sh43 land_own
recode land_own (9=.)
recode sh44 (9998 9999 . = 0)
recode sh45 (9995 9996 9998 9999 . = 0)
gen land_irr = sh45/10
gen land_nir = sh44/10 - land_irr
drop sh44 sh45 

// fertility-sex preference
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
recode placePrevious (3=2)
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
save `data'/base2, replace

