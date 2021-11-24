** ----------------------------------------------------------------------------------------------------------------------------*
* Replication code for "Building Nations Through Shared Experiences: Evidence from African Football" (Depetris-Chauvin, Durante, and Campante)
* Stata 14.2
* ----------------------------------------------------------------------------------------------------------------------------*

version 14

clear all
macro drop _all

global directory = "XYZ/AER-2018-0805_replication"
	global directory_final	"$directory/0-replication-afrobarometer/1-Final"
	global directory_source	"$directory/0-replication-afrobarometer/2-Source"
	global directory_results	"$directory/0-replication-afrobarometer/3-Results"
	global directory_temp	"$directory/0-replication-afrobarometer/4-Temp"

set more off

clear all

ssc install parmest


**** This do file will generate a latex file (labeled p-score-values-for-tab.tex) with p-values for a group of 5 Tables
* The first line (i.e., T1) delivers adjusted p-values for post-victory coefficients in columns 1 to 5 of Table A.8 (adjusted p-values in Table 2 of main manuscript can be recovered from Table A.8)
* The second line (i.e., T2) delivers adjusted p-values for post-victory coefficients in columns 1 to 3 of Table 4
* The third line (i.e., T3)  delivers adjusted p-values for post-victory coefficients in columns 1 to 3 of Table A.2
* The fourth line (i.e., T4) delivers adjusted p-values for post-victory coefficients when 4 indicators for the assesment of present and future own and country's economic conditions are considered as outcome variables
* The fifth line (i.e., T5) delivers adjusted p-values for post-victory coefficients in columns 1 to 6 in Table A.9

//============	===========================================BEGIN-DO-FILE=======================================================//
	

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!ADD!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
global datasetPScoreCorrections "0-p-scores-Anderson_est"
global indepentVarPScore "post_victory"

*generate file for p-score correction
preserve
	clear
	g reg =	 ""
	g parm = ""
	g pval = .

	save "$directory_final/$datasetPScoreCorrections.dta", replace
restore
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!ADD!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//

//----------------------------------------------------------------------------------------------------------------------------//

set more off

use "$directory_final/1-afrobarometer_games_15days.dta"


//===========================================================================================================================//

set matsize 11000
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!ADD!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
global counterTableNumber = 0

capture program drop newTable
program newTable

	/* function newTable
	inputs: none
	outputs: none
	description: add one to counter of tables and set to 1 counter of columns
	*/

	global counterTableNumber = $counterTableNumber + 1
	global counterColumnNumber = 1
end

*TODO: make the function take the counter for table and column (plan B use globals)
capture program drop addToPScoreCorrection
program addToPScoreCorrection

    /* function addToPScoreCorrection
    inputs: none
    outputs: none
    description: add new estimates for p-score corrections
    */
    args varForPScoreCorrection

        *TODO: correct to add other x
        preserve
            parmest ,  list(parm  p,clean noobs) norestore
            keep if parm == "`varForPScoreCorrection'"
            keep p parm
            g reg = "T$counterTableNumber C$counterColumnNumber `varForPScoreCorrection'"
            rename p pval
            append using "$directory_final/$datasetPScoreCorrections.dta"
            save "$directory_final/$datasetPScoreCorrections.dta", replace
        restore

        global counterColumnNumber = $counterColumnNumber + 1
end



//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!ADD!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//

*#2
*								MAIN ESTIMATIONS
*								================

set more off


local individual_controls male age age_sq unemployed rural education 

*Main estimations
newTable
	* Table A.18 (adjusted p-values in columns 4 and 5 of Table 2 can be recovered from this table)
	** Column 1
reghdfe ethnic_sentiment post_victory `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.country_year_fe)
addToPScoreCorrection `=word("`e(cmdline)'", 3)'

** Column 2
reghdfe ethnic_sentiment post_victory `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.country_year_fe i.dayweek i.day i.month)
addToPScoreCorrection `=word("`e(cmdline)'", 3)'

** Column 3
reghdfe ethnic_sentiment post_victory `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.country_year_fe i.language_year_id i.dayweek i.day i.month)
addToPScoreCorrection `=word("`e(cmdline)'", 3)'

** Column 4
reghdfe ethnic_sentiment post_victory `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.country_match_fe i.language_year_id i.dayweek i.day i.month)
addToPScoreCorrection `=word("`e(cmdline)'", 3)'

