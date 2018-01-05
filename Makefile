### Makefile for Sex Selection and Birth Spacing Project        ###
### and tables are hardcoded into tex file          			###
### The non-generated figures are not included here 			###

### The reason for the weird set-up is to have Makefile 
### in base directory and run LaTeX in the paper directory 
### without leaving all the other files in the base directory

### If you are not used to Makefile this might seem overwhelming.
### The problem for this particular project is that it generates a
### very large number of figures and all of those need to go in
### dependencies and targets to ensure none are missing when running.

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
SPELLS  := 1 2 3 4
COMP2   := b g
COMP3   := bb bg gg
COMP4   := bbb bbg bgg ggg

BSDATA := \
    $(foreach spell, $(SPELLS), \
    $(foreach per, $(PERIODS), \
    $(foreach educ, $(EDUC), \
    $(DAT)/bs_s$(spell)_g$(per)_$(educ).dta ) ) ) 
    
PPSDATA1 := \
    $(foreach educ, $(EDUC), \
    $(foreach per, $(PERIODS), \
    $(DAT)/spell1_g$(per)_$(educ).dta ) )

PPSDATA2 := \
    $(foreach educ, $(EDUC), \
    $(foreach per, $(PERIODS), \
    $(DAT)/spell2_g$(per)_$(educ).dta ) )

PPSDATA3 := \
    $(foreach educ, $(EDUC), \
    $(foreach per, $(PERIODS), \
    $(DAT)/spell3_g$(per)_$(educ).dta ) )

PPSDATA4 := \
    $(foreach educ, $(EDUC), \
    $(foreach per, $(PERIODS), \
    $(DAT)/spell4_g$(per)_$(educ).dta ) )
    
### Survival and percentage graphs
    
SPELL1 := \
    $(foreach educ, $(EDUC), \
    $(foreach per, $(PERIODS), \
    $(foreach area, $(AREAS), \
    $(FIG)/spell1_g$(per)_$(educ)_$(area)_s.eps $(FIG)/spell1_g$(per)_$(educ)_$(area)_pc.eps ) ) ) 

SPELL2 := \
    $(foreach educ, $(EDUC), \
    $(foreach per, $(PERIODS), \
    $(foreach area, $(AREAS), \
    $(foreach sex, $(COMP2), \
    $(FIG)/spell2_g$(per)_$(educ)_$(area)_$(sex)_s.eps $(FIG)/spell2_g$(per)_$(educ)_$(area)_$(sex)_pc.eps ) ) ) )

SPELL3 := \
    $(foreach educ, $(EDUC), \
    $(foreach per, $(PERIODS), \
    $(foreach area, $(AREAS), \
    $(foreach sex, $(COMP3), \
    $(FIG)/spell3_g$(per)_$(educ)_$(area)_$(sex)_s.eps $(FIG)/spell3_g$(per)_$(educ)_$(area)_$(sex)_pc.eps ) ) ) )

SPELL4 := \
    $(foreach educ, $(EDUC), \
    $(foreach per, $(PERIODS), \
    $(foreach area, $(AREAS), \
    $(foreach sex, $(COMP4), \
    $(FIG)/spell4_g$(per)_$(educ)_$(area)_$(sex)_s.eps $(FIG)/spell4_g$(per)_$(educ)_$(area)_$(sex)_pc.eps ) ) ) )

### PPS graphs
    
TARGETPPS1 := \
    $(foreach educ, $(EDUC), \
    $(foreach area, $(AREAS), \
    $(FIG)/spell1_$(educ)_$(area)_pps.eps ) )

TARGETPPS2 := \
    $(foreach per, $(PERIODS), \
    $(foreach educ, $(EDUC), \
    $(foreach area, $(AREAS), \
    $(FIG)/spell2_g$(per)_$(educ)_$(area)_pps.eps ) ) )

TARGETPPS3 := \
    $(foreach per, $(PERIODS), \
    $(foreach educ, $(EDUC), \
    $(foreach area, $(AREAS), \
    $(FIG)/spell3_g$(per)_$(educ)_$(area)_pps.eps ) ) )


TARGETPPS4 := \
    $(foreach per, $(PERIODS), \
    $(foreach educ, $(EDUC), \
    $(foreach area, $(AREAS), \
    $(FIG)/spell4_g$(per)_$(educ)_$(area)_pps.eps ) ) )


### Generate figure targets for graphs

TARGET1 := \
    $(foreach area, $(AREAS), \
    $(FIG)/%_$(area)_s.eps $(FIG)/%_$(area)_pc.eps )
    
TARGET2 := \
    $(foreach area, $(AREAS), \
    $(foreach sex, $(COMP2), \
    $(FIG)/%_$(area)_$(sex)_s.eps $(FIG)/%_$(area)_$(sex)_pc.eps ) )

TARGET3 := \
    $(foreach area, $(AREAS), \
    $(foreach sex, $(COMP3), \
    $(FIG)/%_$(area)_$(sex)_s.eps $(FIG)/%_$(area)_$(sex)_pc.eps ) )

TARGET4 := \
    $(foreach area, $(AREAS), \
    $(foreach sex, $(COMP4), \
    $(FIG)/%_$(area)_$(sex)_s.eps $(FIG)/%_$(area)_$(sex)_pc.eps ) )
    
    
