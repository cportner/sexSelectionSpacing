// Common header

version 13.1
clear all

// Load helper programs
capture program drop _all
do fun_helpers
do baseline_hazards/bh_low.do
do baseline_hazards/bh_med.do
do baseline_hazards/bh_high.do

include directories

use `data'/base
