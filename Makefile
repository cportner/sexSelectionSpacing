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

$(TEXDIR)/$(TEXFILE).pdf: $(TEXDIR)/$(TEXFILE).tex $(TEXDIR)/elasticities.bib  
	cd $(TEXDIR); pdflatex $(TEXFILE)
	cd $(TEXDIR); bibtex $(TEXFILE)
	cd $(TEXDIR); pdflatex $(TEXFILE)
	cd $(TEXDIR); pdflatex $(TEXFILE)

view: $(TEXDIR)/$(TEXFILE).pdf
	open -a Skim $(TEXDIR)/$(TEXFILE).pdf & 


### Stata part         			                                ###