###################################################################	
### LaTeX part                                                  ###
###################################################################	

# Main paper
$(TEX)/$(TEXFILE).pdf: $(TEX)/$(TEXFILE).tex $(TEX)/sex_selection_spacing.bib \
 $(TAB)/des_stat.tex \
 $(SPELL1) $(SPELL2) $(SPELL3) $(SPELL4) \
 $(TARGETPPS1) $(TARGETPPS2) $(TARGETPPS3) $(TARGETPPS4) \
 $(TAB)/bootstrap_duration_sex_ratio_high.tex  $(TAB)/bootstrap_duration_sex_ratio_med.tex  $(TAB)/bootstrap_duration_sex_ratio_high.tex
	cd $(TEX); xelatex $(TEXFILE)
	cd $(TEX); bibtex $(TEXFILE)
	cd $(TEX); xelatex $(TEXFILE)
	cd $(TEX); xelatex $(TEXFILE)

# Appendix file	
$(TEX)/$(APPFILE).pdf: $(TEX)/$(APPFILE).tex $(TEX)/sex_selection_spacing.bib \
 $(SPELL1) $(SPELL2) $(SPELL3) $(SPELL4) \
 $(TARGETPPS1) $(TARGETPPS2) $(TARGETPPS3) $(TARGETPPS4) 
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
		
.PHONY: results  # convenience function during development
results: $(SPELL1) $(SPELL2) $(SPELL3) $(SPELL4) \
 $(TARGETPPS1) $(TARGETPPS2) $(TARGETPPS3) $(TARGETPPS4) \
 $(TAB)/bootstrap_duration_sex_ratio_low.tex  $(TAB)/bootstrap_duration_sex_ratio_med.tex  $(TAB)/bootstrap_duration_sex_ratio_high.tex

###################################################################	
### Stata part         			                                ###
###################################################################	

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

#---------------------------------------------------------------------------------------#
# Estimation results and data for graphs                                                #
# Precious is needed because Make generates those through an implicit rule  and         #
# therefore treats them as intermediate files and deletes them after running.           #
#---------------------------------------------------------------------------------------#

.PRECIOUS: $(DAT)/results_%.ster

$(DAT)/results_%.ster: $(COD)/an_%.do $(DAT)/base.dta 
	cd $(COD); stata-se -b -q $(<F)

$(DAT)/spell1_%.dta: $(COD)/an_spell1_%_graphs.do $(DAT)/results_spell1_%.ster $(COD)/gen_spell1_graphs.do
	cd $(COD); stata-se -b -q $(<F)

$(DAT)/spell4_%.dta: $(COD)/an_spell4_%_graphs.do $(DAT)/results_spell4_%.ster $(COD)/gen_spell4_graphs.do
	cd $(COD); stata-se -b -q $(<F)

		
#--------------------#
#      Graphs        #
#--------------------#

$(TARGET1): $(COD)/an_%_graphs.do $(DAT)/results_%.ster $(COD)/gen_spell1_graphs.do
	cd $(COD); stata-se -b -q $(<F)

$(TARGET2): $(COD)/an_%_graphs.do $(DAT)/results_%.ster $(COD)/gen_spell2_graphs.do
	cd $(COD); stata-se -b -q $(<F)

$(TARGET3): $(COD)/an_%_graphs.do $(DAT)/results_%.ster $(COD)/gen_spell3_graphs.do
	cd $(COD); stata-se -b -q $(<F)

$(TARGET4): $(COD)/an_%_graphs.do $(DAT)/results_%.ster $(COD)/gen_spell4_graphs.do
	cd $(COD); stata-se -b -q $(<F)

$(FIG)/%_rural_pps.eps $(FIG)/%_urban_pps.eps: $(COD)/an_%_graphs.do $(DAT)/results_%.ster 
	cd $(COD); stata-se -b -q $(<F)
	
$(TARGETPPS1): $(COD)/an_spell1_pps.do $(PPSDATA1)
	cd $(COD); stata-se -b -q $(<F)
	
$(TARGETPPS4): $(COD)/an_spell4_pps.do $(PPSDATA4)
	cd $(COD); stata-se -b -q $(<F)
	
#--------------------#
#      Tables        #
#--------------------#

# Bootstrap results
$(BSDATA): $(COD)/an_bootstrap.do $(DAT)/base.dta \
 $(COD)/bootspell.do $(COD)/baseline_hazards/bh_low.do \
 $(COD)/baseline_hazards/bh_med.do $(COD)/baseline_hazards/bh_high.do
	cd $(COD); stata-se -b -q $(<F)	

# Bootstrap tables

$(TAB)/bootstrap_duration_sex_ratio_low.tex  $(TAB)/bootstrap_duration_sex_ratio_med.tex  $(TAB)/bootstrap_duration_sex_ratio_high.tex: $(COD)/an_bootstrap_table.do \
 $(BSDATA)
	cd $(COD); stata-se -b -q $(<F)	

	
#---------------------------------------------------------------------------------------#
# Clean directories for (most) generated files                                          #
# This does not clean generated data files; mainly because I am a chicken               #
# The "-" prevents Make from stopping with an error if a file type does not exist       #
#---------------------------------------------------------------------------------------#

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
