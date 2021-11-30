***** Reproduction for BNTSE, Depetris et al. ******
***** Raimundo Contreras******
***** This do contains all commands necesary to reproduce all four claims made for this replication in https://www.socialsciencereproduction.org

***CLAIMS 1 & 2***


clear all
macro drop _all

* Insert here the directory containing all replication files and folders
global directory = "/Users/raimundo/Desktop/Depetris/115011-V1/AER-2018-0805_replication"
	global directory_final	"$directory/0-replication-afrobarometer/1-Final"
	global directory_source	"$directory/0-replication-afrobarometer/2-Source"
	global directory_results	"$directory/0-replication-afrobarometer/3-Results"
	global directory_temp	"$directory/0-replication-afrobarometer/4-Temp"
	
	
clear


use "$directory_final/1-afrobarometer_games_15days.dta"

set matsize 3000

local individual_controls male age age_sq unemployed rural education 

cd "$directory_results"

	
***Panel data
xtset country_match_fe


* First claim
reghdfe ethnic_sentiment post_match if main_sample==1, vce (cluster country_year_fe) absorb (i.country_match_fe i.language_year_id)


*Robustness check
reghdfe ethnic_sentiment post_match trust_ruling_party if main_sample==1, vce (cluster country_year_fe) absorb (i.country_match_fe i.language_year_id)



*Second claim
reghdfe ethnic_sentiment post_victory  male age age_sq unemployed rural education   if main_sample==1, vce (cluster country_year_fe) absorb (i.country_match_fe i.language_year_id i.dayweek i.day i.month)

*Robustness check
reghdfe ethnic_sentiment post_victory  male age age_sq unemployed rural education like_neighbors_ethnicities_d  if main_sample==1, vce (cluster country_year_fe) absorb (i.country_match_fe i.language_year_id i.dayweek i.day i.month)


***CLAIMS 3 & 4 ****


clear all
macro drop _all


global directory = "/Users/raimundo/Desktop/Depetris/115011-V1/AER-2018-0805_replication"
	global directory_final	"$directory/1-replication-acled/1-Final"
    global directory_source	"$directory/1-replication-acled/2-Source"
    global directory_temp	"$directory/1-replication-acled/3-Temp"
	global directory_results "$directory/1-replication-acled/4-Results"
	global directory_aux	"$directory/1-replication-acled/5-Auxiliary"


use "$directory_final/week_panel.dta"

xtset id week 

set more off

set matsize 3000

cd "$directory_results/"


global directory = "/Users/raimundo/Desktop/Depetris/115011-V1/AER-2018-0805_replication"
	global directory_final	"$directory/1-replication-acled/1-Final"
    global directory_source	"$directory/1-replication-acled/2-Source"
    global directory_temp	"$directory/1-replication-acled/3-Temp"
	global directory_results "$directory/1-replication-acled/4-Results"
	global directory_aux	"$directory/1-replication-acled/5-Auxiliary"


	
***3rd CLAIM***

*Third claim
reghdfe ln_ACLED_conflict post_qualification if CAN==1 & country != "CAMEROON", vce(cluster id) absorb (i.id i.week i.month_calendar)
*Robustness check
reghdfe ln_ACLED_conflict post_qualification if CAN==1 & big_wc_team == 0, vce(cluster id) absorb (i.id i.week i.month_calendar)

	
***4th CLAIM***

*4th claim
nbreg ACLED_conflict post_qualification  i.week i.id i.month_calendar if CAN==1, cluster (id)

*robustness check
nbreg ACLED_conflict post_qualification population_1990  i.week i.id i.month_calendar if CAN==1, cluster (id)



