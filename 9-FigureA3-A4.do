
* ----------------------------------------------------------------------------------------------------------------------------*
* Replication code for "Building Nations Through Shared Experiences: Evidence from African Football" (Depetris-Chauvin, Durante, and Campante)
* Stata 14.2
* ----------------------------------------------------------------------------------------------------------------------------*

*Program setup

version 14

clear all
macro drop _all


global directory = "XYZ/AER-2018-0805_replication"
	global directory_final	"$directory/0-replication-afrobarometer/1-Final"
	global directory_source	"$directory/0-replication-afrobarometer/2-Source"
	global directory_results	"$directory/0-replication-afrobarometer/3-Results"


set matsize 3000

use "$directory_final/1-afrobarometer_games_15days.dta"


cd "$directory_results"

set more off


encode country, gen(countryNumeric)

label var post_victory "Victory"

*Divide country_match_fe in two
egen group_country_match_fe = group(country_match_fe)

sum group_country_match_fe
scalar half_country_match_fe = int(r(max)/2)
scalar max_country_match_fe = r(max)

gen ctry_match_feA = country_match_fe if inrange(group_country_match_fe, 1, half_country_match_fe)
gen ctry_match_feB = country_match_fe if inrange(group_country_match_fe, half_country_match_fe + 1, max_country_match_fe)

global variablesToExcludeObs countryNumeric AF ctry_match_feA ctry_match_feB

capture program drop regressionStoreForCoefPlots
program regressionStoreForCoefPlots

	/* function regressionStoreForCoefPlots
	inputs: string variables
	outputs: estimates stores for coefplot
	description: estimate the main regression excluding one value of the variable each times
	*/

	args variable
	local individual_controls male age age_sq unemployed rural education
	

	levelsof `variable', local(variable_levels)

	local counter = 0
	foreach var in `variable_levels' {
		local counter = `counter' + 1

		reghdfe ethnic_sentiment post_victory `individual_controls'  if main_sample==1 & `variable' != `var', vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)

		estimates store `variable'Regress`var'
	}
end

capture program drop generateListForCoefplots
program generateListForCoefplots

	/* function generateListForCoefplots
	inputs: numeric variables
	outputs: list for code of coefplots
	description: generates a list for coefplots code
	*/

	args variable

	local counter = 0
	global stores`variable' = " "

	levelsof `variable', local(variable_levels)

	foreach var in `variable_levels' {
		global stores`variable' = "${stores`variable'}" + " `variable'Regress`var'"
	}
end


foreach obsToExclude in $variablesToExcludeObs {
	display "working on `obsToExclude'"
	regressionStoreForCoefPlots `obsToExclude'
	generateListForCoefplots `obsToExclude'
}

foreach obsToExclude in $variablesToExcludeObs {
	display "working on `obsToExclude'"
	coefplot "${stores`obsToExclude'}", vertical keep(post_victory) xline(0) bgcolor(white) graphregion(color(white)) ytitle("Effect on Ethnic Identification" " ") xtitle("" "" ) title( "" , color(black) span ring(10) ) legend(off) lcol(black) mcol(black) ciopts(lcol(black))
	graph export "$directory_results/1-Graph-excluding-from-`obsToExclude'.pdf", as(pdf) replace
	graph save Graph "$directory_results/1-Graph-excluding-from-`obsToExclude'.gph"
}


