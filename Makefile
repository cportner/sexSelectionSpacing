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
EDUC    := low med high
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
ANALYSISTARGET := \
    $(foreach spell, $(SPELLS), \
    $(foreach per, $(PERIODS), \
    $(foreach educ, $(EDUC), \
    $(DAT)/results_spell$(spell)_g$(per)_$(educ).ster ) ) )

ANALYSISTARGET_REGION := \
    $(foreach spell, $(SPELLS), \
    $(foreach per, $(PERIODS), \
    $(foreach educ, $(EDUC), \
    $(foreach region, $(REGIONS), \
    $(DAT)/results_spell$(spell)_g$(per)_$(educ)_r$(region).ster ) ) ) )

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


### Bootstrap - Combined
### Data for bootstrapping
BSDATA_ALL := \
    $(foreach spell, $(SPELLS), \
    $(foreach per, $(PERIODS), \
    $(foreach educ, $(EDUC), \
    $(DAT)/bs_s$(spell)_g$(per)_$(educ)_all.dta ) ) ) 

### Tables of bootstrapping results
BSTABLE_ALL := \
    $(foreach educ, $(EDUC), \
    $(foreach var, $(BSVAR_NAMES), \
    $(TAB)/bootstrap_$(var)_$(educ)_all.tex ) ) 

### Graphs of bootstrapping results
BSGRAPH_ALL := \
    $(foreach spell, $(SPELLS), \
    $(foreach educ, $(EDUC), \
    $(foreach area, $(AREAS), \
    $(FIG)/bs_spell$(spell)_$(educ)_$(area)_all.eps ) ) ) 


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
 $(TAB)/fertility.tex 
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
$(FIG)/spell$(1)_g$(2)_$(3)_$(area)$(comp)pc.eps $(FIG)/spell$(1)_g$(2)_$(3)_$(area)$(comp)s.eps)) \
 : $(COD)/run_graphs_all.ado \
 $(DAT)/results_spell$(1)_g$(2)_$(3).ster $(COD)/bh_$(3).ado
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
	
	
#---------------------------#
#      Bootstrapping        #
#---------------------------#

### All ###

# Bootstrap results
.PHONY: run_boot_all
run_boot_all: $(BSDATA_ALL)

$(BSDATA_ALL): $(COD)/an_bootstrap_all.do $(DAT)/base.dta $(COD)/bootspell_all.do \
 $(COD)/genSpell1.do $(COD)/genSpell2.do $(COD)/genSpell3.do $(COD)/genSpell4.do
	cd $(COD); nice stata-se -b -q $(<F)	

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


#---------------------------#
#  Fertility Predictions    #
#---------------------------#

FHRESULTS := \
    $(foreach spell, 1 2 3 4, \
    $(foreach educ, $(EDUC), \
    $(foreach per, $(PERIODS), \
    $(DAT)/fertility_results_spell$(spell)_g$(per)_$(educ).ster ) ) )

FHTARGET := \
    $(foreach educ, $(EDUC), \
    $(foreach per, $(PERIODS), \
    $(DAT)/predicted_fertility_hazard_g$(per)_$(educ)_r$(per).dta ) )
    
TFRTARGET := \
    $(foreach per, $(PERIODS), \
    $(DAT)/predicted_tfr_round_$(per).dta ) 

# TFR estimations
$(TFRTARGET) : $(COD)/an_fertility_rate.do
 $(RAW)/iair72fl.dta $(RAW)/iair52fl.dta \
 $(RAW)/iahr42fl.dta $(RAW)/iair42fl.dta \
 $(RAW)/iahh21fl.dta $(RAW)/iahr23fl.dta $(RAW)/iair23fl.dta
	cd $(COD); stata-se -b -q $(<F)	

# Hazard model estimation results
$(FHRESULTS) : $(COD)/an_fertility_hazard.do
 $(DAT)/base.dta
	cd $(COD); stata-se -b -q $(<F)	

# Hazard model predictions
$(FHTARGET) : $(COD)/an_fertility_hazard_predict.do
 $(FHRESULTS) $(DAT)/base.dta
	cd $(COD); stata-se -b -q $(<F)	
  
# Table of predictions
$(TAB)/fertility.tex : $(COD)/an_fertility_table.do \
 $(FHTARGET) $(TFRTARGET) 
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
