
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


set matsize 3000

use "$directory_final/1-afrobarometer_games_15days.dta"

 histogram dist_match, discrete ytitle(Density of Interviews) xtitle(Distance to the Match) xscale(range(-15 15)) xlabel(-15(3)15)

 * Note: The figure needs just one minor editiion (using Graph Editor) to  to look exactly the same as the figure in manuscript (i.e., adding the dashed vertical line separating pre and post treatment periods)
 
 clear
 
