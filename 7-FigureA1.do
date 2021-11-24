

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


use "$directory_source/AF-rounds-2-3-4-5-6.dta"


set matsize 3000

cd "$directory_results"


egen country_wave=group (country AF), label

egen sample= total(main_sample), by(country_wave)

drop if sample==0

collapse (mean) ethnic_sentiment, by(country_wave)


graph bar ethnic_sentiment, by(country_wave) ytitle(Fraction of Respondents Identified as Ethnic over National)  legend(off)

clear
