* Women with medium education (1-7 years) for both urban and rural
* Competing Discrete Hazard model
* Fourth spell (from 3rd to 4th birth)
* an_spell4_g2_med.do
* Begun.: 09/04/10
* Edited: 2015-03-12


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

keep if edu_mother >= 1 & edu_mother < 8
local edgroup = "med"

// data manipulation
do genSpell4

// Group
forvalues group = 2/2 {
    dis _n
    dis "******************************************************"
    dis "*                  THIS IS GROUP `group'                   *"
    dis "******************************************************"    
    dis _n
//         preserve
        keep if group == `group'
        count
        sum $parents $hh $caste 
        estpost tab gu_group
        esttab using `tables'/mainObs_spell4_g`group'_`edgroup'.tex, replace ///
            cells("b(label(N))") ///
            nonumber nomtitle noobs
        eststo clear

        // GENERATE TIME VARIABLES
        expand b4_space 
        bysort id: gen t = _n
        // the b4_cen == 0 is needed since I restrict the duration to `lastm' above
        // b4_sex is the child born as end of spell 4
        gen byte birth = 0
        bysort id (t): replace birth = 1 if b4_sex == 1 & b4_cen == 0 & _n == _N // exit with a son
        bysort id (t): replace birth = 2 if b4_sex == 2 & b4_cen == 0 & _n == _N // exit with a daugther
        tab t, gen(d)
        // EXITS WITH BIRTH ONLY (NON-CENSORED)
        dis " All "
        tab b4_space if birth == 1 | birth == 2
        tab b4_space gu_group if birth == 1 | birth == 2
        tab t if b4_cen == 0
        
        // PIECE-WISE LINEAR HAZARDS
        loc i = 1
        forvalues per = 1(3)2 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 2 // half years
            loc i = `i' + 1
        }
        forvalues per = 4(4)8 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 3 // half years
            loc i = `i' + 1
        }
        gen dur`i' = t >= 12 & t <= 19
        loc i = `i' + 1
        
        loc i = `i' - 1
        
        egen sumdur = rowtotal(dur*)
        assert sumdur == 1
        
        // NON-PROPORTIONALITY
        foreach var of var ///
        girl1 girl2 girl3 urban girl1Xurban girl2Xurban girl3Xurban {
            forval x = 1/`i' {
                gen np`x'X`var'  = dur`x' * `var' 
            }
        }
        
        loc np "  np*X* "
        
        // ESTIMATION
        eststo clear
        eststo: mlogit birth dur* $b1space ///
            $parents $hh $caste `np'  ///
            , baseoutcome(2) noconstant 

        local names : colfullnames e(b)
        estimates notes: `names'
        estimates notes: $lastm
        estimates save `data'/results_spell4_g`group'_med, replace

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



