// Generate LaTeX graph code for Appendix
// Only percentage boys and probability of birth at the moment

capture file close _all

// One file per education/spell combination to make it easier to
// add conditional survival later

include directories

// Spell 1 
// Organized by education; and within that by area

// One figure per education level
foreach educ in "low" "med" "high" {

    // Information for caption
    if "`educ'" == "low" {
        loc char "no education"
        loc age = 16
    }
    if "`educ'" == "med" {
        loc char "1 to 7 years of education"
        loc age = 17
    }
    if "`educ'" == "high" {
        loc char "8 or more years of education"
        loc age = 20
    }

    file open grph using `figures'/appendix_spell1_`educ'.tex, write replace
    // LaTeX graph preamble
    file write grph "\begin{figure}[htpb!]" _n
    file write grph "\centering" _n
    // Loop over area
    loc subfig_count = -2 // counter increases throughout the figure
    foreach area in "urban" "rural" {
        local proper_area = proper("`area'") // nice capitalization
        file write grph "\caption*{`proper_area'}" _n
        // Loop over periods including getting number of observations
        // Each period/area combination is a minipage
        forvalues period = 1/4 {
            file write grph "\setcounter{subfigure}{`subfig_count'}" _n
            file write grph "\subfloat["
            // Get period and number of observations
            if `period' == 1 {
                file write grph "1972--1984 (N="
            }
            else if `period' == 2 {
                file write grph "1985--1994 (N="
            }
            else if `period' == 3 {
                file write grph "1995--2004 (N="
            }
            else if `period' == 4 {
                file write grph "2005--2016 (N=" 
            }
            use `data'/obs_spell1_`period'_`educ', clear
            if "`area'" ==  "urban" {            
                sum num_obs if urban == 1, mean
            }
            else if "`area'" == "rural" {
                sum num_obs if urban == 0, mean
            }
            if `r(N)' != 1 {
                dis "There are more than 1 observation used for number of observations"
                exit
            }
            file write grph %9.0fc (`r(mean)')
            file write grph ")]{" _n
            file write grph "   \begin{minipage}{0.22\textwidth}" _n
            file write grph "       \captionsetup[subfigure]{labelformat=empty,position=top,captionskip=-1pt,farskip=-0.5pt}" _n
            file write grph "       \subfloat[Prob.\ boy (\%)]{\includegraphics[width=\textwidth]{spell1_g`period'_`educ'_`area'_pc}}\\" _n
            file write grph "       \subfloat[Prob.\ no birth yet]{\includegraphics[width=\textwidth]{spell1_g`period'_`educ'_`area'_s}}" _n 
            file write grph "       \captionsetup[subfigure]{labelformat=parens}" _n
            file write grph "   \end{minipage}" _n
            file write grph "}" _n
            loc ++subfig_count         
        }
    }
    // LaTeX graph post-amble
    file write grph "\caption{Predicted probability of having a boy and probability of " _n
    file write grph "no birth yet from time of marriage for women with `char' by month beginning at marriage.  " _n
    file write grph "Predictions based on age `age' at marriage. " _n
    file write grph "Left column shows results prior to sex selection available, middle column before " _n
    file write grph "sex selection illegal and right column after sex selection illegal. " _n
    file write grph "N indicates the number of women in the relevant group in the underlying samples. " _n
    file write grph "} " _n
    file write grph "\label{fig:results_spell1_`educ'} " _n
    file write grph "\end{figure}" _n
    file close grph
}


// Spell 2
// Organized by education and area; and within that by sex composition

