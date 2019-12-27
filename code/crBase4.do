* Create base data set for NFHS-4
* crBase4.do


// THIS FILES ASSUMES THAT YOU RUN IT USING THE FILE STRUCTURE DESCRIBED IN
// THE MAIN README FILE AND THAT THE WORKING DIRECTORY IS "./code"

clear
version 13.1
set more off

// Generic set of locations
include directories

// CHANGES FROM NFHS-3
// Land is no longer in the individual recode (s60 and s61 in NFHS-3).
// Land is now in HV244 in household recode, so need to load that as well.
// Whether irrigated or not is not used in analysis, so only load land own.
// Caste has moved from s118 to s116; otherwise coding the same.

// v026 (de facto place of residence split into different size urban areas) 
// is not available and therefore removed. I use urban/rural anyway, so
// this will not matter for analysis.

// There is no longer any information on where the respondent previously
// lived (v105 in prior survey). There is still information on how long
// the respondent has lived in the current place of residence (v104).
// The exclusion of v105 makes it impossible to examine whether prior
// fertility decisions were made in an urban or rural area as I did for
// the prior survey. For those I used type of area at the time of the
// beginning of spell rather than current area.

/*----------------------------------------------------------------------*/
/* WOMEN'S RECODE 							                            */
/*----------------------------------------------------------------------*/

use caseid v001-v012 v024 ///
   v102 v104 v105 v130-v135 v155 v190 v191 ///
   bidx_01-b16_20 ///
   v211 v213 v214 v221 v222 v224 ///
   v312 v317 ///
   v501 v503 v509 ///
   v603 v613 v616 v627-v629 v714 v715 v719 v721 v741 ///
   s116 using `rawdata'/iair72fl
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
drop v135 v503

/*----------------------------------------------------------------------*/
/* ENSURE CONSISTENTY IN VARIABLES AND NAMES                            */
/*----------------------------------------------------------------------*/

// NFHS-4 state codes - different from NFHS-3 and prior surveys
// 1 Andaman and Nicobar Islands
// 2 Andhra Pradesh
// 3 Arunachal Pradesh
// 4 Assam
// 5 Bihar
// 6 Chandigarh
// 7 Chhattisgarh
// 8 Dadra and Nagar Haveli
// 9 Daman and Diu
// 10 Goa
// 11 Gujarat
// 12 Haryana
// 13 Himachal Pradesh
// 14 Jammu and Kashmir
// 15 Jharkhand
// 16 Karnataka
// 17 Kerala
// 18 Lakshadweep
// 19 Madhya Pradesh
// 20 Maharashtra
// 21 Manipur
// 22 Meghalaya
// 23 Mizoram
// 24 Nagaland
// 25 Delhi
// 26 Odisha
// 27 Puducherry
// 28 Punjab
// 29 Rajasthan
// 30 Sikkim
// 31 Tamil Nadu
// 32 Tripura
// 33 Uttar Pradesh
// 34 Uttarakhand
// 35 West Bengal
// 36 Telangana

drop if v024 == 1 // Andaman and Nicobar Islands (not in other surveys)
drop if v024 == 18 // Lakshadweep a small island chain
// Puducherry (27) is assigned to Tamil Nadu, but has four locations, two in Tamil Nadu
// and one in Andhra Pradesh and one in Kerala
recode v024   ///
       ( 2 36 =  2 "Andhra Pradesh") ///
       ( 4 =  3 Assam) ///
       ( 5 15 =  4 Bihar) ///
       (10 =  5 Goa) ///
       (11 8 9 =  6 Gujarat) ///
       (6 12 =  7 Haryana) ///
       (13 =  8 "Himachal Pradesh") ///
       (14 =  9 Jammu) ///
       (16 = 10 Karnataka) ///
       (17 = 11 Kerala) ///
       (19 7 = 12 "Madhya Pradesh") ///
       (20 = 13 Maharashtra) ///
       (21 = 14 Manipur) ///
       (22 = 15 Meghalaya) ///
       (23 = 16 Mizoram) ///
       (24 = 17 Nagaland) ///
       (26 = 18 Orissa) ///
       (28 = 19 Punjab) ///
       (29 = 20 Rajasthan) ///
       (30 = 21 Sikkim) ///
       (31 27 = 22 "Tamil Nadu") ///
       (35 = 23 "West Bengal") ///
       (33 34 = 24 "Uttar Pradesh") ///
       (25 = 30 Delhi) ///
       (3  = 34 "Arunachal Pradesh") ///
       (32 = 35 Tripura) ///
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

// ethnicity - was s118 in NFHS-3
gen scheduled_caste = s116 == 1
gen scheduled_tribe = s116 == 2
drop s116

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

// fertility-sex preferences
ren v627 want_boys
ren v628 want_girls
ren v629 want_either

// urban-rural
gen urban = v102 == 1
gen rural = v102 == 2
ren v102 urban_rural

// // place of residence - no longer asked in NFHS-4
// gen resid_large   = v134 == 0
// gen resid_small   = v134 == 1
// gen resid_town    = v134 == 2
// gen resid_country = v134 == 3
// ren v134 place_type

// migration question - previous place of residence no longer asked in NFHS-4
// Hence, there is no way to figure out if people migrated from urban/rural
// to urban/rural
ren v104 placeYearLived
// ren v105 placePrevious
// recode placePrevious (2=1) (3=2)
// label def place 1 "Urban" 2 "Rural"
// label val placePrevious place 

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

// Generate household id
gen temp_id  = reverse(caseid)
gen temp_id1 = substr(temp_id,4,.)
gen whhid = trim(reverse(temp_id1))
drop temp_id temp_id1
sort whhid

compress
save `data'/temp4_women, replace

/*----------------------------------------------------------------------*/
/* HOUSEHOLD'S RECODE 							                            */
/*----------------------------------------------------------------------*/

// only needed for land variable
// id uses the string variable because of precision problems when generating
// a new household id based on v001 and v002.
// The trim() is to ensure that the variables are identically defined.

use hhid hv244 using `rawdata'/iahr71fl
gen whhid = trim(hhid)

// land
ren hv244 land_own // Already coded 0: no, 1: yes with no missing

sort whhid
save `data'/temp4_hh, replace

/*----------------------------------------------------------------------*/
/* COMBINE DATA 							                            */
/*----------------------------------------------------------------------*/

use `data'/temp4_women
merge m:1 whhid using `data'/temp4_hh
tab _merge
drop if _merge != 3
drop _merge whhid hhid


compress
save `data'/base4, replace

