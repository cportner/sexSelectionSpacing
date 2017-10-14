### Makefile for Sex Selection and Birth Spacing Project        ###
### and tables are hardcoded into tex file          			###
### The non-generated figures are not included here 			###

### The reason for the weird set-up is to have Makefile 
### in base directory and run LaTeX in the paper directory 
### without leaving all the other files in the base directory

TEXFILE = sexSelectionSpacing-ver1
APPFILE = sexSelectionSpacingAppendix-ver1
TEX  = ./paper
FIG  = ./figures
TAB  = ./tables
COD  = ./code
RAW  = ./rawData
DAT  = ./data

### Generate figure dependencies
PERIODS := 1 2 3
AREAS   := rural urban
EDUC    := low med high
SPELLS  := 2 3
OUTCOME := 1 2

PPSDEPS := \
    $(foreach spell, $(SPELLS), \
    $(foreach educ, $(EDUC), \
    $(foreach per, $(PERIODS), \
    $(foreach area, $(AREAS), \
    $(FIG)/spell$(spell)_g$(per)_$(educ)_$(area)_pps.eps ) ) ) )
    
    
SPELL1 := \
    $(foreach educ, $(EDUC), \
    $(foreach per, $(PERIODS), \
    $(foreach ks, $(OUTCOME), \
    $(FIG)/spell1_g$(per)_$(educ)_r$(ks)_s.eps ) ) ) 


### LaTeX part

# !!need to add a bib file dependency to end of next line
$(TEX)/$(TEXFILE).pdf: $(TEX)/$(TEXFILE).tex \
 $(TAB)/des_stat.tex $(PPSDEPS) $(SPELL1)
	cd $(TEX); xelatex $(TEXFILE)
	cd $(TEX); bibtex $(TEXFILE)
	cd $(TEX); xelatex $(TEXFILE)
	cd $(TEX); xelatex $(TEXFILE)

# Appendix file	
$(TEX)/$(APPFILE).pdf: $(TEX)/$(APPFILE).tex \
 $(PPSDEPS)	
	cd $(TEX); xelatex $(APPFILE)
	cd $(TEX); bibtex $(APPFILE)
	cd $(TEX); xelatex $(APPFILE)
	cd $(TEX); xelatex $(APPFILE)
	
.PHONY: view
view: $(TEX)/$(TEXFILE).pdf
	open -a Skim $(TEX)/$(TEXFILE).pdf & 

.PHONY: app
app: $(TEX)/$(APPFILE).pdf
	open -a Skim $(TEX)/$(APPFILE).pdf & 

.PHONY: all
all: $(TEX)/$(TEXFILE).pdf $(TEX)/$(APPFILE).pdf
	open -a Skim $(TEX)/$(APPFILE).pdf & 
	open -a Skim $(TEX)/$(TEXFILE).pdf & 

	
### Stata part         			                                ###

# Create base data set(s)
# Need "end" file as outcome, here the base data sets for each survey
$(DAT)/base1.dta: $(COD)/crBase1.do $(RAW)/iair23fl.dta $(RAW)/iawi22fl.dta $(RAW)/iahh21fl.dta
	cd $(COD); stata-se -b -q $(<F)
    
$(DAT)/base2.dta: $(COD)/crBase2.do $(RAW)/iair42fl.dta $(RAW)/iawi41fl.dta $(RAW)/iahr42fl.dta
	cd $(COD); stata-se -b -q $(<F)

$(DAT)/base3.dta: $(COD)/crBase3.do $(RAW)/iair52fl.dta 
	cd $(COD); stata-se -b -q $(<F)

$(DAT)/base.dta: $(COD)/crBase.do $(DAT)/base1.dta $(DAT)/base2.dta $(DAT)/base3.dta
	cd $(COD); stata-se -b -q $(<F)

# Descriptive statistics
$(TAB)/des_stat.tex: $(COD)/anDescStat.do $(DAT)/base.dta 
	cd $(COD); stata-se -b -q $(<F)


# Estimation results for graphs
# Precious is needed because Make generates those through an implicit rule  and therefore
# treats them as intermediate files and deletes them after running.

.PRECIOUS: $(DAT)/results_%.ster

$(DAT)/results_%.ster: $(COD)/an_%.do $(DAT)/base.dta 
	cd $(COD); stata-se -b -q $(<F)
	

# Graphs

$(FIG)/%_rural_pps.eps $(FIG)/%_urban_pps.eps: $(COD)/an_%_graphs.do $(DAT)/results_%.ster 
	cd $(COD); stata-se -b -q $(<F)

$(FIG)/%_r1_s.eps $(FIG)/%_r2_s.eps: $(COD)/an_%_graphs.do $(DAT)/results_%.ster $(COD)/gen_spell1_graphs.do
	cd $(COD); stata-se -b -q $(<F)


# Clean directories for (most) generated files
# This does not clean generated data files; mainly because I am a chicken
# The "-" in front prevents Make from stopping with an error if a file type does not exist

.PHONY: cleanall cleantab cleanfig cleantex cleancode
cleanall: cleanfig cleantab cleantex cleancode
	-cd $(DAT); rm *.ster

cleantab:
	-cd $(TAB); rm *.tex
	
cleanfig:
	-cd $(FIG); rm *.eps
	
cleantex:
	-cd $(TEX); rm *.aux; rm *.bbl; rm *.blg; rm *.log; rm *.out; rm *.pdf; rm *.gz
	
cleancode:	
	-cd $(COD); rm *.log