// One figure per education level
foreach educ in "low" "med" "high" {

    // Information for caption
    if "`educ'" == "low" {
        loc char "no education"
        loc age = 18
    }
    if "`educ'" == "med" {
        loc char "1 to 7 years of education"
        loc age = 19
    }
    if "`educ'" == "high" {
        loc char "8 or more years of education"
        loc age = 22
    }

    file open grph using `figures'/appendix_spell2_`educ'.tex, write replace
    foreach area in "urban" "rural" {
    
        if "`area'" == "urban" {
            loc urban = "urban"
        }
        else {
            loc urban = "!urban"
        }
        
        // LaTeX graph preamble
        file write grph "\begin{figure}[htpb!]" _n
        file write grph "\centering" _n
        // Loop over sex composition
        loc subfig_count = -2 // counter increases throughout the figure
        foreach sex in "girl" "boy" {
            if "`sex'" == "girl" {
                loc girl = "girl1"
                loc comp = "g"
            }
            else {
                loc girl = "!girl1"
                loc comp = "b"
            }
            file write grph "\caption*{First child a `sex'}" _n
            // Loop over periods including getting number of observations
            // Each period/sex combination is a minipage
            forvalues period = 1/4 {
                file write grph "\setcounter{subfigure}{`subfig_count'}" _n
                file write grph "\subfloat["
                // Get period and number of observations
                if `period' == 1 {
                    file write grph "1972--1984 (N="
                }
                else if `period' == 2 {
                    file write grph "1985--1994 (N="
                }
                else if `period' == 3 {
                    file write grph "1995--2004 (N="
                }
                else if `period' == 4 {
                    file write grph "2005--2016 (N=" 
                }
                use `data'/obs_spell2_`period'_`educ', clear
                sum num_obs if `urban' & `girl', mean
                if `r(N)' != 1 {
                    dis "There are more than 1 observation used for number of observations"
                    exit
                }
                file write grph %9.0fc (`r(mean)')
                file write grph ")]{" _n
                file write grph "   \begin{minipage}{0.22\textwidth}" _n
                file write grph "       \captionsetup[subfigure]{labelformat=empty,position=top,captionskip=-1pt,farskip=-0.5pt}" _n
                file write grph "       \subfloat[Prob.\ boy (\%)]{\includegraphics[width=\textwidth]{spell2_g`period'_`educ'_`area'_`comp'_pc}}\\" _n
                file write grph "       \subfloat[Prob.\ no birth yet]{\includegraphics[width=\textwidth]{spell2_g`period'_`educ'_`area'_`comp'_s}}" _n 
                file write grph "       \captionsetup[subfigure]{labelformat=parens}" _n
                file write grph "   \end{minipage}" _n
                file write grph "}" _n
                loc ++subfig_count         
            }
        }
        // LaTeX graph post-amble
        file write grph "\caption{Predicted probability of having a boy and probability of " _n
        file write grph "no birth yet from nine months after first birth for `area' women with `char' " _n
        file write grph "by month beginning at 9 months after prior birth.  " _n
        file write grph "Predictions based on age `age' at first birth. " _n
        file write grph "Left column shows results prior to sex selection available, middle column before " _n
        file write grph "sex selection illegal and right column after sex selection illegal. " _n
        file write grph "N indicates the number of women in the relevant group in the underlying samples. " _n
        file write grph "} " _n
        file write grph "\label{fig:results_spell2_`educ'_`area'} " _n
        file write grph "\end{figure}" _n
        file write grph _n(5)
    }
    file close grph
}


// Spell 3
// Organized by education and area; and within that by sex composition

