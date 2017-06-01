* Create base data set for NFHS-1
* crbase1.do
* begun.: 23/07/08
* edited: 2015-03-16

clear
version 8.2
set mem 1G
set more off

loc root "/net/proj/India_NFHS"
*loc root "//marc/net-proj"

loc data "`root'/data/stata"
loc work "`root'/base"

tempfile religion

/*----------------------------------------------------------------------*/
/* WOMEN'S RECODE 							*/
/*----------------------------------------------------------------------*/

use caseid v001-v012 v024 ///
   v102 v130-v135 ///
   bidx_01-b13_20 ///
   v211 v213 v214 v222 v224 ///
   v317 v501 v503 v511 ///
   v603 v613 v616 v715 ///
   s108 s149-s151 s517b-s517e ///
   v104 s104 ///
   using `data'/iair22rt
des , short // for data description in paper
drop v004 b6_* b8_* b9_* b10_* b13_* // not needed/in set
keep if v135 == 1 // usual resident in hh
drop if v104 == 96 // visitor to hh
keep if v503 == 1 // only married once
drop if v511 == 97 // inconsisten information on age 1st marriage
gen whhid = substr(caseid,1,12)
drop caseid v135 v503
sort whhid
save `work'/temp1_women, replace


/*----------------------------------------------------------------------*/
/* WEALTH INDEX 							*/
/*----------------------------------------------------------------------*/

use `data'/iawi22
sort whhid
save `work'/temp1_wlth, replace

/*----------------------------------------------------------------------*/
/* RELIGION FROM RAW HH DATA						*/
/*----------------------------------------------------------------------*/

tempvar db

*use hhstate hhpsu hhnumber h032 using `data'/iahh21fl
use  `data'/iahh21fl
gen v001 = hhstate * 1000 + hhpsu
gen v002 = hhnumber
sort v001 v002
by v001: gen `db' = v002[_n] == v002[_n-1]
drop if `db' == 1
save `religion'

/*----------------------------------------------------------------------*/
/* COMBINED DATA SETS                                                   */
/*----------------------------------------------------------------------*/

* wealth
use `work'/temp1_women
merge whhid using `work'/temp1_wlth
tab _merge
drop if _merge != 3
drop _merge whhid
sort v001 v002

* locale data
merge v001 v002 using `work'/locale1
tab _merge
drop if _merge != 3
drop _merge
sort v001 v002

* religion
merge v001 v002 using `religion'
tab _merge
drop if _merge != 3
drop _merge

compress

/*----------------------------------------------------------------------*/
/* ENSURE CONSISTENCY IN VARIABLES AND NAMES                            */
/*----------------------------------------------------------------------*/

gen state = v024 // have to redefine in NFHS-3
drop v024

// religion
*gen hindu = v130 == 0
*gen muslim = v130 == 1
*gen christian = v130 == 2
*gen sikh = v130 == 3
*gen buddhist = 0 // no option in NFHS-1
*gen jain = 0 // no option in NFHS-1
*gen other = v130 == 4
drop v130
// religion - from raw hh
gen hindu = h032 == 1
gen muslim = h032 == 7
gen christian = h032 == 4
gen sikh = h032 == 2
gen buddhist = h032 == 3
gen jain = h032 == 5
gen other = h032 == 6 | h032 >= 8 | h032 == . 
drop h032

// ethnicity
gen scheduled_caste = v131 == 0
gen scheduled_tribe = v131 == 1
drop v131

// education
ren v133 edu_mother
drop if edu_mother > 30
ren v715 edu_father

// marriage timing
gen marriage_cmc = v011 + v511*12
drop v511

// marriage to first birth interval
// not sure if this is right - could try either just low or
// low + 6 months
// gen mar_cmc_l = marriage_cmc 
// gen mar_cmc_h = marriage_cmc + (v008-v011)-(int((v008-v011)/12))*12
// gen space_0_1 = v211 - (mar_cmc_l + int((mar_cmc_h-mar_cmc_l)/2))
// 2015-03-11 - new version - uses the earliest she could have been born
gen space_0_1 = v211 - marriage_cmc
recode space_0_1 (min/-1 = 996)
// drop mar_*

// male or female sterilization
ren v317 sterilisation 

// literacy
gen literate = s108 == 1 | edu_mother >= 6
drop s108

// land
ren s149 land_own
ren s150 land_nir
ren s151 land_irr
recode land_nir (996 = 0.5) (998 . = 0)
recode land_irr (996 = 0.5) (998 . = 0)

// fertility-sex preferences
ren s517b want_boys
ren s517g want_girls
ren s517e want_either

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
ren s104 placePrevious

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
save `work'/base1, replace

