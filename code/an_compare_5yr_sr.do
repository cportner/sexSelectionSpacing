// How does censoring affect observed sex ratios?
// Compare two five-year periods '05-'09 and '10-'14 using spell start
// and observed births for a spell/sex composition that generates
// increasing sex ratios within spell

include directories

use `data'/base, clear

keep if edu_mother >= 8

do genSpell3

gen b3_born_year = int((b3_born_cmc-1)/12)

// Grouping is based on b2_born_year although spell does not begin
// until 9 months later

// // 2000-2004 spell starts
// dis "2000-2004 spell starts"
// tab b3_sex if b2_born_year >= 100 & b2_born_year <= 104
// 
// tab b3_sex ///
//     if b2_born_year >= 100 & b2_born_year <= 104 ///
//     & b3_born_year >= 100 & b3_born_year <= 104

// 2005-2009 spell starts
dis "2005-2009 spell starts"
tab b3_sex if b2_born_year >= 105 & b2_born_year <= 109

tab b3_sex ///
    if b2_born_year >= 105 & b2_born_year <= 109 ///
    & b3_born_year >= 105 & b3_born_year <= 114

tab b3_sex ///
    if b2_born_year >= 105 & b2_born_year <= 109 ///
    & b3_born_year >= 105 & b3_born_year <= 109


// 2010-2014 spell starts
dis "2010-2014 spell starts"
// tab b3_sex if b2_born_year >= 110 & b2_born_year <= 114

tab b3_sex ///
    if b2_born_year >= 110 & b2_born_year <= 114 ///
    & b3_born_year >= 110 & b3_born_year <= 114


// Grouping based on 3rd birth 

tab b3_sex if b3_born_year >= 100 & b3_born_year <= 104

tab b3_sex if b3_born_year >= 105 & b3_born_year <= 109

tab b3_sex if b3_born_year >= 110 & b3_born_year <= 114


// Predictions based on regression results - hard coded for now

tab gu_group if b2_born_year >= 105 & b2_born_year <= 109

//              gu_group |      Freq.     Percent        Cum.
// ----------------------+-----------------------------------
//         Rural, 2 boys |      2,434       13.84       13.84
// Rural, 1 boy / 1 girl |      5,677       32.29       46.13
//        Rural, 2 girls |      2,795       15.90       62.03
//         Urban, 2 boys |      1,592        9.05       71.08
// Urban, 1 boy / 1 girl |      3,552       20.20       91.28
//        Urban, 2 girls |      1,533        8.72      100.00
// ----------------------+-----------------------------------
//                 Total |     17,583      100.00


loc boys = ///
    1533*0.5524*0.6556 + ///
    3552*0.2493*0.5584 + ///
    1592*0.2444*0.4849 + ///
    2795*0.7385*0.5977 + ///
    5677*0.4150*0.5352 + ///
    2434*0.3738*0.4920
    
loc kids = ///
    1533*0.5524 + ///
    3552*0.2493 + ///
    1592*0.2444 + ///
    2795*0.7385 + ///
    5677*0.4150 + ///
    2434*0.3738
     
loc sr = `boys'/`kids'

dis "Number of boys born: `boys'"
dis "Number of kids born: `kids'"
dis "Sex ration: `sr'"

tab gu_group if b2_born_year >= 110 & b2_born_year <= 114

//              gu_group |      Freq.     Percent        Cum.
// ----------------------+-----------------------------------
//         Rural, 2 boys |      2,986       14.72       14.72
// Rural, 1 boy / 1 girl |      7,133       35.17       49.89
//        Rural, 2 girls |      3,555       17.53       67.42
//         Urban, 2 boys |      1,552        7.65       75.07
// Urban, 1 boy / 1 girl |      3,406       16.79       91.86
//        Urban, 2 girls |      1,651        8.14      100.00
// ----------------------+-----------------------------------
//                 Total |     20,283      100.00


loc boys = ///
    1651*0.5524*0.6556 + ///
    3406*0.2493*0.5584 + ///
    1552*0.2444*0.4849 + ///
    3555*0.7385*0.5977 + ///
    7133*0.4150*0.5352 + ///
    2986*0.3738*0.4920
    
loc kids = ///
    1651*0.5524 + ///
    3406*0.2493 + ///
    1552*0.2444 + ///
    3555*0.7385 + ///
    7133*0.4150 + ///
    2986*0.3738

loc sr = `boys'/`kids'

dis "Number of boys born: `boys'"
dis "Number of kids born: `kids'"
dis "Sex ration: `sr'"


