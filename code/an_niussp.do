// Script for N-IUSSP article
// Assumes that you have wbopendata installed


clear all
version 15.1
set more off

file close _all // easier, in case something went wrong with last file write (Stata does not close files gracefully)
capture program drop _all

include directories
set scheme cleanplots
 
// Try sex ratio from NFHS data



/*-------------------------------------------------------------------*/
/* LOADING BASE DATA AND CREATING NEW VARIABLES                      */
/*-------------------------------------------------------------------*/

use `data'/base

drop if observation_age_m >= 22 & round == 1
drop if observation_age_m >= 22 & round == 2
drop if observation_age_m >= 22 & round == 3
drop if observation_age_m >= 22 & round == 4

// 524,761 before / 395,695

// survey information
gen survey = round // Round is now calculated in crBase.do


/*-------------------------------------------------------------------*/
/* DEVELOPMENT IN SEX RATIOS							             */
/*-------------------------------------------------------------------*/

// prepares data for analysis
//preserve
keep round survey urban observation_age* mom_id b*_sex b*_born_cmc
reshape long b@_sex b@_born_cmc, i(mom_id) j(bo)
drop if b_sex == .
gen born_year = int((b_born_cmc-1)/12)+1900
// drop if born_year < `startyear'
recode b_sex (2=0)

collapse b_sex if born_year >= 1972, by(born_year)
rename born_year year
save `data'/tmp_sr.dta, replace

// Get World Bank data
wbopendata, country(ind) indicator(SP.POP.BRTH.MF;SP.DYN.TFRT.IN) year(1972:2016) clear long

merge 1:1 year using `data'/tmp_sr.dta
drop _merge

// Percent boys to ensure consistency across graphs
gen percent_boys_wb = (sp_pop_brth_mf / (1 + sp_pop_brth_mf ))*100
gen percent_boys_nfhs = b_sex * 100

// Graph TFR and percent boys

// The problem with using the WB data for sex ratio is that there is 
// substantial measurement error/recall bias. According to the WB
// data there is a above normal sex ratio at birth even in 1972, which
// is likely the result of mortality combined with recall error.
// One option is to use the DHS data I already cleaned. 

// With TFR as axis 1
// twoway line sp_dyn_tfrt_in year, yaxis(1)  ytitle("Total Fertility Rate")  || ///
//     line percent_boys year, yaxis(2)  ytitle("Sex Ratio (% Boys)", axis(2)) || ///
//     , legend(label(1 "Total Fertility Rate") label(2 "Sex Ratio") ring(0)) ///
//     yscale(r(0 6) axis(1)) yscale(r(50 53) axis(2)) ///
//     ylabel(0(1)6, axis(1)) ylabel(50(0.5)53, axis(2)) ///
//     plotregion(margin(zero)) yline(51.2195122, axis(2)) ///
//     note("Source: World Bank Open Databases") ///
//     text(51 1980 "Natural sex ratio", yaxis(2) color(gs8))


// Sex ratio as axis 1
// twoway ///
//     line percent_boys_wb year, yaxis(1)  ytitle("Sex Ratio (% Boys)", axis(1)) || ///
//     lowess percent_boys_nfhs year, yaxis(1)  ytitle("Sex Ratio (% Boys)", axis(1)) || ///
// 	line sp_dyn_tfrt_in year, yaxis(2)  ytitle("Total Fertility Rate", axis(2))  || ///
//     , legend(label(1 "Sex Ratio") label(2 "Total Fertility Rate") ring(0)) ///
//     yscale(r(0 6) axis(2)) yscale(r(50 53) axis(1)) ///
//     ylabel(0(1)6, axis(2)) ylabel(50(0.5)53, axis(1)) ///
//     plotregion(margin(zero)) yline(51.2195122, axis(1)) ///
//     note("Source: World Bank Open Databases") ///
//     text(51.1 1972 "Natural sex ratio", yaxis(1) color(gs8) placement(east))

twoway ///
    lowess percent_boys_nfhs year, bw(0.7) yaxis(1)  ytitle("Sex Ratio at Birth (% Boys)", axis(1) color(red*1.2)) || ///
	line sp_dyn_tfrt_in year, yaxis(2)  ytitle("Total Fertility Rate", axis(2) color(eltblue))  || ///
    , legend(label(1 "Sex Ratio for Hindu Women") label(2 "Total Fertility Rate for India") ring(0)) ///
    yscale(r(0 6) axis(2)) yscale(r(50 53) axis(1)) ///
    ylabel(0(1)6, axis(2)) ylabel(50(0.5)53, axis(1)) ///
    plotregion(margin(zero)) yline(51.2195122, axis(1)) ///
    note("Sources: World Bank Open Databases and National Family and Health Surveys 1 through 4") ///
    text(51.1 1972 "Natural sex ratio", yaxis(1) color(gs8) placement(east))


