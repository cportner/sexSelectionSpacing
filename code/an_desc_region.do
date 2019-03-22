// Table of states in each region

version 15.1
clear all

file close _all // easier, in case something went wrong with last file write (Stata does not close files gracefully)

include directories

use `data'/base

label def region 1 "West" 2 "North" 3 "East" 4 "South"
label val region region

levelsof region, local(regions)
foreach reg of local regions {
    levelsof state if region == `reg', local(levels)
    foreach l of local levels {
        local name: label state `l'
        local name: subinstr local name " " "_", all
        local region_names_`reg' "`region_names_`reg'' `name'"
    }
    local region_names_`reg': list sort region_names_`reg'
    local region_names_`reg': subinstr local region_names_`reg' " " ", ", all
    local region_names_`reg': subinstr local region_names_`reg' "_" " ", all
}

file open table using `tables'/desc_region.tex, write replace

file write table "\begin{table}[phtb!]" _n
file write table "\begin{center}" _n
file write table "\begin{normalsize}" _n
file write table "\begin{threeparttable}" _n
file write table "\caption{Definition of Regions}" _n
file write table "\label{tab:regions}" _n
file write table "\begin{tabular}{@{} p{1.5 cm} p{11cm}  @{}}" _n
file write table "\toprule" _n
file write table "Region       & States    \\ \midrule" _n
foreach reg of local regions{
    local reg_name: label region `reg'
    file write table "`reg_name'  & `region_names_`reg'' \\ " _n
    file write table "\addlinespace" _n
}
// Table endnotes
file write table "\bottomrule" _n
file write table "\end{tabular}" _n
file write table "\begin{tablenotes} \tiny" _n
file write table "\item \hspace*{-0.5em} \textbf{Note.}" _n
file write table "The state names reflect those when the first NFHS was collected in 1992/1993." _n
file write table "States created later are allocated as closely as possible to their" _n
file write table "original state." _n
file write table "\end{tablenotes}" _n
file write table "\end{threeparttable}" _n
file write table "\end{normalsize}" _n
file write table "\end{center}" _n
file write table "\end{table}" _n

file close table



