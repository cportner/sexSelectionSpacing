### Makefile for Sex Selection and Birth Spacing Project        ###
### The non-generated figures are not included here 			###

### The reason for the weird directory set-up is to have Makefile 
### in base directory and run XeLaTeX in the paper directory 
### without leaving all the other files in the base directory

### If you are not used to Makefile this might seem overwhelming.
### The problem for this particular project is that it generates a
### very large number of figures and all of those need to go in
### dependencies and targets to ensure none are missing when running.

TEXFILE = sex_selection_spacing-ver3
TEX  = ./paper
FIG  = ./figures
TAB  = ./tables
COD  = ./code
RAW  = ./rawData
DAT  = ./data

### To run on Mac and Linux
### If you want to run this on Windows you will have to figure out how to call a pdf viewer
OS := $(shell uname)
ifeq ($(OS),Darwin)
PDFAPP := open -a Skim
else
PDFAPP := evince 
endif


### Generate dependencies for ease of reading/writing
PERIODS := 1 2 3 4
AREAS   := rural urban
EDUC    := low med high highest
SPELLS  := 2 3 4
COMP1   := _
COMP2   := _b_ _g_
COMP3   := _bb_ _bg_ _gg_
COMP4   := _bbb_ _bbg_ _bgg_ _ggg_
BSVAR_NAMES := duration_avg_sex_ratio duration_p25_p75 

### Intro graphs

WORKGRAPHS := \
    $(foreach area, $(AREAS), \
    $(foreach age, 20 30 40, \
    $(foreach var, currently_working work_cash work_family, \
    $(FIG)/$(var)_$(area)_$(age).eps ) ) )


### Regression analyses
ANALYSISTARGET_HIGHEST := \
    $(foreach spell, 2 3, \
    $(foreach per, $(PERIODS), \
    $(foreach educ, highest, \
    $(DAT)/results_spell$(spell)_g$(per)_$(educ).ster ) ) )

ANALYSISTARGET_OTHER := \
    $(foreach spell, $(SPELLS), \
    $(foreach per, $(PERIODS), \
    $(foreach educ, low med high, \
    $(DAT)/results_spell$(spell)_g$(per)_$(educ).ster ) ) )

ANALYSISTARGET := $(ANALYSISTARGET_HIGHEST) $(ANALYSISTARGET_OTHER)

### Percentage boys and standard survival graphs
GRAPHTARGET_HIGHEST := \
    $(foreach spell, 2 3, \
    $(foreach per, $(PERIODS), \
    $(foreach educ, highest, \
    $(foreach area, $(AREAS),\
    $(foreach comp, $(COMP$(spell)),\
    $(FIG)/spell$(spell)_g$(per)_$(educ)_$(area)$(comp)pc.eps $(FIG)/spell$(spell)_g$(per)_$(educ)_$(area)$(comp)s.eps) ) ) ) )

GRAPHTARGET_OTHER := \
    $(foreach spell, $(SPELLS), \
    $(foreach per, $(PERIODS), \
    $(foreach educ, low med high, \
    $(foreach area, $(AREAS),\
    $(foreach comp, $(COMP$(spell)),\
    $(FIG)/spell$(spell)_g$(per)_$(educ)_$(area)$(comp)pc.eps $(FIG)/spell$(spell)_g$(per)_$(educ)_$(area)$(comp)s.eps) ) ) ) )

GRAPHTARGET := $(GRAPHTARGET_HIGHEST) $(GRAPHTARGET_OTHER)

### PPS graphs
PPSTARGET_HIGHEST := \
    $(foreach spell, 2 3, \
    $(foreach educ, highest, \
    $(foreach area, $(AREAS), \
    $(foreach per, $(PERIODS), \
    $(FIG)/spell$(spell)_g$(per)_$(educ)_$(area)_pps.eps ) ) ) )

PPSTARGET_OTHER := \
    $(foreach spell, $(SPELLS), \
    $(foreach educ, low med high, \
    $(foreach area, $(AREAS), \
    $(foreach per, $(PERIODS), \
    $(FIG)/spell$(spell)_g$(per)_$(educ)_$(area)_pps.eps ) ) ) )

PPSTARGET := $(PPSTARGET_HIGHEST) $(PPSTARGET_OTHER)

