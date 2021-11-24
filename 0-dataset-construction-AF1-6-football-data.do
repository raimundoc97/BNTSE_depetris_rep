* ----------------------------------------------------------------------------------------------------------------------------------------------*
* Replication code for "Building Nations Through Shared Experiences: Evidence from African Football" (Depetris-Chauvin, Durante, and Campante)
* Stata 14.0
* ----------------------------------------------------------------------------------------------------------------------------------------------*
** Dataset Construction for Individual Level Analysis

*Program setup
version 14

clear all
macro drop _all

global directory = "XYZ/AER-2018-0805_replication"
	global directory_final	"$directory/0-replication-afrobarometer/1-Final"
	global directory_source	"$directory/0-replication-afrobarometer/2-Source"
	global directory_temp	"$directory/0-replication-afrobarometer/4-Temp"

	cd "$directory"

*#
*								BEGIN DATASET CONSTRUCTION
*								==========================

set more off

clear all

** We use appended waves 2 to 6 of Afrobarometer (AF-rounds-2-3-4-5-6.dta)
* Raw data and codebooks by wave is available here: https://www.afrobarometer.org/data/merged-data
* PDF file "Codebook_AF-rounds-2-3-4-5-6" in folder "$directory/2-Source" documents all changes in
		*	a) labeling of original variable indicating the original label in each wave
		*   b) source of any additional variable merged to AF-rounds-2-3-4-5-6.dta
* PDF file "EditionLanguages&Ethnicities" in folder "$directory/2-Source" documents all changes and editions for both languages and ethnicity names (e.g., being converted to lower cases or corrected for labeling/spelling consistency across waves or grouping when, e.g., two given ethnicty/language names are reported together in one wave) 

use "$directory_source/AF-rounds-2-3-4-5-6.dta"


keep wb_code respno AF dateintr

** Official matches data (in football_data.dta) from FIFA statistical office is not publicly available for downloading but can be obtained through its Communications and Public Affairs Division
* Note that any game played between two Sub-Saharan African countries will appear twice in football_data.dta (each with an unique CountryxMatch fixed effect id)

compress
display c(current_time)
joinby wb_code using "$directory_source/football_data.dta"
display c(current_time)