graph export `figures'/niussp_sr_tfr.pdf, replace fontface(Palatino) 



/*-------------------------------------------------------------------*/
/* REPRODUCE RESULTS PLOTS   							             */
/*-------------------------------------------------------------------*/

// set scheme s1mono

// cleanplots scheme seems to have smaller default legend key size, so try with larger symxsize(*2.8)

// This is based on code from an_bootstrap_graph_percentiles.do / an_bootstrap_graph_percentiles-typesetting.do

// Weird Stata behavior; you can write my_matrix[1,2], but not my_matrix[1,"var_name"]
// when you want to extract a scalar.
// Need to get col number first using variable name, then call matrix (grumble, grumble)
// program that takes a matrix and a name and returns the column number
capture program drop _all
program find_col, rclass
    args mat_name name
    local col_names : colfullnames `mat_name'
    tokenize `col_names'
    local i = 1
    local found = 0
    while "``i''" != "" & `found' == 0 {
        if "`name'" == "``i''" {
            return scalar col_num = `i' 
            local found = 1
        }
        local i = `i' + 1
    }
end

// Load bootstrap results and create matrices.
foreach educ in "low" "highest" {
	forvalues period = 1/4 {
		clear results // Stupid Stata - calling bstat after using the data does not clear old bstat
		use `data'/bs_s3_g`period'_`educ'_all, clear
		quietly bstat
	
		// Relevant matrices to extract
		// point estimates e(b)
		matrix b_s3_g`period'_`educ' = e(b)
    }
}


// Design choices:
// More likely to use sex selection -> more solid line
// Hence, 
// all girls: solid line, 
// one girl less: long dash
// two girls less: dash
// three girls less: short dash
// Always start with solid line, so if no children the line is solid
// All three graphs have same legend
// Only bottom graph (likelihood of next birth) have an x axis
// There are no confidence intervals in graphs (refer to tables for those)
 

// Generate line patterns - more solid to less solid as likelihood of ssa declines
loc pattern = ""                
forval i = 1/3 {
	if `i' == 1 loc pattern = "solid"
	if `i' == 2 loc pattern = "`pattern' longdash"
	if `i' == 3 loc pattern = "`pattern' dash"
	if `i' == 4 loc pattern = "`pattern' shortdash"
}
// Generate labels for legends
//local label "order(1 "2 Girls" 2 "1 Boy/" "1 Girl" 3 "2 Boys") cols(2) span "
local label "order(1 "2 Daughters" 2 "1 Son/" "1 Daughter" 3 "2 Sons") cols(2) span "
local title "Third Spell"
// Original
// local bi_title1 "{bf: 25th/50th/75th Percentile}" 
// local bi_title2 "{bf: Birth Intervals (months)}"
// local bi_title1 "{bf: 75th Percentile Birth}" 
// local bi_title2 "{bf: Intervals (months)}"
// local sr_title1 "{bf: Sex Ratio}" 
// local sr_title2 "{bf: (% Boys)}"
// local pp_title1 "{bf: Probability of}" 
// local pp_title2 "{bf: a Next Birth}"
// Without bold and only 75th 
local bi_title1 "75th Percentile Birth" 
local bi_title2 "Intervals (months)"
local sr_title1 "Sex Ratio of Third" 
local sr_title2 "Births (% Boys)"
local pp_title1 "Probability of" 
local pp_title2 "a Third Birth"
local fxsize    "fxsize(64)"

// Scales 
// loc spacing_low  = 18
// loc spacing_high = 72
loc spacing_low  = 36
loc spacing_high = 72
loc sr_low  = 30
loc sr_high = 80            


// Rural - low education
// Set up data from matrix
clear // Needed because we are generating new data sets based on matrices in svmat below
matrix tmp_mat = (1, b_s3_g1_low \ 2, b_s3_g2_low \ 3, b_s3_g3_low \  4, b_s3_g4_low)
svmat tmp_mat, names( col )

// Generate y variables in reverse order to match line pattern
foreach stat in "p25" "p50" "p75" "pct" "any" {
	loc `stat' = ""
	forval i = 3(-1)1 {
		loc g = `i' - 1
		loc `stat' = "``stat'' `stat'_rural_g`g' "
	}
}
			
