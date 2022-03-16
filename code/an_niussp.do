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
/* LOADING DATA AND CREATING NEW VARIABLES                           */
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
    lowess percent_boys_nfhs year, bw(0.7) yaxis(1)  ytitle("Sex Ratio (% Boys)", axis(1)) || ///
	line sp_dyn_tfrt_in year, yaxis(2)  ytitle("Total Fertility Rate", axis(2))  || ///
    , legend(label(1 "Sex Ratio for Hindu Women") label(2 "Total Fertility Rate for India") ring(0)) ///
    yscale(r(0 6) axis(2)) yscale(r(50 53) axis(1)) ///
    ylabel(0(1)6, axis(2)) ylabel(50(0.5)53, axis(1)) ///
    plotregion(margin(zero)) yline(51.2195122, axis(1)) ///
    note("Sources: World Bank Open Databases and National Family and Health Surveys 1 through 4") ///
    text(51.1 1972 "Natural sex ratio", yaxis(1) color(gs8) placement(east))


graph export `figures'/n_iussp_sr_tfr.pdf, replace fontface(Palatino) 



