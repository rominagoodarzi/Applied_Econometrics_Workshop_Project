    set matsize 1000
	graph set window fontface "Times New Roman"
		
	grstyle init
	grstyle anglestyle vertical_tick horizontal
	
	clear all
	set more off
	cd "/Users/rominagoodarzi/Desktop/Applied Econometrics_Workshop_Project"

 /*-------------------------------Cleaning---------------------------------*/

 //step 1: Label some variables
 
 label var exper "labor's experience"
 
 label define occ1 1 "Professional, Technical and kindred"
 label values occ1 occ1
 label define occ2 1 "Managers, Offcials and Proprietors"
 label values occ2 occ2
 label define occ3 1 "Sales Workers"
 label values occ3 occ3
 label define occ4 1 "Clerical and kindred"
 label values occ4 occ4
 label define occ5 1 "Craftsmen, Foremen and kindred"
 label values occ5 occ5
 label define occ6 1 "Operatives and kindred"
 label values occ6 occ6
 label define occ7 1 "Laborers and farmers"
 label values occ7 occ7
 label define occ8 1 "Farm Laborers and Foreman"
 label values occ8 occ8
 label define black 1 "Black"
 label values black black
 label define married 1 "Married"
 label values married married
 label define hisp 1 "Hispanic"
 label values hisp hisp
 label define union 1 "is member"
 label values union union
 
 gen occ=.
 forvalues i=1/9 {
 replace occ=`i' if occ`i'==1
 }
 label define occ 1 "Professional, Technical and kindred" 2 "Managers, Offcials and Proprietors" 3 "Sales Workers" 4 "Clerical and kindred" 5 "Craftsmen, Foremen and kindred" 6 "Operatives and kindred" 7 "Laborers and farmers" 8 "Farm Laborers and Foreman" 9 "Service Workers"
 label values occ occ
 
 label var occ "Occupational types"

 //step 2: Generate some variables
 gen wage=exp(lwage)
 label var wage "weekly"
 

 
 
 /*-------------------------------Descriptive------------------------------*/

//step 1:  Calculate some statistics for some control variables

	estpost tabstat black hisp married union, statistics(mean) columns(statistics)
	esttab using "result/table1.tex", cells("mean(fmt(%9.3f))") replace nonumber nomtitle label unstack ///
	coeflabels(black "Blacks/Total" hisp "Hispanics/Total" married "Married/Total" union "Union members/Total") 

//step 2: Table for Occupations

	qui estpost tabulate occ
	esttab using "result/occ.tex", replace unstack noobs nonumber label cells("b pct(fmt(%9.1f)) cumpct(fmt(%9.1f))") varlabels(`e(labels)') eqlabels(`e(eqlabels)')

//step 3: Graph histogram for wage

	histogram wage , name(histwage, replace) title("Histogram of weekly wage($)") percent fcolor(gray) lcolor(black) ylabel(, angle(0))
	graph export "result/wage.png", replace

//step 4: Graph barchart for wage over years

	graph bar wage, label name(barwage,replace) over(year) title("Barchart of wage over years") ytitle("weekly wage($)")
	graph export "result/wage2.png", replace
	
//step 5:  Calculate some statistics for some control variables

	estpost tabstat wage educ exper hours, statistics(mean median sd min max) columns(statistics) listwise
	esttab using "result/table2.tex", cells("mean(fmt(%9.0f)) p50(fmt(%9.0f)) sd(fmt(%9.2f)) min(fmt(%9.0f)) max(fmt(%9.0f))") ///
	varlabels(wage "weekly wage") replace nonumber nomtitle label

//step 6: Graph barchart for experience over education

	graph bar exper, over(educ) name(educexper, replace) title("Barchart for avg. of experience over years of schooling") ytitle("Experience(years)")
	graph export "result/educexper.png" , replace
	
//step 7: Graph barchart for annual work hours over years

	graph bar hours, label name(hours,replace) over(year) title("Barchart of annual work hours over years") ytitle("Annual work hours")
	graph export "result/hours.png", replace
	
//step 8: Graph barchart for wage over occupational types

	graph hbar wage, label name(occ,replace) over(occ) title("Avg. weekly wage for each occ. types") ytitle("weekly wage($)")
	graph export "result/occ.png", replace
	
//step 9: Graph barchart for marriage over years
	graph bar married, label name(mar,replace) over(year) title("Barchart of marriage rate over years") ytitle("Marriage rate")
	graph export "result/mar.png", replace
	
	
	
	
 /*-------------------------------Regression-------------------------------*/

  replace hours=hours/100
//step 1: Generate local list
 
	local varlist1 "lwage educ exper hours i.married i.hisp i.black i.union i.occ1 i.occ2 i.occ3 i.occ4 i.occ5 i.occ6 i.occ7 i.occ8"
	
//step 2: Generate panel regressions

 	xtset year nr , yearly
	qui eststo: xtreg  `varlist1', fe 
	estadd local unit No
	estadd local time Yes
	est store fixed
	qui eststo: xtreg `varlist1', re
	estadd local unit No
	estadd local time Yes
	est store random
	hausman fixed random
	
	xtset nr year, yearly
	qui eststo: xtreg `varlist1', fe 
	estadd local unit Yes
	estadd local time No
	est store fixed2
	qui eststo: xtreg `varlist1', re
	estadd local unit Yes
	estadd local time No
	est store random2
	hausman fixed2 random2
	
	xtset year nr, yearly
	qui eststo: xtreg `varlist1' i.nr, fe
	estadd local unit Yes
	estadd local time Yes
	est store alleffect
	
//step 3: Export regression table to tex
	esttab fixed2 random alleffect using "result/reg.tex",replace compress label b(%9.3f) se(%9.2f) star(* 0.1 ** 0.05 *** 0.01)  ///
	drop(*.nr) s(unit time N, fmt(%9.0f) label("Individual FE" "Time FE" "N. of Obs")) mtitles("FE" "RE" "FE") ///
	title("Panel regressions \label{reg}") ///
	longtable eqlabels(none) noomitted nobaselevels varlabels(_cons "Constant" hours "hours worked(100h)") ///
	collabels("",lhs("ln(Wage:Dollar)")) noconstant booktabs  ///
	refcat(1.black "\emph{Color:}" 1.hisp "\emph{Race:}"  1.married "\emph{Marriage status:}" 1.union "\emph{Union membership:}" 1.occ1 "\emph{Career type:}" , nolabel) ///
	addnotes("Notes: Time FE: Year fixed effects. unit of hours worked: 100hours" "Base levels: Service Workers, Not Hispanic, Not black, No member of union, Single.")
