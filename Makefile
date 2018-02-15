### Makefile for Sex Selection and Birth Spacing Project        ###
### The non-generated figures are not included here 			###

### The reason for the weird directory set-up is to have Makefile 
### in base directory and run XeLaTeX in the paper directory 
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

### To run on Mac and Linux
OS:= $(shell uname)

### Generate dependencies for ease of reading/writing
PERIODS := 1 2 3 4
AREAS   := rural urban
EDUC    := low med high
SPELLS  := 1 2 3 4
COMP1   := _
COMP2   := _b_ _g_
COMP3   := _bb_ _bg_ _gg_
COMP4   := _bbb_ _bbg_ _bgg_ _ggg_

### Regression analyses
ANALYSISTARGET := \
    $(foreach spell, $(SPELLS), \
    $(foreach per, $(PERIODS), \
    $(foreach educ, $(EDUC), \
    $(DAT)/results_spell$(spell)_g$(per)_$(educ).ster ) ) )

### Percentage boys and standard survival graphs
GRAPHTARGET := \
    $(foreach spell, $(SPELLS), \
    $(foreach per, $(PERIODS), \
    $(foreach educ, $(EDUC), \
    $(foreach area, $(AREAS),\
    $(foreach comp, $(COMP$(spell)),\
    $(FIG)/spell$(spell)_g$(per)_$(educ)_$(area)$(comp)pc.eps $(FIG)/spell$(spell)_g$(per)_$(educ)_$(area)$(comp)s.eps) ) ) ) )

### PPS graphs
### Spell 1 is different; it is combined across periods into one graph
PPSTARGET := \
    $(foreach spell, $(SPELLS), \
    $(foreach educ, $(EDUC), \
    $(foreach area, $(AREAS), \
    $(if $(filter $(spell),1), \
    $(FIG)/spell$(spell)_$(educ)_$(area)_pps.eps , \
    $(foreach per, $(PERIODS), \
    $(FIG)/spell$(spell)_g$(per)_$(educ)_$(area)_pps.eps ) ) \
    ) ) )

### Data for bootstrapping
BSDATA := \
    $(foreach spell, $(SPELLS), \
    $(foreach per, $(PERIODS), \
    $(foreach educ, $(EDUC), \
    $(DAT)/bs_s$(spell)_g$(per)_$(educ).dta ) ) ) 
    
### Appendix graphs LaTeX code
APPGRAPHS := \
    $(foreach spell, $(SPELLS), \
    $(foreach educ, $(EDUC), \
    $(FIG)/appendix_spell$(spell)_$(educ).tex \
    ))    
    
    
###################################################################	
### LaTeX part                                                  ###
###################################################################	

# Main paper
$(TEX)/$(TEXFILE).pdf: $(TEX)/$(TEXFILE).tex $(TEX)/sex_selection_spacing.bib \
 $(TAB)/des_stat.tex \
 $(GRAPHTARGET) $(PPSTARGET) \
 $(TAB)/bootstrap_duration_sex_ratio_high.tex  $(TAB)/bootstrap_duration_sex_ratio_med.tex  $(TAB)/bootstrap_duration_sex_ratio_high.tex
	cd $(TEX); xelatex $(TEXFILE)
	cd $(TEX); bibtex $(TEXFILE)
	cd $(TEX); xelatex $(TEXFILE)
	cd $(TEX); xelatex $(TEXFILE)

# Appendix file	
$(TEX)/$(APPFILE).pdf: $(TEX)/$(APPFILE).tex $(TEX)/sex_selection_spacing.bib \
 $(GRAPHTARGET) $(PPSTARGET) $(APPGRAPHS)
	cd $(TEX); xelatex $(APPFILE)
	cd $(TEX); bibtex $(APPFILE)
	cd $(TEX); xelatex $(APPFILE)
	cd $(TEX); xelatex $(APPFILE)
	
.PHONY: view
view: $(TEX)/$(TEXFILE).pdf
    ifeq ($(OS),Darwin)
        open -a Skim $(TEX)/$(TEXFILE).pdf & 
    else
        evince $(TEX)/$(TEXFILE).pdf &
    endif

.PHONY: app
app: $(TEX)/$(APPFILE).pdf
	open -a Skim $(TEX)/$(APPFILE).pdf & 

.PHONY: all
all: $(TEX)/$(TEXFILE).pdf $(TEX)/$(APPFILE).pdf
	open -a Skim $(TEX)/$(APPFILE).pdf & 
	open -a Skim $(TEX)/$(TEXFILE).pdf & 
		
.PHONY: results  # convenience function during development
results: $(GRAPHTARGET) $(PPSTARGET) \
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