** Column 5
reghdfe ethnic_sentiment post_victory post_draw post_defeat `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.country_match_fe i.language_year_id i.dayweek i.day i.month)
addToPScoreCorrection `=word("`e(cmdline)'", 3)'

*** Table 4
newTable
* Trust
reghdfe trust_people_d post_victory `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
addToPScoreCorrection `=word("`e(cmdline)'", 3)'

reg trust_intergroup_d post_victory `individual_controls' i.language_year_id i.country_match_fe i.dayweek i.day i.month if main_sample==1, vce (cluster country_year_fe) 
addToPScoreCorrection `=word("`e(cmdline)'", 3)'

reghdfe like_neighbors_ethnicities_d post_victory `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
addToPScoreCorrection `=word("`e(cmdline)'", 3)'


reghdfe dislike_foreign_neighbors_d post_victory `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
addToPScoreCorrection `=word("`e(cmdline)'", 3)'


** Table A.2
newTable
**Baseline
reghdfe ethnic_sentiment  post_victory `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.country_match_fe i.language_year_id i.dayweek i.day i.month)
addToPScoreCorrection `=word("`e(cmdline)'", 3)'

reghdfe ethnic_sentiment  post_victory `individual_controls'  if main_sample==1 & ethnic_year_id!=., vce (cluster country_year_fe) absorb (i.country_match_fe i.language_year_id i.dayweek i.day i.month)
addToPScoreCorrection `=word("`e(cmdline)'", 3)'

reghdfe ethnic_sentiment  post_victory `individual_controls'  if main_sample==1 & ethnic_year_id!=., vce (cluster country_year_fe) absorb (i.country_match_fe i.ethnic_year_id i.dayweek i.day i.month)
addToPScoreCorrection `=word("`e(cmdline)'", 3)'




*** Additional Hypotheses
newTable
* Trust in ruling party
reghdfe trust_ruling_party_d post_victory `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
addToPScoreCorrection `=word("`e(cmdline)'", 3)'

* Approval of the president
reghdfe approve_president_d  post_victory `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
addToPScoreCorrection `=word("`e(cmdline)'", 3)'

* Assessmnent of country conditions (present)
reghdfe ctry_cond_today_d  post_victory `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
addToPScoreCorrection `=word("`e(cmdline)'", 3)'

* Assessmnent of country conditions (future)
reghdfe ctry_cond_future_d   post_victory `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
addToPScoreCorrection `=word("`e(cmdline)'", 3)'

* Assessmnent of own living conditions (present)
reghdfe own_cond_today_d   post_victory `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
addToPScoreCorrection `=word("`e(cmdline)'", 3)'

* Assessmnent of own living conditions (future)
reghdfe own_cond_future_d    post_victory `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
addToPScoreCorrection `=word("`e(cmdline)'", 3)'



** Table A.9
newTable
* Column 1
reghdfe ethnic_sentiment post_victory `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
addToPScoreCorrection `=word("`e(cmdline)'", 3)'

* Column 2
reghdfe ethnic_sentiment post_victory `individual_controls'  if main_sample==1 &  abs_distance<6, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
addToPScoreCorrection `=word("`e(cmdline)'", 3)'

* Column 3
reghdfe ethnic_sentiment post_victory `individual_controls'  if main_sample==1 &  abs_distance<11, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
addToPScoreCorrection `=word("`e(cmdline)'", 3)'

preserve


***

use "$directory_final/2-afrobarometer_games_20days.dta", clear

set matsize 3000

cd "$directory_results"

local individual_controls male age age_sq unemployed rural education 

*Column 4
reghdfe ethnic_sentiment post_victory `individual_controls', vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
addToPScoreCorrection `=word("`e(cmdline)'", 3)'




***

use "$directory_final/3-afrobarometer_games_25days.dta", clear

set matsize 3000

cd "$directory_results"

local individual_controls male age age_sq unemployed rural education 

*Column 5
reghdfe ethnic_sentiment post_victory `individual_controls', vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
addToPScoreCorrection `=word("`e(cmdline)'", 3)'





***

use "$directory_final/4-afrobarometer_games_30days.dta", clear

set matsize 3000

cd "$directory_results"

local individual_controls male age age_sq unemployed rural education 

*Column 6
reghdfe ethnic_sentiment post_victory `individual_controls', vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
addToPScoreCorrection `=word("`e(cmdline)'", 3)'