twoway line `any' c1, sort ///
	lpattern(`pattern') lwidth(medthin..) ///
    legend(`label' symxsize(*2.8) size(vsmall) linegap(0.75) ring(1) position(12) region(margin(vsmall) lwidth(none)) colgap(1.5) keygap(0.5) symysize(6.5) forcesize subtitle("Rural Hindu Women With No" "Education — Prior Children:") ) ///				 
	plotregion(style(none)) ///
	xscale(off) ///
    xlabel( , nogextend) ///
	ytitle("`pp_title1'" "`pp_title2'", size(small)) ///
	yscale(range(0 1)) ///
	ylabel(0 ".00" 0.25 ".25" 0.50 ".50" 0.75 ".75" 1 "1.0", grid angle(0) labsize(*.84)) ///
	name(any_low, replace) fysize(100) `fxsize'

twoway line `pct' c1, sort ///
	lpattern(`pattern') lwidth(medthin..) ///
	legend(off) /// 
	plotregion(style(none)) ///
	xscale(off) ///
	ytitle("`sr_title1'" "`sr_title2'", size(small)) ///
	yscale(r(`sr_low' `sr_high')) ///
	ylabel(`sr_low'(10)`sr_high', grid angle(0)) ///
	yline(51.2195122, lcolor(gs10)) ///
	name(pct_low, replace) fysize(60) `fxsize'

twoway line `p25' c1, sort  ///
	lpattern(`pattern') lwidth(medthin..) ///
	 || ///
	 , name(interval_low, replace) ///
    legend(off) ///
	plotregion(style(none) margin(2 2 0 2)) ///	
	xtitle("Period") ///
	xlabel(1 `" "1972-" "1984" "' 2 `" "1985-" "1994" "' 3 `" "1995-" "2004" "' 4 `" "2005-" "2016" "') ///
    ytitle("`bi_title1'" "`bi_title2'", size(small)) ///
	yscale(r(`spacing_low' `spacing_high')) ///
	ylabel(`spacing_low'(6)`spacing_high' ,grid angle(0))  ///
	fysize(100) `fxsize'



// Urban - highest education
// Set up data from matrix
clear // Needed because we are generating new data sets based on matrices in svmat below
matrix tmp_mat = (1, b_s3_g1_highest \ 2, b_s3_g2_highest \ 3, b_s3_g3_highest \  4, b_s3_g4_highest)
svmat tmp_mat, names( col )

// Generate y variables in reverse order to match line pattern
foreach stat in "p25" "p50" "p75" "pct" "any" {
	loc `stat' = ""
	forval i = 3(-1)1 {
		loc g = `i' - 1
		loc `stat' = "``stat'' `stat'_urban_g`g' "
	}
}

twoway line `any' c1, sort ///
	lpattern(`pattern') lwidth(medthin..) ///
	legend(`label' symxsize(*2.8) size(vsmall) linegap(0.75) ring(1) position(12) region(margin(vsmall) lwidth(none)) colgap(1.5) keygap(0.5) symysize(6.5) forcesize subtitle("Urban Hindu Women With 12 or More" "Years of Education — Prior Children:" )) ///
	plotregion(style(none)) ///
	xscale(off) ///
    xlabel( , nogextend) ///
	ytitle("`pp_title1'" "`pp_title2'", size(small)) ///
	yscale(range(0 1)) ///
	ylabel(0 ".00" 0.25 ".25" 0.50 ".50" 0.75 ".75" 1 "1.0", grid angle(0) labsize(*.84)) ///
	name(any_highest, replace) fysize(100) `fxsize'
			
twoway line `pct' c1, sort ///
	lpattern(`pattern') lwidth(medthin..) ///
	legend(off) ///
	plotregion(style(none)) ///
	xscale(off) ///
	ytitle("`sr_title1'" "`sr_title2'", size(small)) ///
	yscale(r(`sr_low' `sr_high')) ///
	ylabel(`sr_low'(10)`sr_high', grid angle(0)) ///
	yline(51.2195122, lcolor(gs10)) ///
	name(pct_highest, replace) fysize(60) `fxsize'

twoway line `p25' c1, sort  ///
	lpattern(`pattern') lwidth(medthin..) ///
	 || ///
	 , name(interval_highest, replace) ///	
	legend(off) ///	
	plotregion(style(none) margin(2 2 0 2)) ///	
	xtitle("Period") ///
	xlabel(1 `" "1972-" "1984" "' 2 `" "1985-" "1994" "' 3 `" "1995-" "2004" "' 4 `" "2005-" "2016" "') ///
	ytitle("`bi_title1'" "`bi_title2'", size(small)) ///
	yscale(r(`spacing_low' `spacing_high')) ///
	ylabel(`spacing_low'(6)`spacing_high' ,grid angle(0))  ///
	fysize(100) `fxsize'



// Combine by variable first, then combine all variables    
gr combine any_low any_highest , ///
	row(1) ycommon  name(any, replace) fysize(40) imargin(0 2 0 0)

gr combine pct_low pct_highest , ///
	row(1) ycommon  name(pct, replace) fysize(25) imargin(0 2 0 0)

gr combine interval_low interval_highest , /// 
	row(1) ycommon name(interval, replace) fysize(40) imargin(0 2 0 0)

gr combine any pct interval , ///
	col(1) xcommon ysize(8) xsize(6.5) imargin(0 0 3 0) iscale(*1.2)

graph export `figures'/niussp_spell.pdf, replace fontface(Palatino) 










