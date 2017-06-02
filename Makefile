### Makefile for Sex Selection and Birth Spacing Project        ###
### Still does not have any of the code             			###
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

# need to add a bib file dependency to end of next line
$(TEX)/$(TEXFILE).pdf: $(TEX)/$(TEXFILE).tex $(COD)/crBase1.do
	cd $(TEX); pdflatex $(TEXFILE)
	cd $(TEX); bibtex $(TEXFILE)
	cd $(TEX); pdflatex $(TEXFILE)
	cd $(TEX); pdflatex $(TEXFILE)

view: $(TEX)/$(TEXFILE).pdf
	open -a Skim $(TEX)/$(TEXFILE).pdf & 


### Stata part         			                                ###

$(COD)/crBase1.do: $(RAW)/iair23fl.dta $(RAW)/iawi22fl.dta $(RAW)/iahh21fl.dta
	cd $(COD); stata-se -b crBase1.do 
    
$(COD)/crBase2.do: $(RAW)/iair42fl.dta $(RAW)/iawi41fl.dta $(RAW)/iahr42fl.dta
	cd $(COD); stata-se -b crBase2.do 

$(COD)/crBase3.do: $(RAW)/iair52fl.dta 
	cd $(COD); stata-se -b crBase3.do 
