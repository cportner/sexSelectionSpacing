### Makefile for Sex Selection and Birth Spacing Project        ###
### and tables are hardcoded into tex file          			###
### The non-generated figures are not included here 			###

### The reason for the weird set-up is to have Makefile 
### in base directory and run LaTeX in the paper directory 
### without leaving all the other files in the base directory

TEXFILE = sexSelectionSpacing-ver1
TEX  = ./paper
FIG  = ./figures
TAB  = ./tables
COD  = ./code
RAW  = ./rawData
DAT  = ./data

### LaTeX part

# need to add a bib file dependency to end of next line
$(TEX)/$(TEXFILE).pdf: $(TEX)/$(TEXFILE).tex $(TAB)/des_stat.tex $(FIG)/spell2_g3_high_r4_s.eps
	cd $(TEX); xelatex $(TEXFILE)
	cd $(TEX); bibtex $(TEXFILE)
	cd $(TEX); xelatex $(TEXFILE)
	cd $(TEX); xelatex $(TEXFILE)

.PHONY: view
view: $(TEX)/$(TEXFILE).pdf
	open -a Skim $(TEX)/$(TEXFILE).pdf & 


### Stata part         			                                ###

# Create base data set(s)
# Need "end" file as outcome, here the base data sets for each survey
$(DAT)/base1.dta: $(COD)/crBase1.do $(RAW)/iair23fl.dta $(RAW)/iawi22fl.dta $(RAW)/iahh21fl.dta
	cd $(COD); stata-se -b -q crBase1.do 
    
$(DAT)/base2.dta: $(COD)/crBase2.do $(RAW)/iair42fl.dta $(RAW)/iawi41fl.dta $(RAW)/iahr42fl.dta
	cd $(COD); stata-se -b -q crBase2.do 

$(DAT)/base3.dta: $(COD)/crBase3.do $(RAW)/iair52fl.dta 
	cd $(COD); stata-se -b -q crBase3.do 

$(DAT)/base.dta: $(COD)/crBase.do $(DAT)/base1.dta $(DAT)/base2.dta $(DAT)/base3.dta
	cd $(COD); stata-se -b -q crBase.do 

# Descriptive statistics
$(TAB)/des_stat.tex: $(DAT)/base.dta $(COD)/anDescStat.do
	cd $(COD); stata-se -b -q anDescStat.do
	
# Graph example
$(DAT)/results_spell2_g3_hindu_high.ster: $(DAT)/base.dta $(COD)/an_spell2_g3_hindu_high.do
	cd $(COD); stata-se -b -q an_spell2_g3_hindu_high.do 

$(FIG)/spell2_g3_high_r4_s.eps: $(DAT)/results_spell2_g3_hindu_high.ster $(COD)/an_spell2_g3_hindu_high_graphs.do 
	cd $(COD); stata-se -b -q an_spell2_g3_hindu_high_graphs.do

# Clean directories for (most) generated files
# This does not clean generated data files; mainly because I am a chicken
.PHONY: cleanall cleanfig cleantex cleancode
cleanall: cleanfig cleantex cleancode
	cd $(DAT); rm *.ster
	cd $(TAB); rm *.tex
	
cleanfig:
	cd $(FIG); rm *.eps
	
cleantex:
	cd $(TEX); rm *.aux; rm *.bbl; rm *.blg; rm *.log; rm *.out; rm *.pdf; rm *.gz
	
cleancode:	
	cd $(COD); rm *.log
	