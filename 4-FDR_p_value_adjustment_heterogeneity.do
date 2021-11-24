* ----------------------------------------------------------------------------------------------------------------------------*
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


**** This do file will generate a latex file (labeled p-score-values-for-tab_het.tex) with p-values for 2 Tables with heterogeneity analysis
* The first line (i.e., T1) delivers adjusted p-values for post-victory coefficients in columns 2 to 8 of Table 3 
* The second line (i.e., T1 - interactions) delivers adjusted p-values for interaction terms in columns 2 to 8 of Table 3
* The third line (i.e., T2)  delivers adjusted p-values for post-victory coefficients in columns 1 to 6 of Table A.7
* The fourth line (i.e., T2 - interactions) delivers adjusted p-values for interaction terms in columns 1 to 6 of Table A.7


//=======================================================BEGIN-DO-FILE=======================================================//

*#1
*
*
global datasetPScoreCorrections "0-p-scores-Anderson_est"
global level_of_p_scores = 0.0001

*generate file for p-score correction
preserve
	clear
	g reg =	 ""
	g parm = ""
	g pval = .

	save "$directory_final/$datasetPScoreCorrections_het.dta", replace
restore

//----------------------------------------------------------------------------------------------------------------------------//

set more off
clear all

use "$directory_final/1-afrobarometer_games_15days.dta"

set matsize 3000

*cd "$directory_results"


merge m:m country year using "$directory_temp/team_diversity.dta"

drop _merge

ren local* dummy_local*

foreach var in rivalry_teams dummy_local high_difference total_goals_scored {

	gen `var' = `var'1 if Nmatch == 1 & main_sample == 1
	replace `var' = `var'_1 if Nmatch == 0 & main_sample == 1
}

foreach w in rivalry_teams dummy_local high_difference total_goals_scored rural state_presence elf team_diversity major_ethnicity male unemployed education age {

	sum `w' if main_sample == 1
	gen `w'_dem = `w' - r(mean)
}


//===========================================================================================================================//

set matsize 11000
global counterTableNumber = 0

capture program drop newTable
program newTable

	/* function newTable
	inputs: none
	outputs: none
	description: add one to counter of tables and set to 1 counter of columns
	*/

	global counterTableNumber = $counterTableNumber + 1
	global counterColumnNumber = 0
end

*TODO: make the function take the counter for table and column (plan B use globals)
capture program drop addToPScoreCorrection
program addToPScoreCorrection

    /* function addToPScoreCorrection
    inputs: none
    outputs: none
    description: add new estimates for p-score corrections
    */
    args varsForPScoreCorrection

	*increase column number only when is not an interaction term
	if !strpos("`varsForPScoreCorrection'", "c.post_victory#") {
		global counterColumnNumber = $counterColumnNumber + 1
	}

	display "Saving p-value of T$counterTableNumber C$counterColumnNumber `varsForPScoreCorrection'"

	quiet {

		*save p-value
		preserve
			parmest ,  list(parm  p,clean noobs) norestore
			keep if parm == "`varsForPScoreCorrection'"
			keep p parm
			g reg = "T$counterTableNumber C$counterColumnNumber `varsForPScoreCorrection'"
			rename p pval
			append using "$directory_final/$datasetPScoreCorrections_het.dta"
			save "$directory_final/$datasetPScoreCorrections_het.dta", replace
		restore
	}
end

*#2
*								MAIN ESTIMATIONS
*								================

set more off


local individual_controls male age age_sq unemployed rural education

