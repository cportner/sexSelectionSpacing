# Code

## Create data set for analysis

- crBase1.do: subset of NFHS-1, creates base1.dta
- crBase2.do: subset of NFHS-2, creates base2.dta
- crBase3.do: subset of NFHS-3, creates base3.dta
- crBase4.do: subset of NFHS-4, creates base4.dta
- crBase.do: Combines base1.dta, base2.dta, base3.dta, and base4.dta and ensures consistency

## Analysis files and their dependencies

- anDescStat.do: Creates descriptive statistics LaTeX file des_stat.tex
	|- base.dta
- run_analysis.ado: Runs regression model for spell, period, and education passed to it
- run_graphs.ado: Creates graphs for spell, period, and education passed to it
- an_bootstrap.do: Loop to run bootstrapping for predictions
	|- bootspell.do
	|- directories.do
	|- base.dta
	|- genSpell1.do
	|- genSpell2.do
	|- genSpell3.do
	|- genSpell4.do
- an_bootstrap_table.do: Outputs tables based on bootstrap results
- bootspell.do: Function for analysis of bootstrap sample passed to it

## LaTeX generation files

- gen_appendix_graphs.do: Generates LaTeX code for holding graphs
