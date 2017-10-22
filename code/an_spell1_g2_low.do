* Women with low education (0 years) for both urban and rural
* Competing Discrete Hazard model
* First spell (from marriage to first birth)
* an_spell1_g2_low.do
* Begun.: 08/04/10
* Edited: 2016-09-08


// REVISIONS

version 13.1
clear all

// Generic set of locations
loc rawdata "../rawData"
loc data    "../data"
loc figures "../figures"
loc tables  "../tables"

/*-------------------------------------------------------------------*/
/* LOADING DATA AND CREATING NEW VARIABLES                           */
/*-------------------------------------------------------------------*/

use `data'/base

keep if edu_mother == 0
loc educ = "low"

// data manipulation
do genSpell1

// Group
forvalues group = 2/2 {
    dis _n
    dis "******************************************************"
    dis "*                  THIS IS GROUP `group'                   *"
    dis "******************************************************"    
    dis _n
//         preserve
        keep if group == `group'
        // need to save the sample for predictions
        // save `work'/predictSample_spell1_g2_low, replace 
        count
        sum $parents $hh $caste 
        estpost tab gu_group
        esttab using `tables'/mainObs_spell1_g`group'_`educ'.tex, replace ///
            cells("b(label(N))") ///
            nonumber nomtitle noobs
        eststo clear

        // GENERATE TIME VARIABLES
        expand b1_space 
        bysort id: gen t = _n
        // the b1_cen == 0 is needed since I restrict the duration to `lastm' above
        // b1_sex is the child born as end of spell 2
        gen byte birth = 0
        bysort id (t): replace birth = 1 if b1_sex == 1 & b1_cen == 0 & _n == _N // exit with a son
        bysort id (t): replace birth = 2 if b1_sex == 2 & b1_cen == 0 & _n == _N // exit with a daugther
        tab t, gen(d)
        // EXITS WITH BIRTH ONLY (NON-CENSORED)
        dis " All "
        tab b1_space if birth == 1 | birth == 2
        tab b1_space urban if birth == 1 | birth == 2
        tab t if b1_cen == 0

        // Save number of observation data
        preserve
        bysort id (t): egen any_birth = max(birth)
        bysort id (t): keep if _n == 1
        gen had_birth = any_birth == 1 | any_birth == 2
        collapse (count) num_obs = had_birth (sum) num_births = had_birth , by(urban) 
        save `data'/obs_spell1_`group'_`educ', replace
        restore
        
        // PIECE-WISE LINEAR HAZARDS
        loc i = 1
        forvalues per = 1/4 { // check end number originally 9
            gen dur`i' = t == `per'  // quarters
            loc i = `i' + 1
        }
        forvalues per = 5(3)17 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 2 // 3 quarter years
            loc i = `i' + 1
        }
        gen dur`i' = t >= 20 & t <= 24
                    
        egen sumdur = rowtotal(dur*)
        assert sumdur == 1
        
        // NON-PROPORTIONALITY
//         gen np1 = t >= 1 & t <= 4
//         gen np2 = t >= 5 & t <= 6
//         gen np3 = t >= 7 & t <= 9
//         gen np4 = t >= 10 & t <= 13
//         gen np5 = t >= 14 & t <= 21
//         gen np7 = t > 21
//         loc j = 5

        foreach var of var ///
        urban {
            forval x = 1/`i' {
                gen np`x'X`var'  = dur`x' * `var' 
            }
        }
        
        loc np "  np*X* "
        
        // ESTIMATION
        eststo clear
        eststo: mlogit birth dur*  ///
            $parents $hh $caste `np'  ///
            , baseoutcome(2) noconstant 

        local names : colfullnames e(b)
        estimates notes: `names'
        estimates notes: $lastm
        estimates save `data'/results_spell1_g`group'_low, replace

//         est store M2
        
//         lrtest M2 M1

//         restore
    
}

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



