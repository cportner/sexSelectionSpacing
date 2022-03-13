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
twoway ///
    line percent_boys year, yaxis(1)  ytitle("Sex Ratio (% Boys)", axis(1)) || ///
	line sp_dyn_tfrt_in year, yaxis(2)  ytitle("Total Fertility Rate", axis(2))  || ///
    , legend(label(1 "Sex Ratio") label(2 "Total Fertility Rate") ring(0)) ///
    yscale(r(0 6) axis(2)) yscale(r(50 53) axis(1)) ///
    ylabel(0(1)6, axis(2)) ylabel(50(0.5)53, axis(1)) ///
    plotregion(margin(zero)) yline(51.2195122, axis(1)) ///
    note("Source: World Bank Open Databases") ///
    text(51.1 1972 "Natural sex ratio", yaxis(1) color(gs8) placement(east))

graph export `figures'/n_iussp_sr_tfr.png, replace