// One figure per education level
foreach educ in "low" "med" "high" {

    // Information for caption
    if "`educ'" == "low" {
        loc char "no education"
        loc age = 20
    }
    if "`educ'" == "med" {
        loc char "1 to 7 years of education"
        loc age = 21
    }
    if "`educ'" == "high" {
        loc char "8 or more years of education"
        loc age = 24
    }

    file open grph using `figures'/appendix_spell3_`educ'.tex, write replace
    foreach area in "urban" "rural" {
    
        if "`area'" == "urban" {
            loc urban = "urban"
        }
        else {
            loc urban = "!urban"
        }
        
        // LaTeX graph preamble
        // Loop over sex composition - split over two figures (gg + bg & bb)
        loc subfig_count = -2 // counter increases throughout the figure and across figures
        foreach sex in "girls" "one boy and one girl" "boys" {
            if "`sex'" == "girls" {
                loc girl = "!girl1 & girl2"
                loc comp = "gg"
                file write grph "\begin{figure}[htpb!]" _n
                file write grph "\centering" _n
            }
            else if "`sex'" == "one boy and one girl" {
                loc girl = "girl1 & !girl2"
                loc comp = "bg"
            }
            else if "`sex'" == "boys" {
                loc girl = "!girl1 & !girl2"
                loc comp = "bb"
                file write grph "\begin{figure}[htpb!]" _n
                file write grph "\centering" _n  
                file write grph "\ContinuedFloat" _n          
            }
            file write grph "\caption*{First two children `sex'}" _n
            // Loop over periods including getting number of observations
            // Each period/sex combination is a minipage
            forvalues period = 1/4 {
                file write grph "\setcounter{subfigure}{`subfig_count'}" _n
                file write grph "\subfloat["
                // Get period and number of observations
                if `period' == 1 {
                    file write grph "1972--1984 (N="
                }
                else if `period' == 2 {
                    file write grph "1985--1994 (N="
                }
                else if `period' == 3 {
                    file write grph "1995--2004 (N="
                }
                else if `period' == 4 {
                    file write grph "2005--2016 (N=" 
                }
                use `data'/obs_spell3_`period'_`educ', clear
                sum num_obs if `urban' & `girl', mean
                if `r(N)' != 1 {
                    dis "There are more than 1 observation used for number of observations"
                    exit
                }
                file write grph %9.0fc (`r(mean)')
                file write grph ")]{" _n
                file write grph "   \begin{minipage}{0.22\textwidth}" _n
                file write grph "       \captionsetup[subfigure]{labelformat=empty,position=top,captionskip=-1pt,farskip=-0.5pt}" _n
                file write grph "       \subfloat[Prob.\ boy (\%)]{\includegraphics[width=\textwidth]{spell3_g`period'_`educ'_`area'_`comp'_pc}}\\" _n
                file write grph "       \subfloat[Prob.\ no birth yet]{\includegraphics[width=\textwidth]{spell3_g`period'_`educ'_`area'_`comp'_s}}" _n 
                file write grph "       \captionsetup[subfigure]{labelformat=parens}" _n
                file write grph "   \end{minipage}" _n
                file write grph "}" _n
                loc ++subfig_count         
            }
            if "`sex'" == "one boy and one girl" | "`sex'" == "boys" {
                if "`sex'" == "one boy and one girl" {
                    file write grph "\caption{Predicted probability of having a boy and probability of " _n
                }
                else if "`sex'" == "boys" {
                    file write grph "\caption{(Continued) Predicted probability of having a boy and probability of " _n
                }
                file write grph "no birth yet from nine months after second birth for `area' women with `char' " _n
                file write grph "by month beginning at 9 months after prior birth.  " _n
                file write grph "Predictions based on age `age' at second birth. " _n
                file write grph "Left column shows results prior to sex selection available, middle column before " _n
                file write grph "sex selection illegal and right column after sex selection illegal. " _n
                file write grph "N indicates the number of women in the relevant group in the underlying samples. " _n
                file write grph "} " _n
                if "`sex'" == "girls" {
                    file write grph "\label{fig:results_spell3_`educ'_`area'} " _n
                }
                file write grph "\end{figure}" _n
                file write grph _n(5)
            }
        }
    }
    file close grph
}


// Spell 4
// Organized by education and area; and within that by sex composition

