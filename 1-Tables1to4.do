
* ----------------------------------------------------------------------------------------------------------------------------*
* Replication code for "Building Nations Through Shared Experiences: Evidence from African Football" (Depetris-Chauvin, Durante, and Campante)
* Stata 14.0
* ----------------------------------------------------------------------------------------------------------------------------*

*Program setup

version 14

clear all
macro drop _all


global directory = "XYZ/AER-2018-0805_replication"
	global directory_final	"$directory/0-replication-afrobarometer/1-Final"
	global directory_source	"$directory/0-replication-afrobarometer/2-Source"
	global directory_results	"$directory/0-replication-afrobarometer/3-Results"
	global directory_temp	"$directory/0-replication-afrobarometer/4-Temp"



*Install reuired packages 
    local ssc_packages "reghdfe" "outreg2" "ftools"


    if !missing("`ssc_packages'") {
        foreach pkg in "`ssc_packages'" {
            dis "Installing `pkg'"
            quietly ssc install `pkg', replace
        }
    }
		
	*
	
	**Table 1

use "$directory_final/1-afrobarometer_games_15days.dta"

cd "$directory_results"


*panel set
xtset country_match_fe



* local inv for variables considered.
local inv male education age unemployed major_ethnicity rural religious_group_member public_goods same_language influenced_by_others male_interv education_interviewer age_interviewer
local inv_n: word count `inv'


*obtain each label for names of covariates in latex table
forvalues i = 1 / `inv_n' {
		 local inv_name: word `i' of `inv'
         local inv`i' : var label `inv_name'
 }
*

** Number of Observations and Mean Values
foreach v of local inv {	
	    sum `v' if main_sample==1 
}
*
***Panel A
*Post Game
foreach v of local inv {	
	    xtreg `v' post_match if main_sample==1, fe  vce (cluster country_year_fe) 
		outreg2 using Table1A, append tex bracket bdec(3) sdec(3) noaster keep (post_match)

}
*


***Panel B
*Post Victory
foreach v of local inv {	
	    xtreg `v' post_victory if main_sample==1, fe  vce (cluster country_year_fe) 
		outreg2 using Table1B, append tex bracket bdec(3) sdec(3) noaster keep (post_victory)

}
*


clear


use "$directory_final/1-afrobarometer_games_15days.dta"

set matsize 3000

local individual_controls male age age_sq unemployed rural education 

cd "$directory_results"


*** Table 2
*Column 1
reghdfe ethnic_sentiment post_match if main_sample==1, vce (cluster country_year_fe) absorb (i.country_match_fe i.language_year_id)
outreg2 using Table2, replace tex bracket bdec(3) sdec(3) noaster keep (post_match)
*Column 2
reghdfe ethnic_sentiment post_match `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.country_match_fe i.language_year_id )
outreg2 using Table2, append tex bracket bdec(3) sdec(3) noaster keep (post_match)

*Column 3
reghdfe ethnic_sentiment post_match `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.country_match_fe i.language_year_id i.dayweek i.day i.month)
outreg2 using Table2, append tex bracket bdec(3) sdec(3) noaster keep (post_match)

*Column 4
reghdfe ethnic_sentiment post_match post_victory `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.country_match_fe i.language_year_id i.dayweek i.day i.month)
outreg2 using Table2, append tex bracket bdec(3) sdec(3) noaster keep (post_match post_victory)

*Column 5
reghdfe ethnic_sentiment post_victory post_draw post_defeat `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.country_match_fe i.language_year_id i.dayweek i.day i.month)
outreg2 using Table2, append tex bracket bdec(3) sdec(3) noaster  keep (post_victory post_draw post_defeat)

*Column 6
reghdfe ethnic_sentiment post_victory  `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.country_match_fe i.language_year_id i.dayweek i.day i.month)
outreg2 using Table2, append tex bracket bdec(3) sdec(3) noaster  keep (post_victory post_draw post_defeat)

