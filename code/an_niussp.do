// Script for N-IUSSP article
// Assumes that you have wbopendata installed


clear all
version 15.1
set more off

file close _all // easier, in case something went wrong with last file write (Stata does not close files gracefully)
capture program drop _all

include directories
 
 
// Get background data

wbopendata, country(ind) indicator(SP.POP.BRTH.MF;SP.DYN.TFRT.IN) year(1972:2016) clear long

// Percent boys to ensure consistency across graphs
gen percent_boys = (sp_pop_brth_mf / (1 + sp_pop_brth_mf ))*100

// Graph TFR and percent boys

twoway ///
    line sp_dyn_tfrt_in year, yaxis(1)  ytitle("Total Fertility Rate") || ///
    line percent_boys year, yaxis(2)  ytitle("Sex Ratio (% Boys)", axis(2))

