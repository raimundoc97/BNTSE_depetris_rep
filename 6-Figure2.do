

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


set more off

clear all


use "$directory_final/1-afrobarometer_games_15days.dta"

ssc install coefplot

rename Dfuture_win future_victory
gen pre_13_15days=0
replace pre_13_15days=1 if dist_match>12
gen pre_10_12days=0
replace pre_10_12days=1 if dist_match>9 & dist_match<13
gen pre_7_9days=0
replace pre_7_9days=1 if dist_match>6 & dist_match<10
gen pre_4_6days=0
replace pre_4_6days=1 if dist_match>3 & dist_match<7
gen pre_1_3days=0
replace pre_1_3days=1 if dist_match>0 & dist_match<4

gen post_1_3days=0
replace post_1_3days=1 if dist_match<0 & dist_match>-4
gen post_4_6days=0
replace post_4_6days=1 if dist_match>-7 & dist_match<-3
gen post_7_9days=0
replace post_7_9days=1 if dist_match>-10 & dist_match<-6
gen post_10_12days=0
replace post_10_12days=1 if dist_match>-13 & dist_match<-9
gen post_13_15days=0
replace post_13_15days=1 if dist_match<-12

gen previctory_13_15days=pre_13_15days*future_victory
gen previctory_10_12days=pre_10_12days*future_victory
gen previctory_7_9days=pre_7_9days*future_victory
gen previctory_4_6days=pre_4_6days*future_victory
gen previctory_1_3days=pre_1_3days*future_victory

gen postvictory_1_3days= post_1_3days*post_victory
gen postvictory_4_6days= post_4_6days*post_victory
gen postvictory_7_9days= post_7_9days*post_victory
gen postvictory_10_12days= post_10_12days*post_victory
gen postvictory_13_15days= post_13_15days*post_victory

label variable previctory_13_15days "-15"
label variable previctory_10_12days "-12"
label variable previctory_7_9days "-9"
label variable previctory_4_6days "-6"
label variable previctory_1_3days "-3"
label variable postvictory_1_3days "+3"
label variable postvictory_4_6days "+6"
label variable postvictory_7_9days "+9"
label variable postvictory_10_12days "+12"
label variable postvictory_13_15days "+15"
*/

gen base=0

label variable base "-3"

local individual_controls male age age_sq unemployed rural education 


***Figure 2

quietly reghdfe ethnic_sentiment previctory_13_15days previctory_10_12days previctory_7_9days previctory_4_6days base postvictory_1_3days postvictory_4_6days postvictory_7_9days postvictory_10_12days postvictory_13_15days  `individual_controls'  if main_sample==1, vce (cluster country_year_fe) absorb (i.country_match_fe i.language_year_id i.dayweek i.day i.month)
coefplot ,  omitted keep (previctory_13_15days previctory_10_12days previctory_7_9days previctory_4_6days base postvictory_1_3days postvictory_4_6days postvictory_7_9days postvictory_10_12days postvictory_13_15days) ytitle ("Impact on Ethnic Identification") xtitle ("Distance to the Match") yline(0)  vertical


* Note: The figure needs just one minor editiion (using Graph Editor) to  to look exactly the same as the figure in manuscript (i.e., adding the dashed vertical line separating pre and post treatment periods)
