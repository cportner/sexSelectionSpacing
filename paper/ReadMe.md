# Paper - Revision history

**Background:** 
The paper is essentially a shorter version of my original World Bank working paper.
The original paper went through multiple revisions at *Demography* before finally being
rejected.
My appeal was rejected, but they were open to have me submit a shorter and more focused
version.

sexSelectionSpacing-ver1.tex: This is the shorten version of the last round submitted
to *Demography* with the changes I suggested in my appeal.


# N-IUSSP article

How to run Markdown file in this directory if you do not want to use Make.
In either case, you need to have `pandoc` and `pandoc-crossref` installed.
If on a Mac, I recommend [brew](https://brew.sh).

To PDF: 
`pandoc default.yaml niussp_v2.md -o niussp_v2.pdf --pdf-engine=xelatex -N -s --filter pandoc-crossref --citeproc`

To Word:
`pandoc default.yaml niussp_v2.md -o niussp_v2.docx -N -s --filter pandoc-crossref --citeproc`





