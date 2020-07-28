// Simulation of median birth intervals

clear all

set obs 150
gen month = _n

loc prob_concept = 0.02
loc boy_ratio = 0.512


// Without abortion
gen double survival = 100-100 * `prob_concept' if _n == 1
replace survival = survival[_n-1] - survival[_n-1] * `prob_concept' if _n > 1

gen boys = 100 * `prob_concept' * `boy_ratio' if _n == 1
replace boys = survival[_n-1] * `prob_concept' * `boy_ratio' if _n > 1
gen cum_boys = sum(boys)

gen girls = 100 * `prob_concept' * (1 - `boy_ratio') if _n == 1
replace girls = survival[_n-1] * `prob_concept' * (1 - `boy_ratio') if _n > 1
gen cum_girls = sum(girls)


// With abortion
loc abort_rate = 0.3 // out of girls conceived
gen double abort_survival = 100 - (100 * `prob_concept' - 100 * `prob_concept' * (1 - `boy_ratio') * `abort_rate') if _n == 1
replace abort_survival = abort_survival[_n-1] - (abort_survival[_n-1] * `prob_concept' - abort_survival[_n-1] * `prob_concept' * (1 - `boy_ratio') * `abort_rate') if _n > 1

gen abort_boys = 100 * `prob_concept' * `boy_ratio' if _n == 1
replace abort_boys = abort_survival[_n-1] * `prob_concept' * `boy_ratio' if _n > 1
gen abort_cum_boys = sum(abort_boys)

gen abort_girls = 100 * `prob_concept' * (1 - `boy_ratio') * (1 - `abort_rate') if _n == 1
replace abort_girls = abort_survival[_n-1] * `prob_concept' * (1 - `boy_ratio') * (1- `abort_rate') if _n > 1
gen abort_cum_girls = sum(abort_girls)


// Identify percentiles and calculate ratios
// Because of survival percentiles run in "opposite" direction
foreach var of varlist survival abort_survival {
	foreach percent of numlist 25 50 75 {
		gen double p`percent'_`var' = month - ((`percent' - `var') / (`var'[_n-1] - `var')) ///
			if `var' < `percent' & `var'[_n-1] > `percent'
		sum p`percent'_`var'
		loc p`percent'_`var' = `r(max)'
	}
}

foreach var of varlist survival abort_survival {
	dis "p50/p25: " `p50_`var'' / `p75_`var'' " p75/p25: " `p25_`var'' / `p75_`var''
	
}


