* Descriptive statistics for all regressions

version 13.1
clear all
set more off
file close _all

include directories


/*-------------------------------------------------------------------*/
/* LOADING DATA AND CREATING NEW VARIABLES                           */
/*-------------------------------------------------------------------*/

use `data'/base

keep if hindu 
drop if observation_age_m >= 22 & round == 1
drop if observation_age_m >= 22 & round == 2
drop if observation_age_m >= 22 & round == 3
drop if observation_age_m >= 22 & round == 4

lab var land_own "Owns land"

gen b0_born_year = int((marriage_cmc-1)/12)
gen b1_born_year = int((b1_born_cmc-1)/12) if fertility >= 1
gen b2_born_year = int((b2_born_cmc-1)/12) if fertility >= 2
gen b3_born_year = int((b3_born_cmc-1)/12) if fertility >= 3

// Total sample for paper
count
loc num = `r(N)'

loc births = 0
forvalues fer = 1/3 {
    count if fertility == `fer'
    loc births = `births' + `r(N)' * `fer'
}
count if fertility >= 4
loc births = `births' + `r(N)' * 4

// Automatically generated text for sample size (~ line 650 in tex file)
file open num_women using `tables'/num_women.tex, write replace
file write num_women  %9.0fc (`num') " women, with " %9.0fc (`births') " parity one through four births."
file close num_women

// Automatically generated footnote text for excluded observed births for 
// spell period (~ line 680 in tex file)
file open num_missed using `tables'/num_missed.tex, write replace
file write num_missed "The cut-offs are determined not by the total number of births," _n
file write num_missed "but by how many that occur in each three months period." _n
file write num_missed "If there are too few births, the multinomial logit estimations will not converge." _n
file close num_missed


// Beginning of descriptive stat table data generation

gen edu_group = 1 if edu_mother == 0
replace edu_group = 2 if edu_mother >= 1 & edu_mother <= 7
replace edu_group = 3 if edu_mother >= 8 & edu_mother <= 11
replace edu_group = 4 if edu_mother >= 12

replace scheduled_caste = 1 if scheduled_tribe

gen edu_group_low  = edu_group if edu_group < 3
gen edu_group_high = edu_group if edu_group > 2


//------------------------------//
// Education groups 1 and 2     //
//------------------------------//

* SPELL 2

preserve
keep if fertility >= 1
create_groups b1_born_year


gen mom_age    = b2_mom_age

// Distribution of births
tab b2_space if b2_sex != .
sum b2_space if b2_sex != .
loc max_month = `r(max)'

gen b1space = b1_space

// Sterilization and censoring
gen cen_sterilisation = b1_born_cmc + b2_space == sterilisation & ///
    sterilisation != . & b2_space <= 105 & fertility == 1
    
sum cen_sterilisation    
table edu_group group urban , cont(mean cen_sterilisation) 

bysort edu_group group: tab b2_space if cen_sterilisation