** Recovering unadjusted p-values from Table 3
newTable
** Column 2
reghdfe ethnic_sentiment post_victory c.post_victory#c.rivalry_teams_dem `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
    display "Checking whether the method is capturing the p-score of c.post_victory#*..."
    assert strpos("`=word("`e(cmdline)'", 4)'", "c.post_victory#")
    addToPScoreCorrection post_victory
	addToPScoreCorrection `=word("`e(cmdline)'", 4)'

** Column 3
reghdfe ethnic_sentiment post_victory c.post_victory#c.dummy_local_dem `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
    display "Checking whether the method is capturing the p-score of c.post_victory#*..."
    assert strpos("`=word("`e(cmdline)'", 4)'", "c.post_victory#")
    addToPScoreCorrection post_victory
	addToPScoreCorrection `=word("`e(cmdline)'", 4)'

** Column 4
reghdfe ethnic_sentiment post_victory c.post_victory#c.high_difference_dem `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
    display "Checking whether the method is capturing the p-score of c.post_victory#*..."
    assert strpos("`=word("`e(cmdline)'", 4)'", "c.post_victory#")
    addToPScoreCorrection post_victory
	addToPScoreCorrection `=word("`e(cmdline)'", 4)'

** Column 5 
reghdfe ethnic_sentiment post_victory c.post_victory#c.total_goals_scored_dem `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
    display "Checking whether the method is capturing the p-score of c.post_victory#*..."
    assert strpos("`=word("`e(cmdline)'", 4)'", "c.post_victory#")
    addToPScoreCorrection post_victory
	addToPScoreCorrection `=word("`e(cmdline)'", 4)'

** Column 6
reghdfe ethnic_sentiment post_victory c.post_victory#c.state_presence_dem age age_sq state_presence_dem unemployed rural education if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
    display "Checking whether the method is capturing the p-score of c.post_victory#*..."
    assert strpos("`=word("`e(cmdline)'", 4)'", "c.post_victory#")
    addToPScoreCorrection post_victory
	addToPScoreCorrection `=word("`e(cmdline)'", 4)'

** Column 7
reghdfe ethnic_sentiment post_victory c.post_victory#c.elf_dem male  age age_sq unemployed rural education if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
    display "Checking whether the method is capturing the p-score of c.post_victory#*..."
    assert strpos("`=word("`e(cmdline)'", 4)'", "c.post_victory#")
    addToPScoreCorrection post_victory
	addToPScoreCorrection `=word("`e(cmdline)'", 4)'

** Column 8
reghdfe ethnic_sentiment post_victory c.post_victory#c.team_diversity_dem male  age age_sq  unemployed rural education if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
    display "Checking whether the method is capturing the p-score of c.post_victory#*..."
    assert strpos("`=word("`e(cmdline)'", 4)'", "c.post_victory#")
    addToPScoreCorrection post_victory
	addToPScoreCorrection `=word("`e(cmdline)'", 4)'

	
 * Recovering unadjusted p-values from Table A.7
newTable
** Column 1
reghdfe ethnic_sentiment post_victory c.post_victory#c.rural_dem male_dem age age_sq unemployed rural_dem education  if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
    display "Checking whether the method is capturing the p-score of c.post_victory#*..."
    assert strpos("`=word("`e(cmdline)'", 4)'", "c.post_victory#")
    addToPScoreCorrection post_victory
	addToPScoreCorrection `=word("`e(cmdline)'", 4)'

** Column 2
reghdfe ethnic_sentiment post_victory c.post_victory#c.unemployed_dem male_dem age age_sq unemployed_dem rural education  if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
    display "Checking whether the method is capturing the p-score of c.post_victory#*..."
    assert strpos("`=word("`e(cmdline)'", 4)'", "c.post_victory#")
    addToPScoreCorrection post_victory
	addToPScoreCorrection `=word("`e(cmdline)'", 4)'

** Column 3
reghdfe ethnic_sentiment post_victory c.post_victory#c.male_dem male_dem age age_sq unemployed rural education  if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
    display "Checking whether the method is capturing the p-score of c.post_victory#*..."
    assert strpos("`=word("`e(cmdline)'", 4)'", "c.post_victory#")
    addToPScoreCorrection post_victory
	addToPScoreCorrection `=word("`e(cmdline)'", 4)'

** Column 4
reghdfe ethnic_sentiment post_victory c.post_victory#c.education_dem  male age age_sq unemployed rural education_dem  if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
    display "Checking whether the method is capturing the p-score of c.post_victory#*..."
    assert strpos("`=word("`e(cmdline)'", 4)'", "c.post_victory#")
    addToPScoreCorrection post_victory
	addToPScoreCorrection `=word("`e(cmdline)'", 4)'

** Column 5
reghdfe ethnic_sentiment post_victory c.post_victory#c.age_dem  male age_dem age_sq unemployed rural education  if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
    display "Checking whether the method is capturing the p-score of c.post_victory#*..."
    assert strpos("`=word("`e(cmdline)'", 4)'", "c.post_victory#")
    addToPScoreCorrection post_victory
	addToPScoreCorrection `=word("`e(cmdline)'", 4)'

** Column 6
reghdfe ethnic_sentiment post_victory c.post_victory#c.major_ethnicity_dem  major_ethnicity_dem male age age_sq unemployed rural education  if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
    display "Checking whether the method is capturing the p-score of c.post_victory#*..."
    assert strpos("`=word("`e(cmdline)'", 4)'", "c.post_victory#")
    addToPScoreCorrection post_victory
	addToPScoreCorrection `=word("`e(cmdline)'", 4)'

//===========================================================================================================================//

*#2
*								CORRECT P-SCORES ANDERSON (2008)
*								================================

set more off

clear all

use "$directory_final/$datasetPScoreCorrections_het.dta"

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
save "$directory_temp/2-p-values-for-tex_het.dta", replace


//===========================================================================================================================//

*#3
*								PREPARE .TEX FILE
*								=================

set more off

clear all

*open dataset
use "$directory_temp/2-p-values-for-tex_het.dta"


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

gen str_bh95_qvalues_for_tables = str_bh95_qvalues

*separate name of lines of main effects from the ones of interactions
replace split1 = split1 + "-Interactions" if strpos(reg, "c.#c.")

sort split1 split2

by split1: replace str_bh95_qvalues_for_tables = str_bh95_qvalues_for_tables[_n-1] + " & " + str_bh95_qvalues_for_tables if _n != _N
by split1: replace str_bh95_qvalues_for_tables = str_bh95_qvalues_for_tables[_n-1] + " & " + str_bh95_qvalues_for_tables + " // " ///
											if _n == _N

replace str_bh95_qvalues_for_tables = trim(subinstr(str_bh95_qvalues_for_tables,"& 0 &","& 0.00 &",.))
replace str_bh95_qvalues_for_tables = trim(subinstr(str_bh95_qvalues_for_tables,"& 0 //","& 0.00 //",.))

*keep one line by table and variable
by split1: keep if _n == _N

keep split1 str_bh95_qvalues_for_tables

*Begin latex file writting

tempname hh
file open `hh' using "$directory_results/p-score-values-for-tab_het.tex", write replace

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