$(DAT)/base4.dta: $(COD)/crBase4.do $(RAW)/iair71fl.dta $(RAW)/iahr71fl.dta 
	cd $(COD); stata-se -b -q $(<F)

$(DAT)/base.dta: $(COD)/crBase.do $(DAT)/base1.dta $(DAT)/base2.dta $(DAT)/base3.dta $(DAT)/base4.dta
	cd $(COD); stata-se -b -q $(<F)


#---------------------------------------------------------------------------------------#
# Descriptive statistics                                                                #
#---------------------------------------------------------------------------------------#

$(TAB)/des_stat.tex: $(COD)/anDescStat.do $(DAT)/base.dta 
	cd $(COD); stata-se -b -q $(<F)


#---------------------------------------------------------------------------------------#
# Estimation results                                                                    #
#---------------------------------------------------------------------------------------#

.PHONY: run_analysis
run_analysis: $(ANALYSISTARGET)

# Use basename because run_analysis is an ado file
define analysis-rule
$(DAT)/obs_spell$(1)_$(2)_$(3).dta $(DAT)/results_spell$(1)_g$(2)_$(3).ster: $(COD)/run_analysis.ado \
 $(DAT)/base.dta $(COD)/bh_$(3).ado $(COD)/genSpell$(1).do
	cd $(COD); stata-se -b -q $$(basename $$(<F)) $(1) $(2) $(3) 
endef

$(foreach spell, $(SPELLS), \
$(foreach per, $(PERIODS), \
$(foreach educ, $(EDUC), \
$(eval $(call analysis-rule,$(spell),$(per),$(educ))) ) ) )

		
#---------------------------------------------------------------------------------------#
# Percentage boys and survival graphs                                                   #
#---------------------------------------------------------------------------------------#

.PHONY: run_graphs
run_graphs: $(GRAPHTARGET)

define graph-rule
$(DAT)/spell$(1)_g$(2)_$(3).dta \
$(foreach area, $(AREAS),\
$(foreach comp, $(COMP$(1)),\
$(FIG)/spell$(1)_g$(2)_$(3)_$(area)$(comp)pc.eps $(FIG)/spell$(1)_g$(2)_$(3)_$(area)$(comp)s.eps)) : $(COD)/run_graphs.ado \
 $(DAT)/obs_spell$(1)_$(2)_$(3).dta $(DAT)/results_spell$(1)_g$(2)_$(3).ster $(COD)/bh_$(3).ado
	cd $(COD); stata-se -b -q $$(basename $$(<F)) $(1) $(2) $(3) 
endef

$(foreach spell, $(SPELLS), \
$(foreach per, $(PERIODS), \
$(foreach educ, $(EDUC), \
$(eval $(call graph-rule,$(spell),$(per),$(educ))))))

# Generate LaTeX code for appendix graphs
$(APPGRAPHS) : $(COD)/gen_appendix_graphs.do $(GRAPHTARGET)
	cd $(COD); stata-se -b -q $(<F)

#---------------------------------------------------------------------------------------#
# Parity progression survival graphs                                                    #
# The rule is more complicated because the graphs for spell 1 are combined over periods,#
# while they are separated by period for spell 2 and above.                             #
#---------------------------------------------------------------------------------------#

.PHONY: run_pps
run_pps: $(PPSTARGET)
	
define pps-rule
$(foreach educ, $(EDUC), \
$(foreach area, $(AREAS), \
$(if $(filter $(spell),1), \
 $(FIG)/spell$(1)_$(educ)_$(area)_pps.eps , \
 $(foreach per, $(PERIODS), \
 $(FIG)/spell$(1)_g$(per)_$(educ)_$(area)_pps.eps ) \
) ) ) \
: $(COD)/an_spell$(1)_pps.do \
 $(foreach per, $(PERIODS), \
 $(foreach educ, $(EDUC), \
 $(DAT)/spell$(1)_g$(per)_$(educ).dta))
	cd $(COD); stata-se -b -q $$(<F)
endef

$(foreach spell, $(SPELLS), \
 $(eval $(call pps-rule,$(spell))) \
)
	
	
#--------------------#
#      Tables        #
#--------------------#

# Bootstrap results
$(BSDATA): $(COD)/an_bootstrap.do $(DAT)/base.dta \
 $(COD)/bootspell.do $(COD)/bh_low.ado \
 $(COD)/bh_med.ado $(COD)/bh_high.ado \
 $(COD)/genSpell1.do $(COD)/genSpell2.do $(COD)/genSpell3.do $(COD)/genSpell4.do
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
