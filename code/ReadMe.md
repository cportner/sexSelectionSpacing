# Code

## Stata

All code written for Stata 15.1.
The programs used the user-generated packages below (might not be a complete list).

- asgen (net install asgen.pkg)
- xfill (net from https://www.sealedenvelope.com/ and then install xfill)

The following user-generated packages are needed for the N-IUSSP article

- wbopendata (ssc install wbopendata [website](https://datahelpdesk.worldbank.org/knowledgebase/articles/889464-wbopendata-stata-module-to-access-world-bank-data))
- cleanplots (net install cleanplots, from("https://tdmize.github.io/data/cleanplots"))

## Create data set for analysis

- crBase1.do: subset of NFHS-1, creates base1.dta
- crBase2.do: subset of NFHS-2, creates base2.dta
- crBase3.do: subset of NFHS-3, creates base3.dta
- crBase4.do: subset of NFHS-4, creates base4.dta
- crBase.do: Combines base1.dta, base2.dta, base3.dta, and base4.dta and ensures consistency

## Analysis files and their dependencies

Many of the do files in this directory are no longer in active use, but are kept mainly for
"historical" reasons (and to serve as code snippet repositories).
The files below are those currently used for producing the paper.
Note that you really should use `make` to run these because otherwise it is easy to lose
track of what you have run and the downstream files depend on other files being run first.

```
- an_educ_over_time.do: Women's education over time in India
- anRecall.do: Produces tables for appendix recall section
- an_recall_graph.do: Produces figures for appendix recall section
- anDescStat.do: Creates appendix descriptive statistics LaTeX file des_stat.tex
- run_bootstrap.ado: Loop to run bootstrapping for predictions, called with spell, period, and education
	|- bootspell_all.do
	|- directories.do
	|- genSpell1.do
	|- genSpell2.do
	|- genSpell3.do
	|- genSpell4.do
- an_bootstrap_table_all.do: Outputs appendix tables based on bootstrap results
- an_bootstrap_graph_percentiles.do: Produces percentile spacing, sex ratio, and parity progression graphs for paper
- an_fertility_rate.do: Calculates the "TFR" based on first 4 parity births
- an_fertility_hazard.do: Runs hazard models and save estimation results
- an_fertility_hazard_predict.do: Calculates predicted fertility from hazard model
	|- an_fertility_hazard.do
- an_fertility_table.do: Produces table of fertility predictions for paper
	|- an_fertility_rate.do
	|- an_fertility_hazard.do
	|- an_fertility_hazard_predict.do
- an_infant_mortality.do: Runs logit model on infant mortality and produces figures
```