// One figure per education level
foreach educ in "low" "med" "high" {

    // Information for caption
    if "`educ'" == "low" {
        loc char "no education"
        loc age = 23
    }
    if "`educ'" == "med" {
        loc char "1 to 7 years of education"
        loc age = 24
    }
    if "`educ'" == "high" {
        loc char "8 or more years of education"
        loc age = 25
    }

    file open grph using `figures'/appendix_spell4_`educ'.tex, write replace
    foreach area in "urban" "rural" {
    
        if "`area'" == "urban" {
            loc urban = "urban"
        }
        else {
            loc urban = "!urban"
        }
        
        // LaTeX graph preamble
        // Loop over sex composition - split over two figures (gg + bg & bb)
        loc subfig_count = -2 // counter increases throughout the figure and across figures
        foreach sex in "girls" "one boy and two girls" "two boys and one girl" "boys" {
            if "`sex'" == "girls" {
                loc girl = "!girl1 & !girl2 & girl3"
                loc comp = "ggg"
                file write grph "\begin{figure}[htpb!]" _n
                file write grph "\centering" _n
            }
            else if "`sex'" == "one boy and two girls" {
                loc girl = "!girl1 & girl2 & !girl3"
                loc comp = "bgg"
            }
            else if "`sex'" == "two boys and one girl" {
                loc girl = "girl1 & !girl2 & !girl3"
                loc comp = "bbg"
                file write grph "\begin{figure}[htpb!]" _n
                file write grph "\centering" _n  
                file write grph "\ContinuedFloat" _n          
            }
            else if "`sex'" == "boys" {
                loc girl = "!girl1 & !girl2 & !girl3"
                loc comp = "bbb"
            }
            file write grph "\caption*{First three children `sex'}" _n
            // Loop over periods including getting number of observations
            // Each period/sex combination is a minipage
            forvalues period = 1/4 {
                file write grph "\setcounter{subfigure}{`subfig_count'}" _n
                file write grph "\subfloat["
                // Get period and number of observations
                if `period' == 1 {
                    file write grph "1972--1984 (N="
                }
                else if `period' == 2 {
                    file write grph "1985--1994 (N="
                }
                else if `period' == 3 {
                    file write grph "1995--2004 (N="
                }
                else if `period' == 4 {
                    file write grph "2005--2016 (N=" 
                }
                use `data'/obs_spell4_`period'_`educ', clear
                sum num_obs if `urban' & `girl', mean
                if `r(N)' != 1 {
                    dis "There are more than 1 observation used for number of observations"
                    exit
                }
                file write grph %9.0fc (`r(mean)')
                file write grph ")]{" _n
                file write grph "   \begin{minipage}{0.22\textwidth}" _n
                file write grph "       \captionsetup[subfigure]{labelformat=empty,position=top,captionskip=-1pt,farskip=-0.5pt}" _n
                file write grph "       \subfloat[Prob.\ boy (\%)]{\includegraphics[width=\textwidth]{spell4_g`period'_`educ'_`area'_`comp'_pc}}\\" _n
                file write grph "       \subfloat[Prob.\ no birth yet]{\includegraphics[width=\textwidth]{spell4_g`period'_`educ'_`area'_`comp'_s}}" _n 
                file write grph "       \captionsetup[subfigure]{labelformat=parens}" _n
                file write grph "   \end{minipage}" _n
                file write grph "}" _n
                loc ++subfig_count         
            }
            if "`sex'" == "one boy and two girls" | "`sex'" == "boys" {
                if "`sex'" == "one boy and two girls" {
                    file write grph "\caption{Predicted probability of having a boy and probability of " _n
                }
                else if "`sex'" == "boys" {
                    file write grph "\caption{(Continued) Predicted probability of having a boy and probability of " _n
                }
                file write grph "no birth yet from nine months after third birth for `area' women with `char' " _n
                file write grph "by month beginning at 9 months after prior birth.  " _n
                file write grph "Predictions based on age `age' at third birth. " _n
                file write grph "Left column shows results prior to sex selection available, middle column before " _n
                file write grph "sex selection illegal and right column after sex selection illegal. " _n
                file write grph "N indicates the number of women in the relevant group in the underlying samples. " _n
                file write grph "} " _n
                if "`sex'" == "girls" {
                    file write grph "\label{fig:results_spell4_`educ'_`area'} " _n
                }
                file write grph "\end{figure}" _n
                file write grph _n(5)
            }
        }
    }
    file close grph
}


