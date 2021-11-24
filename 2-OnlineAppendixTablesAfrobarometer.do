* ----------------------------------------------------------------------------------------------------------------------------*
* Replication code for "Building Nations Through Shared Experiences: Evidence from African Football" (Depetris-Chauvin, Durante, and Campante)
* Stata 14	
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
    local ssc_packages "reghdfe" "outreg2" "ftools" "estout"


    if !missing("`ssc_packages'") {
        foreach pkg in "`ssc_packages'" {
            dis "Installing `pkg'"
            quietly ssc install `pkg', replace
        }
    }
		
	*

		
**Table A.2

use "$directory_final/1-afrobarometer_games_15days.dta"

cd "$directory_results"


local individual_controls male age age_sq unemployed rural education 

*Column 1
reghdfe ethnic_sentiment  post_victory `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.country_match_fe i.language_year_id i.dayweek i.day i.month)
outreg2 using TableA2, replace tex bdec(3) sdec(3) noaster keep ( post_victory)

*Column 2
reghdfe ethnic_sentiment  post_victory `individual_controls'  if main_sample==1 & ethnic_year_id!=., vce (cluster country_year_fe) absorb (i.country_match_fe i.language_year_id i.dayweek i.day i.month)
outreg2 using TableA2, append tex bdec(3) sdec(3)  noaster keep ( post_victory)

*Column 3
reghdfe ethnic_sentiment  post_victory `individual_controls'  if main_sample==1 & ethnic_year_id!=., vce (cluster country_year_fe) absorb (i.country_match_fe i.ethnic_year_id i.dayweek i.day i.month)
outreg2 using TableA2, append tex bdec(3) sdec(3) noaster keep ( post_victory)

clear


**Table A.5
use "$directory_final/1-afrobarometer_games_15days.dta"

estpost summarize ethnic_sentiment ethnic_sentiment_categorical post_match post_victory post_defeat post_draw trust_people_d trust_intergroup_d like_neighbors_ethnicities_d dislike_foreign_neighbors_d trust_ruling_party_d approve_president_d ctry_cond_today_d ctry_cond_future_d own_cond_today_d own_cond_future_d male age unemployed rural education major_ethnicity religious_group state_presence public_goods if main_sample==1 
esttab using TableA5.tex, cells("mean(fmt(3)) sd(fmt(3)) min(fmt(3)) max (fmt(3)) count(fmt(0))")  replace addnotes("") noobs

clear




**Table A.6

use "$directory_final/1-afrobarometer_games_15days.dta"

cd "$directory_results"


local individual_controls male age age_sq unemployed rural education 


***Panel A
*Column 1
reghdfe ethnic_sentiment won_share `individual_controls', vce (cluster country_year_fe) absorb (i.language_year_id i.country_year_fe i.dayweek i.day i.month)
outreg2 using TableA6_A, replace tex bdec(3) sdec(3) noaster  keep (won_share)

*Column 2
reghdfe trust_people_d won_share `individual_controls', vce (cluster country_year_fe) absorb (i.language_year_id i.country_year_fe i.dayweek i.day i.month)
outreg2 using TableA6_A, append tex bdec(3) sdec(3)  noaster keep (won_share)

*Column 3
reghdfe trust_intergroup_d won_share `individual_controls', vce (cluster country_year_fe) absorb (i.language_year_id i.country_year_fe i.dayweek i.day i.month)
outreg2 using TableA6_A, append tex bdec(3) sdec(3)  noaster keep (won_share)

*Column 4
reghdfe like_neighbors_ethnicities_d won_share `individual_controls', vce (cluster country_year_fe) absorb (i.language_year_id i.country_year_fe i.dayweek i.day i.month)
outreg2 using TableA6_A, append tex bdec(3) sdec(3) noaster keep (won_share)

*Column 5
reghdfe dislike_foreign_neighbors_d won_share `individual_controls', vce (cluster country_year_fe) absorb (i.language_year_id i.country_year_fe i.dayweek i.day i.month)
outreg2 using TableA6_A, append tex bdec(3) sdec(3) noaster keep (won_share)

*Column 6
reghdfe trust_ruling_party_d won_share `individual_controls', vce (cluster country_year_fe) absorb (i.language_year_id i.country_year_fe i.dayweek i.day i.month)
outreg2 using TableA6_A, append tex bdec(3) sdec(3) noaster keep (won_share)

*Column 7
reghdfe approve_president_d won_share `individual_controls', vce (cluster country_year_fe) absorb (i.language_year_id i.country_year_fe i.dayweek i.day i.month)
outreg2 using TableA6_A, append tex bdec(3) sdec(3) noaster keep (won_share)


***Panel B
*Column 1
reghdfe ethnic_sentiment won_point_share `individual_controls', vce (cluster country_year_fe) absorb (i.language_year_id i.country_year_fe i.dayweek i.day i.month)
outreg2 using TableA6_B, replace tex bdec(3) sdec(3) noaster keep (won_point_share)

*Column 2
reghdfe trust_people_d won_point_share `individual_controls' , vce (cluster country_year_fe) absorb (i.language_year_id i.country_year_fe i.dayweek i.day i.month)
outreg2 using TableA6_B, append tex bdec(3) sdec(3) noaster keep (won_point_share)

*Column 3
reghdfe trust_intergroup_d won_point_share `individual_controls', vce (cluster country_year_fe) absorb (i.language_year_id i.country_year_fe i.dayweek i.day i.month)
outreg2 using TableA6_B, append tex bdec(3) sdec(3) noaster keep (won_point_share)

*Column 4
reghdfe like_neighbors_ethnicities_d won_point_share `individual_controls', vce (cluster country_year_fe) absorb (i.language_year_id i.country_year_fe i.dayweek i.day i.month)
outreg2 using TableA6_B, append tex bdec(3) sdec(3) noaster keep (won_point_share)

*Column 5
reghdfe dislike_foreign_neighbors_d won_point_share  `individual_controls' , vce (cluster country_year_fe) absorb (i.language_year_id i.country_year_fe i.dayweek i.day i.month)
outreg2 using TableA6_B, append tex bdec(3) sdec(3)  noaster keep (won_point_share)

*Column 6
reghdfe trust_ruling_party_d won_point_share `individual_controls', vce (cluster country_year_fe) absorb (i.language_year_id i.country_year_fe i.dayweek i.day i.month)
outreg2 using TableA6_B, append tex bdec(3) sdec(3) noaster  keep (won_point_share)

*Column 7
reghdfe approve_president_d won_point_share `individual_controls', vce (cluster country_year_fe) absorb (i.language_year_id i.country_year_fe i.dayweek i.day i.month)
outreg2 using TableA6_B, append tex bdec(3) sdec(3) noaster keep (won_point_share)

clear


** Table A.7

use "$directory_final/1-afrobarometer_games_15days.dta"

cd "$directory_results"


foreach w in  rural unemployed major_ethnicity male education age {

	sum `w' if main_sample == 1
	gen `w'_dem = `w' - r(mean)
}




* 

* Column 1
reghdfe ethnic_sentiment post_victory c.post_victory#c.rural_dem male age age_sq unemployed rural_dem education if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
outreg2 using TableA7, replace tex bdec(3) sdec(3) noaster keep (post_victory c.post_victory#c.rural_dem rural_dem)

* Column 2
reghdfe ethnic_sentiment post_victory c.post_victory#c.unemployed_dem male age age_sq unemployed_dem rural education  if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
outreg2 using TableA7, append tex bdec(3) sdec(3) noaster keep (post_victory c.post_victory#c.unemployed_dem unemployed_dem)

* Column 3
reghdfe ethnic_sentiment post_victory c.post_victory#c.male_dem male_dem age age_sq unemployed rural education  if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
outreg2 using TableA7, append tex bdec(3) sdec(3) noaster keep (post_victory c.post_victory#c.male_dem male_dem)

* Column 4
reghdfe ethnic_sentiment post_victory c.post_victory#c.education_dem  male age age_sq unemployed rural education_dem  if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
outreg2 using TableA7, append tex bdec(3) sdec(3) noaster keep (post_victory c.post_victory#c.education_dem education_dem)

* Column 5
reghdfe ethnic_sentiment post_victory c.post_victory#c.age_dem  male age_dem age_sq unemployed rural education  if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
outreg2 using TableA7, append tex bdec(3) sdec(3) noaster keep (post_victory c.post_victory#c.age_dem age_dem )

* Column 6
reghdfe ethnic_sentiment post_victory c.post_victory#c.major_ethnicity_dem  major_ethnicity_dem male age age_sq unemployed rural education  if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
outreg2 using TableA7, append tex bdec(3) sdec(3) noaster keep (post_victory c.post_victory#c.major_ethnicity_dem major_ethnicity_dem)

clear





** Table A.8

use "$directory_final/1-afrobarometer_games_15days.dta"

cd "$directory_results"

set matsize 3000

local individual_controls male age age_sq unemployed rural education 

* Column 1
* Std errors clustered at language group x year level
reghdfe ethnic_sentiment post_victory `individual_controls'  if main_sample==1, vce (cluster language_year_id) absorb (i.country_year_fe)
* Std errors clustered at country x match level
reghdfe ethnic_sentiment post_victory `individual_controls'  if main_sample==1, vce (cluster country_match_fe) absorb (i.country_year_fe)
* Std errors clustered at country x year level 
reghdfe ethnic_sentiment post_victory `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.country_year_fe)
outreg2 using TableA8, replace tex bracket bdec(3) sdec(3)  noaster  keep (post_victory) 


* Column 2
* Std errors clustered at language group x year level
reghdfe ethnic_sentiment post_victory `individual_controls'  if main_sample==1, vce (cluster language_year_id) absorb (i.country_year_fe i.dayweek i.day i.month)
* Std errors clustered at country x match level
reghdfe ethnic_sentiment post_victory `individual_controls'  if main_sample==1, vce (cluster country_match_fe) absorb (i.country_year_fe i.dayweek i.day i.month)
* Std errors clustered at country x year level 
reghdfe ethnic_sentiment post_victory `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.country_year_fe i.dayweek i.day i.month)
outreg2 using TableA8, append tex bracket bdec(3) sdec(3) noaster keep (post_victory)


* Column 3
* Std errors clustered at language group x year level
reghdfe ethnic_sentiment post_victory `individual_controls'  if main_sample==1, vce (cluster language_year_id) absorb (i.country_year_fe i.language_year_id i.dayweek i.day i.month)
* Std errors clustered at country x match level
reghdfe ethnic_sentiment post_victory `individual_controls'  if main_sample==1, vce (cluster country_match_fe) absorb (i.country_year_fe i.language_year_id i.dayweek i.day i.month)
* Std errors clustered at country x year level 
reghdfe ethnic_sentiment post_victory `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.country_year_fe i.language_year_id i.dayweek i.day i.month)
outreg2 using TableA9, append tex bracket bdec(3) sdec(3) noaster keep (post_victory)


* Column 4
* Std errors clustered at language group x year level
reghdfe ethnic_sentiment post_victory `individual_controls'  if main_sample==1, vce (cluster language_year_id) absorb (i.country_match_fe i.language_year_id i.dayweek i.day i.month)
* Std errors clustered at country x match level
reghdfe ethnic_sentiment post_victory `individual_controls'  if main_sample==1, vce (cluster country_match_fe) absorb (i.country_match_fe i.language_year_id i.dayweek i.day i.month)
* Std errors clustered at country x year level 
reghdfe ethnic_sentiment post_victory `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.country_match_fe i.language_year_id i.dayweek i.day i.month)
outreg2 using TableA9, append tex bracket bdec(3) sdec(3) noaster keep (post_victory)


* Column 5
* Std errors clustered at language group x year level
reghdfe ethnic_sentiment post_victory post_draw post_defeat `individual_controls'  if main_sample==1, vce (cluster language_year_id) absorb (i.country_match_fe i.language_year_id i.dayweek i.day i.month)
* Std errors clustered at country x match level
reghdfe ethnic_sentiment post_victory post_draw post_defeat `individual_controls'  if main_sample==1, vce (cluster country_match_fe) absorb (i.country_match_fe i.language_year_id i.dayweek i.day i.month)
* Std errors clustered at country x year level 
reghdfe ethnic_sentiment post_victory post_draw post_defeat `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.country_match_fe i.language_year_id i.dayweek i.day i.month)
outreg2 using TableA9, append tex bracket bdec(3) sdec(3) noaster  keep (post_victory post_draw post_defeat)


* Column 6
* Std errors clustered at language group x year level
probit ethnic_sentiment post_victory  `individual_controls' i.country_match_fe i.language_year_id i.dayweek i.day i.month if main_sample==1,  vce (cluster language_year_id) 
* Std errors clustered at country x match level
probit ethnic_sentiment post_victory  `individual_controls' i.country_match_fe i.language_year_id i.dayweek i.day i.month if main_sample==1,  vce (cluster country_match_fe) 
* Std errors clustered at country x year level 
probit ethnic_sentiment post_victory  `individual_controls' i.country_match_fe i.language_year_id i.dayweek i.day i.month if main_sample==1,  vce (cluster country_year_fe) 
outreg2 using TableA9, append tex bracket bdec(3) sdec(3) noaster keep (post_victory)

margins , dydx(post_victory) at(male=(.50) age=(36.9) age_sq=(1361.61) unemployed=(0.30) rural=(.61) education=(3.08))


*** Adjusted p-values for columns 1 to 5 in separate dofile

clear


** Table A.9

use "$directory_final/1-afrobarometer_games_15days.dta"

cd "$directory_results"


local individual_controls male age age_sq unemployed rural education 

*Column 1
reghdfe ethnic_sentiment post_victory `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
outreg2 using TableA9, replace tex bdec(3) sdec(3)  noaster  keep (post_victory)

*Column 2
reghdfe ethnic_sentiment post_victory `individual_controls'  if main_sample==1 &  abs_distance<6, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
outreg2 using TableA9, append tex bdec(3) sdec(3) noaster keep (post_victory)

*Column 3
reghdfe ethnic_sentiment post_victory `individual_controls'  if main_sample==1 &  abs_distance<11, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
outreg2 using TableA9, append tex bdec(3) sdec(3) noaster keep (post_victory)


clear
use "$directory_final/2-afrobarometer_games_20days.dta"
set matsize 3000

cd "$directory_results"

local individual_controls male age age_sq unemployed rural education 

*Column 4
reghdfe ethnic_sentiment post_victory `individual_controls', vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
outreg2 using TableA9, append tex bdec(3) sdec(3) noaster keep (post_victory)




clear
use "$directory_final/3-afrobarometer_games_25days.dta"
set matsize 3000

cd "$directory_results"

local individual_controls male age age_sq unemployed rural education 

*Column 5
reghdfe ethnic_sentiment post_victory `individual_controls', vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
outreg2 using TableA9, append tex bdec(3) sdec(3) noaster keep (post_victory)


clear
use "$directory_final/4-afrobarometer_games_30days.dta"

cd "$directory_results"

set matsize 3000
local individual_controls male age age_sq unemployed rural education 

*Column 6
reghdfe ethnic_sentiment post_victory `individual_controls', vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
outreg2 using TableA9, append tex bdec(3) sdec(3) noaster keep (post_victory)

clear


**Table A.10

use "$directory_final/1-afrobarometer_games_15days.dta"

cd "$directory_results"


**Number of Observations per Country-Match
sort country_match_fe
by country_match_fe: gen n=_N
replace n=. if main_sample==0

local individual_controls male age age_sq unemployed rural education 

*Column 1
reghdfe ethnic_sentiment post_victory `individual_controls'  if main_sample==1 [pw=n], vce (cluster country_year_fe) absorb (i.country_match_fe i.language_year_id i.dayweek i.day i.month)
outreg2 using TableA10, replace tex bdec(3) sdec(3) noaster keep (post_victory) 

*Column 2
reghdfe ethnic_sentiment post_victory `individual_controls'  if main_sample==1 & n>370, vce (cluster country_year_fe) absorb (i.country_match_fe i.language_year_id i.dayweek i.day i.month)
outreg2 using TableA10, append tex bdec(3) sdec(3) noaster keep (post_victory) 

*Column 3
reghdfe ethnic_sentiment post_victory `individual_controls'  if main_sample==1 & n>999, vce (cluster country_year_fe) absorb (i.country_match_fe i.language_year_id i.dayweek i.day i.month)
outreg2 using TableA10, append tex bdec(3) sdec(3) noaster keep (post_victory) 

*Column 4
reghdfe ethnic_sentiment post_victory `individual_controls'  if main_sample==1 & n<1501, vce (cluster country_year_fe) absorb (i.country_match_fe i.language_year_id i.dayweek i.day i.month)
outreg2 using TableA10, append tex bdec(3) sdec(3) noaster keep (post_victory) 

** Dfbeta Analysis
reg ethnic_sentiment post_victory `individual_controls' i.country_match_fe i.language_year_id i.dayweek i.day i.month if main_sample==1
predict dfor, dfbeta(post_victory)
*Column 5
reghdfe ethnic_sentiment post_victory `individual_controls'  if main_sample==1 & abs(dfor) < 2/sqrt(37093) , vce (cluster country_year_fe) absorb (i.country_match_fe i.language_year_id i.dayweek i.day i.month)
outreg2 using TableA10, append tex bdec(3) sdec(3) noaster keep (post_victory) 

clear

** Table A.11
use "$directory_final/1-afrobarometer_games_15days.dta"
set matsize 3000
cd "$directory_results"
local individual_controls male age age_sq unemployed rural education 

*Column 1
reghdfe ethnic_sentiment_categorical post_victory  `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.country_year_fe i.language_year_id i.dayweek i.month)
outreg2 using TableA11, replace tex bdec(3) sdec(3) noaster keep (post_victory )

*Column 2
reghdfe ethnic_sentiment_categorical post_victory  `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.country_match_fe i.language_year_id i.dayweek i.month)
outreg2 using TableA11, append tex bdec(3) sdec(3) noaster keep (post_victory )

*Column 3
oprobit ethnic_sentiment_categorical post_victory  `individual_controls' i.country_year_fe i.language_year_id i.dayweek i.month if main_sample==1, vce (cluster country_year_fe) 
outreg2 using TableA11, append tex bdec(3) sdec(3) noaster keep (post_victory )

*Column 4
oprobit ethnic_sentiment_categorical post_victory  `individual_controls' i.country_match_fe i.language_year_id i.dayweek i.month if main_sample==1, vce (cluster country_year_fe) 
outreg2 using TableA11, append tex bdec(3) sdec(3) noaster keep (post_victory )

clear





** Table A.12
use "$directory_final/1-afrobarometer_games_15days.dta"
set matsize 3000
cd "$directory_results"


merge m:m country year using "$directory_temp/team_diversity.dta"

drop _merge

foreach w in team_diversity  {

	sum `w' if main_sample == 1
	gen `w'_dem = `w' - r(mean)
}



local individual_controls male age age_sq unemployed rural education 

reghdfe ethnic_sentiment post_victory c.post_victory#c.team_diversity_dem male  age age_sq  unemployed rural education if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)

gen sample=e(sample)
drop if sample==0

sort country year
by country year: gen n=_n
**List Country, Year, and Team Diversity
list country year team_diversity if n==1  & sample==1 & team_diversity!=.

clear


**Table A.13

use "$directory_final/1-afrobarometer_games_15days.dta"
cd "$directory_results"

set matsize 3000
local individual_controls male age age_sq unemployed rural education 


*Column 1
reghdfe trust_ruling_party_d post_victory `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
outreg2 using TableA13, replace tex bdec(3) sdec(3) noaster keep (post_victory) 

*Column 2
oprobit trust_ruling_party post_victory `individual_controls' i.language_year_id i.country_match_fe i.dayweek i.day i.month if main_sample==1, vce (cluster country_year_fe)
outreg2 using TableA13, append tex bdec(3) sdec(3) noaster keep (post_victory) 


*Column 3
reghdfe approve_president_d post_victory `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
outreg2 using TableA13, append tex bdec(3) sdec(3) noaster keep (post_victory) 

*Column 4
oprobit approve_president post_victory `individual_controls' i.language_year_id i.country_match_fe i.dayweek i.day i.month if main_sample==1, vce (cluster country_year_fe)
outreg2 using TableA13, append tex bdec(3) sdec(3) noaster keep (post_victory) 


clear

** Table A.14

use "$directory_final/1-afrobarometer_games_15days.dta"
cd "$directory_results"

set matsize 3000

gen ctry_cond_today_d2=0
replace ctry_cond_today_d2=. if ctry_cond_today==.
replace ctry_cond_today_d2=1 if ctry_cond_today==4
replace ctry_cond_today_d2=1 if ctry_cond_today==5

gen ctry_cond_today_d3=0
replace ctry_cond_today_d3=. if ctry_cond_today==.
replace ctry_cond_today_d3=1 if ctry_cond_today==5

local individual_controls male age age_sq unemployed rural education 

*Column 1
reghdfe ctry_cond_today_d3 post_victory `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
outreg2 using TableA14, replace tex bdec(3) sdec(3) noaster keep (post_victory) 

*Column 2
reghdfe ctry_cond_today_d2 post_victory `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
outreg2 using TableA14, append tex bdec(3) sdec(3) noaster keep (post_victory) 

*Column 3
reghdfe ctry_cond_today_d post_victory `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
outreg2 using TableA14, append tex bdec(3) sdec(3) noaster keep (post_victory) 

*Column 4
oprobit ctry_cond_today post_victory `individual_controls' i.language_year_id i.country_match_fe i.dayweek i.day i.month if main_sample==1, vce (cluster country_year_fe)
outreg2 using TableA14, append tex bdec(3) sdec(3) noaster keep (post_victory) 

clear


** Table A.15

use "$directory_final/1-afrobarometer_games_15days.dta"
cd "$directory_results"

set matsize 3000

gen ctry_cond_future_d2=0
replace ctry_cond_future_d2=. if ctry_cond_future==.
replace ctry_cond_future_d2=1 if ctry_cond_future==4
replace ctry_cond_future_d2=1 if ctry_cond_future==5

gen ctry_cond_future_d3=0
replace ctry_cond_future_d3=. if ctry_cond_future==.
replace ctry_cond_future_d3=1 if ctry_cond_future==5


local individual_controls male age age_sq unemployed rural education 

*Column 1
reghdfe ctry_cond_future_d3 post_victory `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
outreg2 using TableA15, replace tex bdec(3) sdec(3) noaster keep (post_victory) 

*Column 2
reghdfe ctry_cond_future_d2 post_victory `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
outreg2 using TableA15, append tex bdec(3) sdec(3) noaster keep (post_victory) 

*Column 3
reghdfe ctry_cond_future_d post_victory `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
outreg2 using TableA15, append tex bdec(3) sdec(3) noaster keep (post_victory) 

*Column 4
oprobit ctry_cond_future post_victory `individual_controls' i.language_year_id i.country_match_fe i.dayweek i.day i.month if main_sample==1, vce (cluster country_year_fe)
outreg2 using TableA15, append tex bdec(3) sdec(3) noaster keep (post_victory) 

clear



** Table A.16

use "$directory_final/1-afrobarometer_games_15days.dta"
cd "$directory_results"

set matsize 3000



gen own_cond_today_d3=0
replace own_cond_today_d3=. if own_cond_today==.
replace own_cond_today_d3=1 if own_cond_today==5

gen own_cond_today_d2=0
replace own_cond_today_d2=. if own_cond_today==.
replace own_cond_today_d2=1 if own_cond_today==4
replace own_cond_today_d2=1 if own_cond_today==5

local individual_controls male age age_sq unemployed rural education 

*Column 1
reghdfe own_cond_today_d3 post_victory `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
outreg2 using TableA16, replace tex bdec(3) sdec(3) noaster keep (post_victory) 

*Column 2
reghdfe own_cond_today_d2 post_victory `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
outreg2 using TableA16, append tex bdec(3) sdec(3) noaster keep (post_victory) 

*Column 3
reghdfe own_cond_today_d post_victory `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
outreg2 using TableA16, append tex bdec(3) sdec(3) noaster keep (post_victory) 

*Column 4
oprobit own_cond_today post_victory `individual_controls' i.language_year_id i.country_match_fe i.dayweek i.day i.month if main_sample==1, vce (cluster country_year_fe)
outreg2 using TableA16, append tex bdec(3) sdec(3) noaster keep (post_victory) 

clear


** Table A.17

use "$directory_final/1-afrobarometer_games_15days.dta"
cd "$directory_results"

set matsize 3000

gen own_cond_future_d2=0
replace own_cond_future_d2=. if own_cond_future==.
replace own_cond_future_d2=1 if own_cond_future==4
replace own_cond_future_d2=1 if own_cond_future==5


gen own_cond_future_d3=0
replace own_cond_future_d3=. if own_cond_future==.
replace own_cond_future_d3=1 if own_cond_future==5


local individual_controls male age age_sq unemployed rural education 

*Column 1
reghdfe own_cond_future_d3 post_victory `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
outreg2 using TableA17, replace tex bdec(3) sdec(3) noaster keep (post_victory) 

*Column 2
reghdfe own_cond_future_d2 post_victory `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
outreg2 using TableA17, append tex bdec(3) sdec(3) noaster keep (post_victory) 

*Column 3
reghdfe own_cond_future_d post_victory `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
outreg2 using TableA17, append tex bdec(3) sdec(3) noaster keep (post_victory) 

*Column 4
oprobit own_cond_future post_victory `individual_controls' i.language_year_id i.country_match_fe i.dayweek i.day i.month if main_sample==1, vce (cluster country_year_fe)
outreg2 using TableA17, append tex bdec(3) sdec(3) noaster keep (post_victory) 

clear



** Table A.18

use "$directory_final/1-afrobarometer_games_15days.dta"
cd "$directory_results"

set matsize 3000


gen ctry_cond_today_d2=0
replace ctry_cond_today_d2=. if ctry_cond_today==.
replace ctry_cond_today_d2=1 if ctry_cond_today==4
replace ctry_cond_today_d2=1 if ctry_cond_today==5

gen ctry_cond_today_d3=0
replace ctry_cond_today_d3=. if ctry_cond_today==.
replace ctry_cond_today_d3=1 if ctry_cond_today==5

gen ctry_cond_future_d2=0
replace ctry_cond_future_d2=. if ctry_cond_future==.
replace ctry_cond_future_d2=1 if ctry_cond_future==4
replace ctry_cond_future_d2=1 if ctry_cond_future==5

gen ctry_cond_future_d3=0
replace ctry_cond_future_d3=. if ctry_cond_future==.
replace ctry_cond_future_d3=1 if ctry_cond_future==5


gen own_cond_today_d3=0
replace own_cond_today_d3=. if own_cond_today==.
replace own_cond_today_d3=1 if own_cond_today==5

gen own_cond_today_d2=0
replace own_cond_today_d2=. if own_cond_today==.
replace own_cond_today_d2=1 if own_cond_today==4
replace own_cond_today_d2=1 if own_cond_today==5


gen own_cond_future_d2=0
replace own_cond_future_d2=. if own_cond_future==.
replace own_cond_future_d2=1 if own_cond_future==4
replace own_cond_future_d2=1 if own_cond_future==5


gen own_cond_future_d3=0
replace own_cond_future_d3=. if own_cond_future==.
replace own_cond_future_d3=1 if own_cond_future==5


pca ctry_cond_today_d own_cond_today_d ctry_cond_future_d own_cond_future_d

predict pc1

rename pc1 pc_dummy_positive

pca ctry_cond_today_d2 own_cond_today_d2 ctry_cond_future_d2 own_cond_future_d2

predict pc1

rename pc1 pc_dummy_very_positive

pca ctry_cond_today_d3 own_cond_today_d3 ctry_cond_future_d3 own_cond_future_d3

predict pc1

rename pc1 pc_dummy_extremely_positive

pca ctry_cond_today own_cond_today ctry_cond_future own_cond_future

predict pc1

rename pc1 pc_assesment_ordered

local individual_controls male age age_sq unemployed rural education 


*Column 1
reghdfe pc_dummy_extremely_positive  post_victory `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
outreg2 using TableA18, replace tex bdec(3) sdec(3) noaster keep (post_victory)

*Column 2
reghdfe pc_dummy_very_positive  post_victory `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
outreg2 using TableA18, append tex  bdec(3) sdec(3) noaster keep (post_victory)

*Column 3
reghdfe pc_dummy_positive  post_victory `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
outreg2 using TableA18, append tex bdec(3) sdec(3) noaster keep (post_victory)

*Column 4
reghdfe pc_assesment_ordered  post_victory `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.language_year_id i.country_match_fe i.dayweek i.day i.month)
outreg2 using TableA18, append tex  bdec(3) sdec(3) noaster keep (post_victory)

clear


** Table A.19

use "$directory_final/1-afrobarometer_games_15days.dta"
cd "$directory_results"

set matsize 3000

local individual_controls male age age_sq unemployed rural education 

*Column 1
oprobit trust_people post_victory `individual_controls' i.language_year_id i.country_match_fe i.dayweek i.day i.month if main_sample==1, vce (cluster country_year_fe)
outreg2 using TableA19, replace tex bdec(3) sdec(3) noaster keep (post_victory) 

*Column 2
oprobit trust_intergroup post_victory `individual_controls' i.language_year_id i.country_match_fe i.dayweek i.day i.month if main_sample==1, vce (cluster country_year_fe)
outreg2 using TableA19, append tex bdec(3) sdec(3) noaster keep (post_victory) 

*Column 3
oprobit like_neighbors_ethnicities post_victory `individual_controls' i.language_year_id i.country_match_fe i.dayweek i.day i.month if main_sample==1, vce (cluster country_year_fe)
outreg2 using TableA19, append tex bdec(3) sdec(3) noaster keep (post_victory) 

*Column 4
oprobit dislike_foreign_neighbors post_victory `individual_controls' i.language_year_id i.country_match_fe i.dayweek i.day i.month if main_sample==1, vce (cluster country_year_fe)
outreg2 using TableA19, append tex bdec(3) sdec(3) noaster keep (post_victory) 

clear

