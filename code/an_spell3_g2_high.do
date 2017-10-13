* Women with high education (8+ years) for both urban and rural
* Competing Discrete Hazard model
* Third spell (from 2nd to 3rd birth)
* an_spell3_g2_high.do
* Begun.: 07/04/10
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

keep if edu_mother >= 8
local edgroup = "high"

// data manipulations
do genSpell3.do

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
        esttab using `tables'/mainObs_spell3_g`group'_`edgroup'.tex, replace ///
            cells("b(label(N))") ///
            nonumber nomtitle noobs
        eststo clear

        // GENERATE TIME VARIABLES
        expand b3_space 
        bysort id: gen t = _n
        // the b3_cen == 0 is needed since I restrict the duration to `lastm' above
        // b3_sex is the child born as end of spell 2
        gen byte birth = 0
        bysort id (t): replace birth = 1 if b3_sex == 1 & b3_cen == 0 & _n == _N // exit with a son
        bysort id (t): replace birth = 2 if b3_sex == 2 & b3_cen == 0 & _n == _N // exit with a daugther
        tab t, gen(d)
        // EXITS WITH BIRTH ONLY (NON-CENSORED)
        dis " All "
        tab b3_space if birth == 1 | birth == 2
        tab b3_space gu_group if birth == 1 | birth == 2
        tab t if b3_cen == 0
        
        // PIECE-WISE LINEAR HAZARDS
        loc i = 1
        forvalues per = 1(3)4 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 2 // 3 quarter years
            loc i = `i' + 1
        }
        forvalues per = 7(4)11 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 3 // 3 quarter years
            loc i = `i' + 1
        }
        forvalues per = 15(5)18 { // originally 14
            gen dur`i' = t >= `per' & t <= `per' + 4 // 3 quarter years
            loc i = `i' + 1
        }
        gen dur`i' = t >= 20 & t <= 24
        
        egen sumdur = rowtotal(dur*)
        assert sumdur == 1
        
        // NON-PROPORTIONALITY
        foreach var of var ///
        girl1 girl2 urban girl1Xurban girl2Xurban {
            forval x = 1/`i' {
                gen np`x'X`var'  = dur`x' * `var' 
            }
        }
        
        loc np "  np*X* "
        
        // ESTIMATION
        eststo clear
//         eststo: mlogit birth dur* $b1space ///
//             `parents' `hh' `religion' `caste' ///
//             urbanXedu*  ///
//             girl ///
//             girlsXedu* ///
//             girlsXurban ///
//             girlsXurbanXedu1 ///
//             np?XgirlsXurbanXedu2 ///
//             , baseoutcome(2) noconstant
// 
//         est store M1 
//    
//         local names : colfullnames e(b)
//         estimates notes: `names'
//         estimates notes: $lastm
//         estimates save `data'/results_spell2_g`group', replace

        eststo clear
//         eststo: mlogit birth dur* $b1space ///
//             `parents' `hh' `caste' `np' ///
//             , baseoutcome(2) noconstant 
//         est store M1 

        eststo: mlogit birth dur* $b1space ///
            $parents $hh $caste `np'  ///
            , baseoutcome(2) noconstant 

        local names : colfullnames e(b)
        estimates notes: `names'
        estimates notes: $lastm
        estimates save `data'/results_spell3_g`group'_high, replace

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