local larger_window = 30
keep if abs(dateintr-date_match) <= `larger_window'

drop dateintr
merge m:1 wb_code respno AF using "$directory_source/AF-rounds-2-3-4-5-6.dta"
	drop if _merge == 2
	drop _merge

	**Drop Observations for Countries outside Sub-Saharan Africa
drop if not_ssa == 1
drop not_ssa

	**Drop Observations with unknown language or (Indo-European or Arabic languages)

drop if unknown_language==1
drop if not_indigenous==1
drop unknown_language

set more off
local counter = 1

foreach window in 15 20 25 30 15 {
	preserve

	display "working on window of `window' days..."

	local friendly_match = 4

    if `window' == 15 & `counter' == 5 {
        keep if tournament_rank == `friendly_match'
    }
    else {
    	drop if tournament_rank == `friendly_match'
    }

	keep if abs(dateintr-date_match) <= `window'
	format date_match dateintr %tdD-m-Y


	*before-after
	gen date_dif = date_match - dateintr
	bys respno AF: egen after  = rank(date_dif) if date_dif>0, u
	bys respno AF: egen before = rank(date_dif) if date_dif<0, u

	gen after_before     = ""
	replace after_before = "_" + string(after)  + "_aft" if after  ! =.
	replace after_before = string(before)       + "_bef" if before ! =.
	replace after_before = "0"                  if after_before == ""
		drop after before

	reshape wide teams tournament_rank date_dif result date_match country_match_fe score rivalry_teams final_score penalty_score total_goals_scored ///
			goal_difference_abs_value goal_difference_team penalty_definition penalty_won penalty_lose high_difference local, i(dateintr respno AF) j(after_before) string

	*Identify the number of matches before and after
	egen Nmatch = rownonmiss(result*_bef )

	egen ANmatch = rownonmiss(result*_aft )

	*Date_dif for only 1 match
	gen id_match0 = !missing(date_match0)
	drop if id_match0 == 1
		label var id_match0 "Individuals with a match the same day of interview"

	egen min_dist_before = rowmin(date_dif*_bef)

	egen min_dist_after  = rowmin(date_dif_*_aft)

	gen date_dif_1match = cond(Nmatch == 0 & id_match0 == 0, min_dist_after, cond(Nmatch == 1, min_dist_before, .))
		label var date_dif_1match "Distance to closest match for control and for unique match for treatment"

	*Treat-Control variable
	gen treat_control = teams1 != ""
		replace treat_control = . if date_match0 != .
			*g treat=1 if teams1!=""
			*g control=1 if teams1==""
	label def treat_control 1 "Treatment" 0 "Control"
	label val treat_control treat_control

	*Play, won
	gen play = .
	replace play = 1 if Nmatch == 1
	replace play = 0 if Nmatch == 0

	*g won=result1==1
	egen wons = anycount(result*_bef), value(1)

	gen won_share = wons/Nmatch
		replace won_share = 0 if play==0

	egen draw = anycount(result*_bef), value(2)

	gen won_point = (wons*3 + draw)
		replace won_point = 0 if Nmatch==0

	gen won_point_share = won_point / (3*Nmatch)
		replace won_point_share = 0 if Nmatch==0

	**Won (i.e., Post-Victory) as treatment only applies for respondents with exclusively one match in the time window before the interview
	gen won = wons
		replace won = . if Nmatch>1

	gen lost = 0
		replace lost = 1 if play == 1 & won_point == 0
		replace lost = . if Nmatch > 1

	gen tie = 0
		replace tie = 1 if play == 1 & won_point == 1
		replace tie = . if Nmatch > 1

	*country_match_fe
	gen country_match_fe = .
	replace country_match_fe = country_match_fe1 if Nmatch  == 1
	replace country_match_fe = country_match_fe2 if country_match_fe1 == . & Nmatch == 1
	replace country_match_fe = country_match_fe3 if country_match_fe1 == . & country_match_fe2 == . & Nmatch == 1

	replace country_match_fe = country_match_fe_1 if Nmatch == 0
	replace country_match_fe = country_match_fe_2 if country_match_fe_1 == . & Nmatch == 0
	replace country_match_fe = country_match_fe_3 if country_match_fe_1 == . & country_match_fe_2 == . & Nmatch == 0
	replace country_match_fe = country_match_fe_4 if country_match_fe_1 == . & country_match_fe_2 == . ///
												   	& country_match_fe_3 == . & Nmatch == 0
	*Number of control matches
	egen AN_before_matches = rownonmiss(result_*_aft)

	*gen ids
	encode country, generate(country_id)
	encode language, generate(language_id)
	egen country_year_fe= group( year wb_code )
	egen ethnic_year_id = group(ethnicity year) //
	egen language_year_id = group(language_id year)

	**Match FE sample
	sort country_match_fe
	by country_match_fe: egen before_and_after = mean(play)
	gen match_fe_sample = 0
		replace match_fe_sample = 1 if before_and_after > 0 & before_and_after < 1

	g Dfuture_win=result_1==1
	replace Dfuture_win=. if country_match_fe==.
	replace Dfuture_win=0 if play==1 & Nmatch<2

	g Dfuture_lose=result_1==0
	replace Dfuture_lose=. if country_match_fe==.
	replace Dfuture_lose=0 if play==1 & Nmatch<2

	g Dfuture_tie=result_1==2
	replace Dfuture_tie=. if country_match_fe==.
	replace Dfuture_tie=0 if play==1 & Nmatch<2

	gen abs_distance=abs(date_dif_1match)

		replace tie = 1 if match_fe_sample == 1 & won == . & play != .
		replace won = 0 if match_fe_sample == 1 & won == . & play != .

	ren *_bef *
	ren *_aft *

rename won post_victory
rename lost post_defeat
rename tie post_draw
rename play post_match
	
**** Additional Data Creation
*	Ethnic Majority Indicator

tab language if not_indigenous == 1

by country, sort:    gen N_bycountry = _N
by country language, sort: gen N_Language_country = _N

gen share_ethnics = N_Language_country / N_bycountry
lab var share_ethnics "Share of respondent's language in sample by country"


by country, sort: egen mayority_share_by_country = max(share_ethnics) if not_indigenous == 0

gen major_ethnicity = 0
replace major_ethnicity = 1 if share_ethnics == mayority_share_by_country

lab var major_ethnicity "1 if language of the respondant is the most spoken in country sample"

drop N_bycountry  N_Language_country mayority_share_by_country

drop not_indigenous


****Respondent and Interviewer Speak Same Language 

gen same_language = language == language_interviewer if !missing(language, language_interviewer)


**
rename date_dif_1match dist_match


drop date_dif* date_match* final_score* goal_difference_abs_value* goal_difference_team* penalty_definition* penalty_lose* penalty_score* penalty_won* result* score0 score1 score2 score3 score_1 score_2 score_3 score_4 teams* tournament_rank*
	
	compress
	label dat "`window' window Afrobarometer-Football data, Stata`c(version)', `c(current_date)'"

    if `window' == 15 & `counter' == 5 {

       save "$directory_final/`counter'-afrobarometer_games_`window'days_friendly_matches.dta", replace
    }
    else {

    	save "$directory_final/`counter'-afrobarometer_games_`window'days.dta", replace
    }
	restore

	local counter = `counter' + 1
}

*
clear



****Create Seasonal Dummies and Drop Unnecessary Observations 
clear all
use "$directory_final/5-afrobarometer_games_15days_friendly_matches.dta" 
keep dateintr respno male age age_sq unemployed rural education ethnic_sentiment post_victory country_year_fe language_year_id country_match_fe 
generate day=day(dateintr)
generate month=month(dateintr)
generate dayweek=dow(dateintr)
save "$directory_final/5-afrobarometer_games_15days_friendly_matches.dta", replace

clear all
use "$directory_final/2-afrobarometer_games_20days.dta" 
keep dateintr respno male age age_sq unemployed rural education ethnic_sentiment post_victory country_year_fe language_year_id country_match_fe 
generate day=day(dateintr)
generate month=month(dateintr)
generate dayweek=dow(dateintr)
save "$directory_final/2-afrobarometer_games_20days.dta", replace

clear all
use "$directory_final/3-afrobarometer_games_25days.dta"
keep dateintr respno male age age_sq unemployed rural education ethnic_sentiment post_victory country_year_fe language_year_id country_match_fe 
generate day=day(dateintr)
generate month=month(dateintr)
generate dayweek=dow(dateintr)
save "$directory_final/3-afrobarometer_games_25days.dta", replace


clear all
use "$directory_final/4-afrobarometer_games_30days.dta"
keep dateintr respno male age age_sq unemployed rural education ethnic_sentiment post_victory country_year_fe language_year_id country_match_fe 
generate day=day(dateintr)
generate month=month(dateintr)
generate dayweek=dow(dateintr)
save "$directory_final/4-afrobarometer_games_30days.dta", replace


clear all
use "$directory_final/1-afrobarometer_games_15days.dta"
generate day=day(dateintr)
generate month=month(dateintr)
generate dayweek=dow(dateintr)
keep dateintr respno dayweek day month year country wb_code AF country_year_fe elf ethnic_year_id ethnicity language_year_id same_language influenced_by_others male_interv education_interviewer age_interviewer country_match_fe post_victory post_draw post_defeat post_match won_share won_point_share  Dfuture_win dist_match abs_distance main_sample  local_1 local1 rivalry_teams1 rivalry_teams_1 Nmatch ANmatch high_difference1  total_goals_scored1 high_difference_1  total_goals_scored_1  male age age_sq unemployed rural education  major_ethnicity religious_group state_presence public_goods  ethnic_sentiment ethnic_sentiment_categorical trust_people_d trust_people trust_intergroup_d trust_intergroup  like_neighbors_ethnicities_d like_neighbors_ethnicities dislike_foreign_neighbors_d dislike_foreign_neighbors trust_ruling_party_d approve_president_d ctry_cond_today_d ctry_cond_future_d own_cond_today_d own_cond_future_d trust_ruling_party approve_president ctry_cond_today ctry_cond_future own_cond_today own_cond_future
save "$directory_final/1-afrobarometer_games_15days", replace


*** Generate Team Diversity Dataset
use "$directory_source/players_ethnicity.dta", clear

* Check the share of each ethnic group within country/year
by country year ethnicity, sort: gen N_players_ethnic_group = _N 
by country year, sort:           gen total_N_of_players = _N 

* Keep only the unique counts of each ethnic group within each country/year
drop player
duplicates drop

* Generate shares of players and squared shares of players in each ethnic group
gen share_ethnic_group = N_players_ethnic_group / total_N_of_players
label var share_ethnic_group "Share of ethnic group"
gen share_ethnic_group2 = share_ethnic_group * share_ethnic_group

* Generate fractionalization index
by country year, sort: egen total_sum_shares2 = total(share_ethnic_group2)
gen team_diversity = 1 - total_sum_shares2
label var team_diversity "1 - total_sum_shares2"

* Keep relevant variables
keep country year team_diversity
duplicates drop
sort country year team_diversity 
assert inrange(team_diversity, 0, 1)
replace country=upper(country)

save "$directory_temp/team_diversity.dta", replace


clear