*Column 7
probit ethnic_sentiment post_victory  `individual_controls' i.country_match_fe i.language_year_id i.dayweek i.day i.month if main_sample==1,  vce (cluster country_year_fe) 
outreg2 using Table2, append tex bracket bdec(3) sdec(3) noaster keep (post_victory)
*Post-Victory Marginal Effect in Column 7
margins , dydx(post_victory) at(male=(.50) age=(36.9) age_sq=(1361.61) unemployed=(0.30) rural=(.61) education=(3.08))
**Alternatively, the following coding can be used but may have some problems with the calculation of numerical derivatives due to the fixed effects:
*  margins , dydx(post_victory) atmeans


**Note: P-values adjustment in a separate dofile
clear



*** Table 3

use "$directory_final/5-afrobarometer_games_15days_friendly_matches.dta"

cd "$directory_results"

set more off
set matsize 11000
local individual_controls male age age_sq unemployed rural education

** Column 1
reghdfe ethnic_sentiment post_victory `individual_controls' , vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
outreg2 using Table3, replace tex bdec(3) sdec(3)  noaster keep (post_victory)


********

clear
use "$directory_final/1-afrobarometer_games_15days.dta"
set matsize 3000

merge m:m country year using "$directory_temp/team_diversity.dta"

drop _merge

cd "$directory_results"

ren local* dummy_local*

foreach var in rivalry_teams dummy_local high_difference total_goals_scored {

	gen `var' = `var'1 if Nmatch == 1 & main_sample == 1
	replace `var' = `var'_1 if Nmatch == 0 & main_sample == 1
}

foreach w in rivalry_teams dummy_local high_difference total_goals_scored state_presence elf team_diversity  {

	sum `w' if main_sample == 1
	gen `w'_dem = `w' - r(mean)
}



local individual_controls male age age_sq unemployed rural education 


**Column 2
reghdfe ethnic_sentiment post_victory c.post_victory#c.rivalry_teams_dem `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
outreg2 using Table3, append  tex bdec(3) sdec(3)  noaster keep (post_victory c.post_victory#c.rivalry_teams_dem)

**Column 3
reghdfe ethnic_sentiment post_victory c.post_victory#c.dummy_local_dem `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
outreg2 using Table3, append  tex bdec(3) sdec(3) noaster   keep (post_victory c.post_victory#c.dummy_local_dem )

**Column 4
reghdfe ethnic_sentiment post_victory c.post_victory#c.high_difference_dem `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
outreg2 using Table3, append  tex bdec(3) sdec(3)  noaster keep (post_victory c.post_victory#c.high_difference_dem)

**Column 5
reghdfe ethnic_sentiment post_victory c.post_victory#c.total_goals_scored_dem `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
outreg2 using Table3, append tex bdec(3) sdec(3)  noaster  keep (post_victory c.post_victory#c.total_goals_scored_dem)

**Column 6
reghdfe ethnic_sentiment post_victory c.post_victory#c.state_presence_dem age age_sq state_presence_dem unemployed rural education if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
outreg2 using Table3, append  tex bdec(3) sdec(3)  noaster keep (post_victory c.post_victory#c.state_presence_dem state_presence_dem)

**Column 7
reghdfe ethnic_sentiment post_victory c.post_victory#c.elf_dem male  age age_sq unemployed rural education if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
outreg2 using Table3, append  tex bdec(3) sdec(3)  noaster keep (post_victory c.post_victory#c.elf_dem)

**Column 8
reghdfe ethnic_sentiment post_victory c.post_victory#c.team_diversity_dem male  age age_sq  unemployed rural education if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
outreg2 using Table3, append  tex bdec(3) sdec(3)  noaster keep (post_victory c.post_victory#c.team_diversity_dem)


clear

**********

use "$directory_final/1-afrobarometer_games_15days.dta"
set matsize 3000
cd "$directory_results"

***Table 4
*Column 1
reghdfe trust_people_d post_victory `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
outreg2 using Table4, replace tex bdec(3) sdec(3) noaster keep (post_victory) 


*Column 2
reg trust_intergroup_d post_victory `individual_controls' i.language_year_id i.country_match_fe i.dayweek i.day i.month if main_sample==1, vce (cluster country_year_fe) 
outreg2 using Table4, append tex bdec(3) sdec(3) noaster keep (post_victory) 

*Column 3
reghdfe like_neighbors_ethnicities_d post_victory `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
outreg2 using Table4, append tex bdec(3) sdec(3) noaster keep (post_victory) 


*Column 4
reghdfe dislike_foreign_neighbors_d post_victory `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
outreg2 using Table4, append tex bdec(3) sdec(3) noaster keep (post_victory) 


clear