restore

*/	

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!ADD!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
*#2
*								CORRECT P-SCORES ANDERSON (2008)
*								================================

set more off

clear all

use "$directory_final/$datasetPScoreCorrections.dta"

* Collect the total number of p-values tested

quietly sum pval
local totalpvals = r(N)

* Sort the p-values in ascending order and generate a variable that codes each p-value's rank

quietly gen int original_sorting_order = _n
quietly sort pval
quietly gen int rank = _n if pval~=.

* Set the initial counter to 1

local qval = 1

* Generate the variable that will contain the BH (1995) q-values

gen bh95_qval = 1 if pval~=.

* Set up a loop that begins by checking which hypotheses are rejected at q = 1.000, then checks which hypotheses are rejected at q = 0.999, then checks which hypotheses are rejected at q = 0.998, etc.  The loop ends by checking which hypotheses are rejected at q = 0.001.

while `qval' > 0 {
	* Generate value qr/M
	quietly gen fdr_temp = `qval'*rank/`totalpvals'
	* Generate binary variable checking condition p(r) <= qr/M
	quietly gen reject_temp = (fdr_temp>=pval) if fdr_temp~=.
	* Generate variable containing p-value ranks for all p-values that meet above condition
	quietly gen reject_rank = reject_temp*rank
	* Record the rank of the largest p-value that meets above condition
	quietly egen total_rejected = max(reject_rank)
	* A p-value has been rejected at level q if its rank is less than or equal to the rank of the max p-value that meets the above condition
	replace bh95_qval = `qval' if rank <= total_rejected & rank~=.
	* Reduce q by 0.001 and repeat loop
	quietly drop fdr_temp reject_temp reject_rank total_rejected
	local qval = `qval' - .001
}

quietly sort original_sorting_order
pause off
set more on

display "Code has completed."
display "Benjamini Hochberg (1995) q-vals are in variable 'bh95_qval'"
display	"Sorting order is the same as the original vector of p-values"

*save dataset

compress
label dat "p-values for .tex tables, JMP, Stata`c(version)', `c(current_date)'"
save "$directory_temp/2-p-values-for-tex_main.dta", replace

//===========================================================================================================================//

*#3
*								PREPARE .TEX FILE
*								=================

set more off

clear all

*open dataset
use "$directory_temp/2-p-values-for-tex_main.dta"

display `c(N)'
set obs `=`c(N)'+1'

*fill new var

replace reg = "T1 C6 post_victory" if missing(reg)

sort reg

replace reg = trim(subinstr(reg,"post_victory","",.))

keep bh95_qval reg
order reg

split reg, gen(split)

replace split2 = trim(subinstr(split2,"C","",.))
destring split2, replace

gen bh95_qvalues = round(bh95_qval, 0.0001)

gen str_bh95_qvalues = string(bh95_qvalues)
replace str_bh95_qvalues = trim(subinstr(str_bh95_qvalues,".","0.",.))

replace str_bh95_qvalues = "" if reg == "T1 C6"

gen str_bh95_qvalues_for_tables = str_bh95_qvalues

sort split1 split2
by split1: replace str_bh95_qvalues_for_tables = str_bh95_qvalues_for_tables[_n-1] + " & " + str_bh95_qvalues_for_tables if _n != _N
by split1: replace str_bh95_qvalues_for_tables = str_bh95_qvalues_for_tables[_n-1] + " & " + str_bh95_qvalues_for_tables + " // " ///
											if _n == _N

replace str_bh95_qvalues_for_tables = trim(subinstr(str_bh95_qvalues_for_tables,"& 0 &","& 0.00 &",.))
replace str_bh95_qvalues_for_tables = trim(subinstr(str_bh95_qvalues_for_tables,"& 0 //","& 0.00 //",.))


by split1: keep if _n == _N

keep split1 str_bh95_qvalues_for_tables

*Begin latex file writting

tempname hh
file open `hh' using "$directory_results/p-score-values-for-tab.tex", write replace

forvalues i = 1/`c(N)' {
			local table_N `=split1[`i']'
			local table_values `=str_bh95_qvalues_for_tables[`i']'
			display "`table_N'"
			file write `hh' "% `table_N'"  _newline
			file write `hh' " `table_values'"  _newline
			file write `hh' " " _newline
}
*

file write `hh' " " _newline

file close `hh'
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!ADD!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