### Spell 1 is different; it is combined across periods into one graph
#PPSTARGET := \
#    $(foreach spell, $(SPELLS), \
#    $(foreach educ, $(EDUC), \
#    $(foreach area, $(AREAS), \
#    $(if $(filter $(spell),1), \
#    $(FIG)/spell$(spell)_$(educ)_$(area)_pps.eps , \
#    $(foreach per, $(PERIODS), \
#    $(FIG)/spell$(spell)_g$(per)_$(educ)_$(area)_pps.eps ) ) \
#    ) ) )


### Bootstrap - Combined
### Data for bootstrapping
### Do not run 4th spell for highest because too few observations (199 women in 1st)
BSDATA_HIGHEST := \
    $(foreach spell, 2 3, \
    $(foreach per, $(PERIODS), \
    $(DAT)/bs_s$(spell)_g$(per)_highest_all.dta ) ) 

BSDATA_OTHERS := \
    $(foreach spell, $(SPELLS), \
    $(foreach educ, low med high, \
    $(foreach per, $(PERIODS), \
    $(DAT)/bs_s$(spell)_g$(per)_$(educ)_all.dta ) ) ) 

BSDATA_ALL := $(BSDATA_HIGHEST) $(BSDATA_OTHERS)

### Tables of bootstrapping results
BSTABLE_ALL := \
    $(foreach educ, $(EDUC), \
    $(foreach var, $(BSVAR_NAMES), \
    $(TAB)/bootstrap_$(var)_$(educ)_all.tex ) ) 

### Graphs of bootstrapping results
BSGRAPH_HIGHEST := \
    $(foreach spell, 2 3, \
    $(foreach area, $(AREAS), \
    $(FIG)/bs_spell$(spell)_highest_$(area)_all.eps ) )  

BSGRAPH_OTHERS := \
    $(foreach spell, $(SPELLS), \
    $(foreach educ, low med high, \
    $(foreach area, $(AREAS), \
    $(FIG)/bs_spell$(spell)_$(educ)_$(area)_all.eps ) ) ) 

BSGRAPH_ALL := $(BSGRAPH_HIGHEST) $(BSGRAPH_OTHERS)

### Graphs of Distribution results
DISTGRAPH_HIGHEST := \
    $(foreach var, p25 p50 p75 avg, \
    $(foreach spell, 2 3, \
    $(foreach area, $(AREAS), \
    $(FIG)/$(var)_spell$(spell)_highest_$(area).eps ) ) )

DISTGRAPH_OTHERS := \
    $(foreach var, p25 p50 p75 avg, \
    $(foreach spell, $(SPELLS), \
    $(foreach educ, low med high, \
    $(foreach area, $(AREAS), \
    $(FIG)/$(var)_spell$(spell)_$(educ)_$(area).eps ) ) ) )

DISTGRAPH_ALL := $(DISTGRAPH_HIGHEST) $(DISTGRAPH_OTHERS)



## Mortality target

MORTTARGET_OTHER := \
    $(foreach spell, 2 3, \
    $(foreach educ, low med high, \
    $(foreach per, $(PERIODS), \
    $(FIG)/mortality_s$(spell)_p$(per)_$(educ)_dummies.eps ) ) )

MORTTARGET_HIGHEST := \
    $(foreach spell, 2 3, \
    $(foreach per, 2 3 4, \
    $(FIG)/mortality_s$(spell)_p$(per)_highest_dummies.eps ) )

MORTTARGET := $(MORTTARGET_OTHER) $(MORTTARGET_HIGHEST)    



### Appendix 
### graphs LaTeX code
APPGRAPHS := \
    $(foreach spell, $(SPELLS), \
    $(foreach educ, $(EDUC), \
    $(FIG)/appendix_spell$(spell)_$(educ).tex \
    ))
    
### Recall error graphs
RECALLGRAPHS := \
    $(foreach round, $(PERIODS), \
    $(FIG)/recall_sex_ratio_marriage_round_$(round).eps $(FIG)/recall_sex_ratio_marriage_round_$(round)_bo2.eps )  
    
    
###################################################################	
### LaTeX part                                                  ###
###################################################################	