// Converting to 3 months intervals
drop if b2_space == .
replace b2_space = int((b2_space)/3) + 1 // 0-2 first quarter, 3-5 second, etc - now 9 months is **not** dropped
loc lastm = 4*8+3 //
replace b2_cen = 1 if b2_space > `lastm' // cut off 
replace b2_space = `lastm' if b2_space > `lastm'
replace b2_space = b2_space - 3 // start when pregnancy can occur
global lastm = `lastm'-3
drop if b2_space < 1

gen boy = b2_sex == 1 & !b2_cen
gen girl = b2_sex == 2 & !b2_cen

// Censoring
tab b2_cen b2_sex, col
sum b2_cen if b2_sex != .
loc percent = `r(mean)' * 100
loc total = `r(N)'
count if b2_cen & b2_sex != .
loc missed = `r(N)'
file open num_missed using `tables'/num_missed.tex, write append
file write num_missed "For spell 2, " %9.2fc (`percent') "\%, or " %9.0fc (`missed') " births," _n
file write num_missed "of a total of " %9.0fc (`total') " births are observed after 105 months from the first birth, " _n
file write num_missed "with the highest observed duration " %9.0fc (`max_month') " months." _n
file close num_missed


gen b1_girl = b1_sex == 2 if b1_sex != .
gen b1_boy  = b1_sex == 1 if b1_sex != .

lab var boy     "Boy born"
lab var girl    "Girl born"
lab var b2_cen  "Censored"
lab var b1_boy  "1 boy"
lab var b1_girl "1 girl"
lab var urban   "Urban"
lab var b1_space "First spell length"
lab var mom_age "Age"
lab var scheduled_caste "Sched.\ caste/tribe "

// LaTeX intro part for table
file open stats using `tables'/des_stat.tex, write replace

file write stats "\begin{table}[htp]" _n
file write stats "\begin{center}" _n
file write stats "\begin{tiny}" _n
file write stats "\begin{threeparttable}" _n
file write stats "\caption{Descriptive Statistics by Education Level and Beginning of Spell For Two Lowest Education Levels}" _n
file write stats "\label{tab:des_stat1}" _n
file write stats "\begin{tabular} {@{} c l D{.}{.}{1.3} D{.}{.}{1.3} D{.}{.}{1.3}  D{.}{.}{1.3} D{.}{.}{1.3} D{.}{.}{1.3} D{.}{.}{1.3} D{.}{.}{1.3}  @{}} \toprule" _n
file write stats "                    &                     & \multicolumn{4}{c}{No Education}                            & \multicolumn{4}{c}{1--7 Years of Education}                 \\ \cmidrule(lr){3-6} \cmidrule(lr){7-10} " _n
file write stats "                    &                     & \mco{1972--}  & \mco{1985--}  & \mco{1995--} & \mco{2005--} & \mco{1972--}  & \mco{1985--}  & \mco{1995--} & \mco{2005--} \\ " _n
file write stats "                    &                     & \mco{1984}    & \mco{1994}    & \mco{2004}   & \mco{2016}   & \mco{1984}    & \mco{1994}    & \mco{2004}   & \mco{2016}   \\ " _n
file write stats "\midrule" _n
file write stats "\multirow{22}{*}{\rotatebox{90}{Second Spell}}" _n
file close stats

eststo clear
bysort edu_group_low group: eststo: estpost sum boy girl b2_cen ///
    b1_boy b1_girl urban mom_age land_own scheduled_caste
esttab using `tables'/des_stat.tex, ///
    main(mean %9.3fc) aux(sd %9.3fc) noobs label nonotes nogaps ///
    fragment nomtitles nonumber append nolines begin("                    &")

// Direct version of number of quarters and observations
file open stats using `tables'/des_stat.tex, write append
file write stats "                    & 3 months periods "
forvalues edu = 1/2 {
    forvalues per = 1/4 {
        qui sum b2_space if edu_group == `edu' & group == `per'
        file write stats "& \mco{" %9.0fc (`r(sum)') "}     "
    }
}
file write stats " \\" _n 

file write stats "                    & Women    "
forvalues edu = 1/2 {
    forvalues per = 1/4 {
        qui sum b2_space if edu_group == `edu' & group == `per'
        file write stats "& \mco{" %9.0fc (`r(N)') "}     "
    }
}
file write stats " \\" _n 
file write stats "\addlinespace" _n
file write stats "\midrule" _n

file close stats

restore

// Second table


* SPELL 3

preserve
keep if fertility >= 2
create_groups b2_born_year

gen mom_age    = b3_mom_age
gen b1space = b1_space

// Distribution of births
tab b3_space if b3_sex != .
sum b3_space if b3_sex != .
loc max_month = `r(max)'

// Sterilization and censoring
gen cen_sterilisation = b2_born_cmc + b3_space == sterilisation & ///
    sterilisation != . & b3_space <= 105 & fertility == 2
    
sum cen_sterilisation
table edu_group group urban, cont(mean cen_sterilisation) 

bysort edu_group group: tab b3_space if cen_sterilisation


// Converting to 3 months intervals
drop if b3_space == .
replace b3_space = int((b3_space)/3) + 1 // 0-2 first quarter, 3-5 second, etc - now 9 months is **not** dropped
loc lastm = 4*8+3 //
replace b3_cen = 1 if b3_space > `lastm' // cut off 
replace b3_space = `lastm' if b3_space > `lastm'
replace b3_space = b3_space - 3 // start when pregnancy can occur
global lastm = `lastm'-3
drop if b3_space < 1

gen boy = b3_sex == 1 & !b3_cen
gen girl = b3_sex == 2 & !b3_cen

// Censoring
tab b3_cen b3_sex, col
sum b3_cen if b3_sex != .
loc percent = `r(mean)' * 100
loc total = `r(N)'
count if b3_cen & b3_sex != .
loc missed = `r(N)'
file open num_missed using `tables'/num_missed.tex, write append
file write num_missed "For spell 3, " %9.2fc (`percent') "\%, or " %9.0fc (`missed') " births," _n
file write num_missed "of a total of " %9.0fc (`total') " births are observed after 105 months from the second birth, " _n
file write num_missed "with the highest observed duration " %9.0fc (`max_month') " months." _n
file close num_missed


egen numgirls = anycount(b1_sex b2_sex) if b1_sex != . & b2_sex != ., v(2)
gen b2_2b   = numgirls == 0
gen b2_1b1g = numgirls == 1
gen b2_2g   = numgirls == 2

lab var boy     "Boy born"
lab var girl    "Girl born"
lab var b3_cen  "Censored"
lab var b2_2b   "2 boys"
lab var b2_1b1g "1 boy, 1 girl"
lab var b2_2g   "2 girls"
lab var urban   "Urban"
lab var b1_space "First spell length"
lab var mom_age "Age"
lab var scheduled_caste "Sched.\ caste/tribe "

// LaTeX intro part for table
file open stats using `tables'/des_stat.tex, write append
file write stats "\multirow{24}{*}{\rotatebox{90}{Third Spell}}" _n
file close stats

eststo clear
bysort edu_group_low group: eststo: estpost sum boy girl b3_cen ///
    b2_2b b2_1b1g b2_2g urban mom_age land_own scheduled_caste
esttab using `tables'/des_stat.tex, ///
    main(mean %9.3fc) aux(sd %9.3fc) noobs label nonotes nogaps ///
    fragment nomtitles nonumber append nolines begin("                    &")

// Direct version of number of quarters and observations
file open stats using `tables'/des_stat.tex, write append
file write stats "                    & 3 months periods "
forvalues edu = 1/2 {
    forvalues per = 1/4 {
        qui sum b3_space if edu_group == `edu' & group == `per'
        file write stats "& \mco{" %9.0fc (`r(sum)') "}     "
    }
}
file write stats " \\" _n 

file write stats "                    & Women    "
forvalues edu = 1/2 {
    forvalues per = 1/4 {
        qui sum b3_space if edu_group == `edu' & group == `per'
        file write stats "& \mco{" %9.0fc (`r(N)') "}     "
    }
}
file write stats " \\" _n 
file write stats "\addlinespace" _n
file write stats "\midrule" _n

file close stats

restore

* SPELL 4

preserve
keep if fertility >= 3
create_groups b3_born_year

gen mom_age    = b4_mom_age
gen b1space = b1_space

// Distribution of births
tab b4_space if b4_sex != .
sum b4_space if b4_sex != .
loc max_month = `r(max)'

// Sterilization and censoring
gen cen_sterilisation = b3_born_cmc + b4_space == sterilisation & ///
    sterilisation != . & b4_space <= 105 & fertility == 3
    
sum cen_sterilisation
table edu_group group urban, cont(mean cen_sterilisation) 

bysort edu_group group: tab b4_space if cen_sterilisation

// Converting to 3 months intervals
drop if b4_space == .
replace b4_space = int((b4_space)/3) + 1 // 0-2 first quarter, 3-5 second, etc - now 9 months is **not** dropped
loc lastm = 4*8+3
replace b4_cen = 1 if b4_space > `lastm' // cut off 
replace b4_space = `lastm' if b4_space > `lastm'
replace b4_space = b4_space - 3 // start when pregnancy can occur
global lastm = `lastm'-3
drop if b4_space < 1

gen boy = b4_sex == 1 & !b4_cen
gen girl = b4_sex == 2 & !b4_cen

// Censoring
tab b4_cen b4_sex, col  
sum b4_cen if b4_sex != .
loc percent = `r(mean)' * 100
loc total = `r(N)'
count if b4_cen & b4_sex != .
loc missed = `r(N)'
file open num_missed using `tables'/num_missed.tex, write append
file write num_missed "For spell 4, " %9.2fc (`percent') "\%, or " %9.0fc (`missed') " births," _n
file write num_missed "of a total of " %9.0fc (`total') " births are observed after 105 months from the third birth, " _n
file write num_missed "with the highest observed duration " %9.0fc (`max_month') " months." _n
file close num_missed


egen numgirls = anycount(b1_sex b2_sex b3_sex) if b1_sex != . & b2_sex != . & b3_sex != ., v(2)
gen girl0 = numgirls == 0 if b1_sex != . & b2_sex != . & b3_sex != .
gen girl1 = numgirls == 1 if b1_sex != . & b2_sex != . & b3_sex != .
gen girl2 = numgirls == 2 if b1_sex != . & b2_sex != . & b3_sex != .
gen girl3 = numgirls == 3 if b1_sex != . & b2_sex != . & b3_sex != .

lab var boy     "Boy born"
lab var girl    "Girl born"
lab var b4_cen  "Censored"
lab var girl0   "3 boys"
lab var girl1   "2 boys, 1 girl"
lab var girl2   "1 boys, 2 girls"
lab var girl3   "3 girls"
lab var urban   "Urban"
lab var b1_space "First spell length"
lab var mom_age "Age"
lab var scheduled_caste "Sched.\ caste/tribe "

file open stats using `tables'/des_stat.tex, write append
file write stats "\multirow{26}{*}{\rotatebox{90}{Fourth Spell}}" _n
file close stats


eststo clear
bysort edu_group_low group: eststo: estpost sum boy girl b4_cen ///
    girl0-girl3 urban mom_age land_own scheduled_caste
esttab using `tables'/des_stat.tex, ///
    main(mean %9.3fc) aux(sd %9.3fc) noobs label nonotes nogaps ///
    fragment nomtitles nonumber append nolines begin("                    &")


// Direct version of number of quarters and observations
file open stats using `tables'/des_stat.tex, write append
file write stats "                    & 3 months periods "
forvalues edu = 1/2 {
    forvalues per = 1/4 {
        qui sum b4_space if edu_group == `edu' & group == `per'
        file write stats "& \mco{" %9.0fc (`r(sum)') "}     "
    }
}
file write stats " \\" _n 

file write stats "                    & Women    "
forvalues edu = 1/2 {
    forvalues per = 1/4 {
        qui sum b4_space if edu_group == `edu' & group == `per'
        file write stats "& \mco{" %9.0fc (`r(N)') "}     "
    }
}
file write stats " \\" _n 

// End of table
file write stats "\bottomrule" _n
file write stats "\end{tabular}" _n
file write stats "\begin{tablenotes} \tiny" _n
file write stats "\item \hspace*{-0.7em} \textbf{Note.}" _n
file write stats "Means without parentheses and standard deviation in parentheses." _n
file write stats "Interactions between variables and baseline hazard dummies not shown." _n
// file write stats "Quarters refer to number of 3 month periods observed." _n
file write stats "\end{tablenotes}" _n
file write stats "\end{threeparttable}" _n
file write stats "\end{tiny}" _n
file write stats "\end{center}" _n
file write stats "\end{table}" _n

file close stats

restore


//---------------------------//
// Education groups 3 and 4  //
//---------------------------//


* SPELL 2

preserve
keep if fertility >= 1
create_groups b1_born_year


gen mom_age    = b2_mom_age

// Distribution of births
tab b2_space if b2_sex != .
sum b2_space if b2_sex != .
loc max_month = `r(max)'

gen b1space = b1_space

// Converting to 3 months intervals
drop if b2_space == .
replace b2_space = int((b2_space)/3) + 1 // 0-2 first quarter, 3-5 second, etc - now 9 months is **not** dropped
loc lastm = 4*8+3 //
replace b2_cen = 1 if b2_space > `lastm' // cut off 
replace b2_space = `lastm' if b2_space > `lastm'
replace b2_space = b2_space - 3 // start when pregnancy can occur
global lastm = `lastm'-3
drop if b2_space < 1

gen boy = b2_sex == 1 & !b2_cen
gen girl = b2_sex == 2 & !b2_cen

// Censoring
tab b2_cen b2_sex, col
sum b2_cen if b2_sex != .
loc percent = `r(mean)' * 100
loc total = `r(N)'
count if b2_cen & b2_sex != .
loc missed = `r(N)'
file open num_missed using `tables'/num_missed.tex, write append
file write num_missed "For spell 2, " %9.2fc (`percent') "\%, or " %9.0fc (`missed') " births," _n
file write num_missed "of a total of " %9.0fc (`total') " births are observed after 105 months from the first birth, " _n
file write num_missed "with the highest observed duration " %9.0fc (`max_month') " months." _n
file close num_missed


gen b1_girl = b1_sex == 2 if b1_sex != .
gen b1_boy  = b1_sex == 1 if b1_sex != .

lab var boy     "Boy born"
lab var girl    "Girl born"
lab var b2_cen  "Censored"
lab var b1_boy  "1 boy"
lab var b1_girl "1 girl"
lab var urban   "Urban"
lab var b1_space "First spell length"
lab var mom_age "Age"
lab var scheduled_caste "Sched.\ caste/tribe "

// LaTeX intro part for table
file open stats using `tables'/des_stat.tex, write append

file write stats _n
file write stats _n
file write stats _n

file write stats "\begin{table}[htp]" _n
file write stats "\begin{center}" _n
file write stats "\begin{tiny}" _n
file write stats "\begin{threeparttable}" _n
file write stats "\caption{Descriptive Statistics by Education Level and Beginning of Spell for Two Highest Education Levels}" _n
file write stats "\label{tab:des_stat2}" _n
file write stats "\begin{tabular} {@{} c l D{.}{.}{1.3} D{.}{.}{1.3} D{.}{.}{1.3}  D{.}{.}{1.3} D{.}{.}{1.3} D{.}{.}{1.3} D{.}{.}{1.3} D{.}{.}{1.3}  @{}} \toprule" _n
file write stats "                    &                     & \multicolumn{4}{c}{8--11 Years of Education}                & \multicolumn{4}{c}{12+ Years of Education}                  \\ \cmidrule(lr){3-6} \cmidrule(lr){7-10} " _n
file write stats "                    &                     & \mco{1972--}  & \mco{1985--}  & \mco{1995--} & \mco{2005--} & \mco{1972--}  & \mco{1985--}  & \mco{1995--} & \mco{2005--} \\ " _n
file write stats "                    &                     & \mco{1984}    & \mco{1994}    & \mco{2004}   & \mco{2016}   & \mco{1984}    & \mco{1994}    & \mco{2004}   & \mco{2016}   \\ " _n
file write stats "\midrule" _n
file write stats "\multirow{22}{*}{\rotatebox{90}{Second Spell}}" _n
file close stats

eststo clear
bysort edu_group_high group: eststo: estpost sum boy girl b2_cen ///
    b1_boy b1_girl urban mom_age land_own scheduled_caste
esttab using `tables'/des_stat.tex, ///
    main(mean %9.3fc) aux(sd %9.3fc) noobs label nonotes nogaps ///
    fragment nomtitles nonumber append nolines begin("                    &")

// Direct version of number of quarters and observations
file open stats using `tables'/des_stat.tex, write append
file write stats "                    & 3 months periods "
forvalues edu = 3/4 {
    forvalues per = 1/4 {
        qui sum b2_space if edu_group == `edu' & group == `per'
        file write stats "& \mco{" %9.0fc (`r(sum)') "}     "
    }
}
file write stats " \\" _n 

file write stats "                    & Women    "
forvalues edu = 3/4 {
    forvalues per = 1/4 {
        qui sum b2_space if edu_group == `edu' & group == `per'
        file write stats "& \mco{" %9.0fc (`r(N)') "}     "
    }
}
file write stats " \\" _n 
file write stats "\addlinespace" _n
file write stats "\midrule" _n

file close stats

restore

// Second table


* SPELL 3

preserve
keep if fertility >= 2
create_groups b2_born_year

gen mom_age    = b3_mom_age
gen b1space = b1_space

// Distribution of births
tab b3_space if b3_sex != .
sum b3_space if b3_sex != .
loc max_month = `r(max)'

// Converting to 3 months intervals
drop if b3_space == .
replace b3_space = int((b3_space)/3) + 1 // 0-2 first quarter, 3-5 second, etc - now 9 months is **not** dropped
loc lastm = 4*8+3 //
replace b3_cen = 1 if b3_space > `lastm' // cut off 
replace b3_space = `lastm' if b3_space > `lastm'
replace b3_space = b3_space - 3 // start when pregnancy can occur
global lastm = `lastm'-3
drop if b3_space < 1

gen boy = b3_sex == 1 & !b3_cen
gen girl = b3_sex == 2 & !b3_cen

// Censoring
tab b3_cen b3_sex, col
sum b3_cen if b3_sex != .
loc percent = `r(mean)' * 100
loc total = `r(N)'
count if b3_cen & b3_sex != .
loc missed = `r(N)'
file open num_missed using `tables'/num_missed.tex, write append
file write num_missed "For spell 3, " %9.2fc (`percent') "\%, or " %9.0fc (`missed') " births," _n
file write num_missed "of a total of " %9.0fc (`total') " births are observed after 105 months from the second birth, " _n
file write num_missed "with the highest observed duration " %9.0fc (`max_month') " months." _n
file close num_missed


egen numgirls = anycount(b1_sex b2_sex) if b1_sex != . & b2_sex != ., v(2)
gen b2_2b   = numgirls == 0
gen b2_1b1g = numgirls == 1
gen b2_2g   = numgirls == 2

lab var boy     "Boy born"
lab var girl    "Girl born"
lab var b3_cen  "Censored"
lab var b2_2b   "2 boys"
lab var b2_1b1g "1 boy, 1 girl"
lab var b2_2g   "2 girls"
lab var urban   "Urban"
lab var b1_space "First spell length"
lab var mom_age "Age"
lab var scheduled_caste "Sched.\ caste/tribe "

// LaTeX intro part for table
file open stats using `tables'/des_stat.tex, write append
file write stats "\multirow{24}{*}{\rotatebox{90}{Third Spell}}" _n
file close stats

eststo clear
bysort edu_group_high group: eststo: estpost sum boy girl b3_cen ///
    b2_2b b2_1b1g b2_2g urban mom_age land_own scheduled_caste
esttab using `tables'/des_stat.tex, ///
    main(mean %9.3fc) aux(sd %9.3fc) noobs label nonotes nogaps ///
    fragment nomtitles nonumber append nolines begin("                    &")

// Direct version of number of quarters and observations
file open stats using `tables'/des_stat.tex, write append
file write stats "                    & 3 months periods "
forvalues edu = 3/4 {
    forvalues per = 1/4 {
        qui sum b3_space if edu_group == `edu' & group == `per'
        file write stats "& \mco{" %9.0fc (`r(sum)') "}     "
    }
}
file write stats " \\" _n 

file write stats "                    & Women    "
forvalues edu = 3/4 {
    forvalues per = 1/4 {
        qui sum b3_space if edu_group == `edu' & group == `per'
        file write stats "& \mco{" %9.0fc (`r(N)') "}     "
    }
}
file write stats " \\" _n 
file write stats "\addlinespace" _n
file write stats "\midrule" _n

file close stats

restore

* SPELL 4

preserve
keep if fertility >= 3
create_groups b3_born_year

gen mom_age    = b4_mom_age
gen b1space = b1_space

// Distribution of births
tab b4_space if b4_sex != .
sum b4_space if b4_sex != .
loc max_month = `r(max)'

// Converting to 3 months intervals
drop if b4_space == .
replace b4_space = int((b4_space)/3) + 1 // 0-2 first quarter, 3-5 second, etc - now 9 months is **not** dropped
loc lastm = 4*8+3
replace b4_cen = 1 if b4_space > `lastm' // cut off 
replace b4_space = `lastm' if b4_space > `lastm'
replace b4_space = b4_space - 3 // start when pregnancy can occur
global lastm = `lastm'-3
drop if b4_space < 1

gen boy = b4_sex == 1 & !b4_cen
gen girl = b4_sex == 2 & !b4_cen

// Censoring
tab b4_cen b4_sex, col  
sum b4_cen if b4_sex != .
loc percent = `r(mean)' * 100
loc total = `r(N)'
count if b4_cen & b4_sex != .
loc missed = `r(N)'
file open num_missed using `tables'/num_missed.tex, write append
file write num_missed "For spell 4, " %9.2fc (`percent') "\%, or " %9.0fc (`missed') " births," _n
file write num_missed "of a total of " %9.0fc (`total') " births are observed after 105 months from the third birth, " _n
file write num_missed "with the highest observed duration " %9.0fc (`max_month') " months." _n
file close num_missed


egen numgirls = anycount(b1_sex b2_sex b3_sex) if b1_sex != . & b2_sex != . & b3_sex != ., v(2)
gen girl0 = numgirls == 0 if b1_sex != . & b2_sex != . & b3_sex != .
gen girl1 = numgirls == 1 if b1_sex != . & b2_sex != . & b3_sex != .
gen girl2 = numgirls == 2 if b1_sex != . & b2_sex != . & b3_sex != .
gen girl3 = numgirls == 3 if b1_sex != . & b2_sex != . & b3_sex != .

lab var boy     "Boy born"
lab var girl    "Girl born"
lab var b4_cen  "Censored"
lab var girl0   "3 boys"
lab var girl1   "2 boys, 1 girl"
lab var girl2   "1 boys, 2 girls"
lab var girl3   "3 girls"
lab var urban   "Urban"
lab var b1_space "First spell length"
lab var mom_age "Age"
lab var scheduled_caste "Sched.\ caste/tribe "

file open stats using `tables'/des_stat.tex, write append
file write stats "\multirow{26}{*}{\rotatebox{90}{Fourth Spell}}" _n
file close stats


eststo clear
bysort edu_group_high group: eststo: estpost sum boy girl b4_cen ///
    girl0-girl3 urban mom_age land_own scheduled_caste
esttab using `tables'/des_stat.tex, ///
    main(mean %9.3fc) aux(sd %9.3fc) noobs label nonotes nogaps ///
    fragment nomtitles nonumber append nolines begin("                    &")


// Direct version of number of quarters and observations
file open stats using `tables'/des_stat.tex, write append
file write stats "                    & 3 months periods "
forvalues edu = 3/4 {
    forvalues per = 1/4 {
        qui sum b4_space if edu_group == `edu' & group == `per'
        file write stats "& \mco{" %9.0fc (`r(sum)') "}     "
    }
}
file write stats " \\" _n 

file write stats "                    & Women    "
forvalues edu = 3/4 {
    forvalues per = 1/4 {
        qui sum b4_space if edu_group == `edu' & group == `per'
        file write stats "& \mco{" %9.0fc (`r(N)') "}     "
    }
}
file write stats " \\" _n 

// End of table
file write stats "\bottomrule" _n
file write stats "\end{tabular}" _n
file write stats "\begin{tablenotes} \tiny" _n
file write stats "\item \hspace*{-0.7em} \textbf{Note.}" _n
file write stats "Means without parentheses and standard deviation in parentheses." _n
file write stats "Interactions between variables and baseline hazard dummies not shown." _n
// file write stats "Quarters refer to number of 3 month periods observed." _n
file write stats "\end{tablenotes}" _n
file write stats "\end{threeparttable}" _n
file write stats "\end{tiny}" _n
file write stats "\end{center}" _n
file write stats "\end{table}" _n

file close stats

restore


