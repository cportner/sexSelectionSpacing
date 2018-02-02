// Running through all combinations

foreach educ in "high" "med" "low" {
    forvalues spell = 1/4 {
        forvalues period = 1/4 {
            run_analysis `spell' `period' `educ'
            run_graphs `spell' `period' `educ'
        }
    }
}