# Main paper
$(TEX)/$(TEXFILE).pdf: $(TEX)/$(TEXFILE).tex $(TEX)/sex_selection_spacing.bib \
 $(FIG)/educ_over_time_rural.eps $(FIG)/educ_over_time_urban.eps $(WORKGRAPHS) \
 $(TAB)/des_stat.tex $(TAB)/num_women.tex $(TAB)/num_missed.tex \
 $(TAB)/recallBirthBO1.tex $(TAB)/recallBirthBO2.tex $(TAB)/recallMarriageBO1.tex $(TAB)/recallMarriageBO2.tex \
 $(RECALLGRAPHS) \
 $(PPSTARGET) \
 $(BSTABLE_ALL) $(BSGRAPH_ALL) \
 $(DISTGRAPH_ALL) \
 $(TAB)/fertility.tex \
 $(MORTTARGET)
	cd $(TEX); xelatex $(TEXFILE)
	cd $(TEX); bibtex $(TEXFILE)
	cd $(TEX); xelatex $(TEXFILE)
	cd $(TEX); xelatex $(TEXFILE)
	
.PHONY: view
view: $(TEX)/$(TEXFILE).pdf
	$(PDFAPP) $(TEX)/$(TEXFILE).pdf & 
		
.PHONY: results  # convenience function during development
results: $(GRAPHTARGET) $(PPSTARGET) \
 $(BSTABLE_ALL) $(BSGRAPH_ALL)


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

$(DAT)/base4.dta: $(COD)/crBase4.do $(RAW)/iair72fl.dta $(RAW)/iahr71fl.dta 
	cd $(COD); stata-se -b -q $(<F)

$(DAT)/base.dta: $(COD)/crBase.do $(DAT)/base1.dta $(DAT)/base2.dta $(DAT)/base3.dta $(DAT)/base4.dta
	cd $(COD); stata-se -b -q $(<F)

#---------------------------------------------------------------------------------------#
# Recall error analysis                                                                 #
#---------------------------------------------------------------------------------------#

.PHONY: run_recall
run_recall: $(RECALLGRAPHS) $(TAB)/recallBirthBO1.tex $(TAB)/recallBirthBO2.tex $(TAB)/recallMarriageBO1.tex $(TAB)/recallMarriageBO2.tex

$(TAB)/recallBirthBO1.tex $(TAB)/recallBirthBO2.tex $(TAB)/recallMarriageBO1.tex $(TAB)/recallMarriageBO2.tex: $(COD)/anRecall.do $(DAT)/base.dta 
	cd $(COD); stata-se -b -q $(<F)

$(RECALLGRAPHS) : $(COD)/an_recall_graph.do $(DAT)/base.dta
	cd $(COD); stata-se -b -q $(<F)

#---------------------------------------------------------------------------------------#
# Descriptive statistics and graphs                                                     #
#---------------------------------------------------------------------------------------#


$(FIG)/educ_over_time_rural.eps $(FIG)/educ_over_time_urban.eps: $(COD)/an_educ_over_time.do \
 $(RAW)/iahh21fl.dta $(RAW)/iahr23fl.dta $(RAW)/iahr42fl.dta $(RAW)/iahr52fl.dta $(RAW)/iahr71fl.dta
	cd $(COD); stata-se -b -q $(<F)

$(WORKGRAPHS): $(COD)/an_work_over_time.do $(DAT)/base.dta
	cd $(COD); stata-se -b -q $(<F)
	
$(TAB)/des_stat.tex $(TAB)/num_women.tex $(TAB)/num_missed.tex: $(COD)/anDescStat.do $(DAT)/base.dta 
	cd $(COD); stata-se -b -q $(<F)


#---------------------------------------------------------------------------------------#
# Estimation results                                                                    #
#---------------------------------------------------------------------------------------#

# All/combined
.PHONY: run_analysis
run_analysis: $(ANALYSISTARGET)

# Use basename because run_analysis is an ado file
define analysis-rule
$(DAT)/obs_spell$(1)_$(2)_$(3).dta $(DAT)/results_spell$(1)_g$(2)_$(3).ster: $(COD)/run_analysis_all.ado \
 $(DAT)/base.dta $(COD)/bh_$(3).ado $(COD)/genSpell$(1).do
	cd $(COD); stata-se -b -q $$(basename $$(<F)) $(1) $(2) $(3) $(4)
endef

$(foreach spell, 2 3, \
$(foreach per, $(PERIODS), \
$(foreach educ, highest, \
$(eval $(call analysis-rule,$(spell),$(per),$(educ))) ) ) )

