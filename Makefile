### Makefile for Sex Selection and Birth Spacing Project        ###
### Still does not have any of the code             			###
### and tables are hardcoded into tex file          			###
### The non-generated figures are not included here 			###

### The reason for the weird set-up is to have Makefile 
### in base directory and run LaTeX in the paper directory 
### without leaving all the other files in the base directory

TEXFILE = sexSelectionSpacing-ver1
TEXDIR  = ./paper
FIGDIR  = ./figures
TABDIR  = ./tables
CODDIR  = ./code
RAWDIR  = ./rawData

# need to add a bib file dependency to end of next line
$(TEXDIR)/$(TEXFILE).pdf: $(TEXDIR)/$(TEXFILE).tex 
	cd $(TEXDIR); pdflatex $(TEXFILE)
	cd $(TEXDIR); bibtex $(TEXFILE)
	cd $(TEXDIR); pdflatex $(TEXFILE)
	cd $(TEXDIR); pdflatex $(TEXFILE)

view: $(TEXDIR)/$(TEXFILE).pdf
	open -a Skim $(TEXDIR)/$(TEXFILE).pdf & 


### Stata part         			                                ###

$(CODDIR)/$crBase1.do: $(RAWDIR)/iair23fl.dta
	cd $(CODDIR); stata-se -b crBase1.do 
    