$(foreach spell, $(SPELLS), \
$(foreach per, $(PERIODS), \
$(foreach educ, low med high, \
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
$(FIG)/spell$(1)_g$(2)_$(3)_$(area)$(comp)pc.eps $(FIG)/spell$(1)_g$(2)_$(3)_$(area)$(comp)s.eps)) \
 : $(COD)/run_graphs_all.ado \
 $(DAT)/results_spell$(1)_g$(2)_$(3).ster $(COD)/bh_$(3).ado
	cd $(COD); stata-se -b -q $$(basename $$(<F)) $(1) $(2) $(3) 
endef

$(foreach spell, 2 3, \
$(foreach per, $(PERIODS), \
$(foreach educ, highest, \
$(eval $(call graph-rule,$(spell),$(per),$(educ))) ) ) )

$(foreach spell, $(SPELLS), \
$(foreach per, $(PERIODS), \
$(foreach educ, low med high, \
$(eval $(call graph-rule,$(spell),$(per),$(educ))) ) ) )


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

### old version of pps-rule	
#define pps-rule
#$(foreach educ, $(EDUC), \
#$(foreach area, $(AREAS), \
#$(if $(filter $(spell),1), \
# $(FIG)/spell$(1)_$(educ)_$(area)_pps.eps , \
# $(foreach per, $(PERIODS), \
# $(FIG)/spell$(1)_g$(per)_$(educ)_$(area)_pps.eps ) \
#) ) ) \
#: $(COD)/an_spell$(1)_pps.do \
# $(foreach per, $(PERIODS), \
# $(foreach educ, $(EDUC), \
# $(DAT)/spell$(1)_g$(per)_$(educ).dta))
#	cd $(COD); stata-se -b -q $$(<F)
#endef
#
#$(foreach spell, $(SPELLS), \
#$(eval $(call pps-rule,$(spell) ) ) )

$(foreach area, $(AREAS), \
$(foreach educ, low med high, \
$(foreach per, $(PERIODS), \
$(FIG)/spell4_g$(per)_$(educ)_$(area)_pps.eps ) ) ) \
 : $(COD)/an_spell4_pps.do \
 $(foreach per, $(PERIODS), \
 $(foreach educ, low med high, \
 $(DAT)/spell4_g$(per)_$(educ).dta ) )
	cd $(COD); stata-se -b -q $(<F)

$(foreach area, $(AREAS), \
$(foreach educ, $(EDUC), \
$(foreach per, $(PERIODS), \
$(FIG)/spell3_g$(per)_$(educ)_$(area)_pps.eps ) ) ) \
 : $(COD)/an_spell3_pps.do \
 $(foreach per, $(PERIODS), \
 $(foreach educ, $(EDUC), \
 $(DAT)/spell3_g$(per)_$(educ).dta ) )
	cd $(COD); stata-se -b -q $(<F)

$(foreach area, $(AREAS), \
$(foreach educ, $(EDUC), \
$(foreach per, $(PERIODS), \
$(FIG)/spell2_g$(per)_$(educ)_$(area)_pps.eps ) ) ) \
 : $(COD)/an_spell2_pps.do \
 $(foreach per, $(PERIODS), \
 $(foreach educ, $(EDUC), \
 $(DAT)/spell2_g$(per)_$(educ).dta ) )
	cd $(COD); stata-se -b -q $(<F)




#---------------------------#
#      Bootstrapping        #
#---------------------------#

### All ###

# Bootstrap results
.PHONY: run_boot_all
run_boot_all: $(BSDATA_ALL)

# Use basename because run_analysis is an ado file
define bootstrap-rule
$(DAT)/bs_s$(1)_g$(2)_$(3)_all.dta: $(COD)/run_bootstrap.ado \
 $(DAT)/base.dta $(COD)/genSpell$(1).do
	cd $(COD); stata-se -b -q $$(basename $$(<F)) $(1) $(2) $(3) $(4)
endef

$(foreach spell, 2 3, \
$(foreach per, $(PERIODS), \
$(foreach educ, highest, \
$(eval $(call bootstrap-rule,$(spell),$(per),$(educ))) ) ) )

$(foreach spell, $(SPELLS), \
$(foreach per, $(PERIODS), \
$(foreach educ, low med high, \
$(eval $(call bootstrap-rule,$(spell),$(per),$(educ))) ) ) )

#$(BSDATA_ALL): $(COD)/an_bootstrap_all.do $(DAT)/base.dta $(COD)/bootspell_all.do \
# $(COD)/genSpell1.do $(COD)/genSpell2.do $(COD)/genSpell3.do $(COD)/genSpell4.do
#	cd $(COD); nice stata-se -b -q $(<F)	

# Bootstrap tables
.PHONY: run_boot_table_all
run_boot_table_all: $(BSTABLE_ALL)

$(BSTABLE_ALL): $(COD)/an_bootstrap_table_all.do \
 $(BSDATA_ALL)
	cd $(COD); stata-se -b -q $(<F)	

# Bootstrap graphs
.PHONY: run_boot_graph_all
run_boot_graph_all: $(BSGRAPH_ALL)

$(BSGRAPH_ALL): $(COD)/an_bootstrap_graph_all.do \
 $(BSDATA_ALL)
	cd $(COD); stata-se -b -q $(<F)	
		
# Distribution graphs
.PHONY: run_distribution_graphs
run_distribution_graphs: $(DISTGRAPH_ALL)

$(DISTGRAPH_ALL): $(COD)/an_distribution_graph.do \
 $(BSDATA_ALL)
	cd $(COD); stata-se -b -q $(<F)	


#---------------------------#
#  Fertility Predictions    #
#---------------------------#

FHRESULTS_OTHER := \
    $(foreach spell, 1 2 3 4, \
    $(foreach educ, low med high, \
    $(foreach per, $(PERIODS), \
    $(DAT)/fertility_results_spell$(spell)_g$(per)_$(educ).ster ) ) )

FHRESULTS_HIGHEST := \
    $(foreach spell, 1 2 3 4, \
    $(foreach per, 2 3 4, \
    $(DAT)/fertility_results_spell$(spell)_g$(per)_highest.ster ) )

FHRESULTS := $(FHRESULTS_HIGHEST) $(FHRESULTS_OTHER)

FHTARGET_OTHER := \
    $(foreach educ, low med high, \
    $(foreach per, $(PERIODS), \
    $(DAT)/predicted_fertility_hazard_g$(per)_$(educ)_r$(per).dta ) )

FHTARGET_HIGHEST:= \
    $(foreach per, 2 3 4, \
    $(DAT)/predicted_fertility_hazard_g$(per)_highest_r$(per).dta ) 
    
FHTARGET := $(FHTARGET_HIGHEST) $(FHTARGET_OTHER)
    
TFRTARGET := \
    $(foreach per, $(PERIODS), \
    $(DAT)/predicted_tfr_round_$(per).dta ) 

# TFR estimations
$(TFRTARGET) : $(COD)/an_fertility_rate.do \
 $(RAW)/iair72fl.dta $(RAW)/iair52fl.dta \
 $(RAW)/iahr42fl.dta $(RAW)/iair42fl.dta \
 $(RAW)/iahh21fl.dta $(RAW)/iahr23fl.dta $(RAW)/iair23fl.dta
	cd $(COD); stata-se -b -q $(<F)	

# Hazard model estimation results
$(FHRESULTS) : $(COD)/an_fertility_hazard.do \
 $(DAT)/base.dta
	cd $(COD); stata-se -b -q $(<F)	

# Hazard model predictions
$(FHTARGET) : $(COD)/an_fertility_hazard_predict.do \
 $(FHRESULTS) $(DAT)/base.dta
	cd $(COD); stata-se -b -q $(<F)	
  
# Table of predictions
$(TAB)/fertility.tex : $(COD)/an_fertility_table.do \
 $(FHTARGET) $(TFRTARGET) 
	cd $(COD); stata-se -b -q $(<F)	

#---------------------------#
#  Infant Mortality         #
#---------------------------#
    
$(MORTTARGET) : $(COD)/an_infant_mortality.do $(DAT)/base.dta
	cd $(COD); stata-se -b -q $(<F)	
    

	
#---------------------------------------------------------------------------------------#
# Clean directories for generated files                                                 #
# The "-" prevents Make from stopping with an error if a file type does not exist       #
#---------------------------------------------------------------------------------------#

.PHONY: clean cleantab cleanfig cleantex cleancode cleandata
clean: cleantab cleanfig cleantex cleancode cleandata

cleantab:
	-cd $(TAB); rm *.tex
	
cleanfig:
	-cd $(FIG); rm *.eps; rm *.tex
	
cleantex:
	-cd $(TEX); rm *.aux; rm *.bbl; rm *.blg; rm *.log; rm *.out; rm *.pdf; rm *.gz
	
cleancode:	
	-cd $(COD); rm *.log

cleandata:	
	-cd $(DAT); rm *.dta; rm *.ster
