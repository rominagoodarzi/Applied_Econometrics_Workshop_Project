use "Result/cleaned.dta", clear

//step 1: Generate some local lists

	local varlist0  "age age2 i.educ i.edu"
	local varlist1  "i.sex age age2 i.educ i.edu"
	local varlist2  "*.year *.fasl *.ostan *.ur"
	local location  "Location FE"
	local year 	"TimE FE"
	local order "age age2 *.sex *.educ *.edu *.citizen *.mar"
	
//step 2: Generate some regression and export them to tex  
	
	qui eststo: logit pr `varlist1' [pweight=IW_Yearly], vce(robust)
	estadd local location No
	estadd local year No
	est store r1
	
	qui eststo: logit pr `varlist1' i.year i.fasl [pweight=IW_Yearly], vce(robust)
	estadd local location No
	estadd local year Yes
	est store r2
	
	qui eststo: logit pr `varlist1' i.year i.fasl i.ur i.ostan [pweight=IW_Yearly], vce(robust)
	estadd local location Yes
	estadd local year Yes
	est store r3
	
	qui eststo: logit pr `varlist1' i.year i.fasl i.ur i.ostan i.citizen i.mar [pweight=IW_Yearly], vce(robust)
	estadd local location Yes
	estadd local year Yes
	est store r4
	
	qui estpost margins, dydx(`varlist1' i.citizen i.mar)
	est store mar
	
	esttab r1 r2 r3 r4 mar using "Result/reg.tex",replace compress label b(%9.3f) se(%9.3f) star(* 0.1 ** 0.05 *** 0.01)  ///
	s(location year N, label("Region FE" "Time FE" "N. of Obs")) nomtitles ///
	drop(`varlist2') order(`order') title("Logit regressions \label{reg}") ///
	addnotes("Notes: Time FE: Year and season fixed effects; Region FE: Province and Urban/Rural fixed effects." "Base levels: Irainian-Urban area-Illitrate-Married-spring-year 92.") ///
    longtable eqlabels(none) noomitted nobaselevels ///
	collabels("Logit" "Logit" "Logit" "Logit" "Margins",lhs("Activity Prob.")) noconstant booktabs ///
	refcat(1.sex "\emph{Gender:}" 1.educ "\emph{Schooling stat.:}" 1.edu "\emph{Degree of educ.:}" 2.citizen "\emph{Citizenship:}" 2.mar "\emph{Marriage stat.:}" , nolabel)
	
//step 3: Generate OLS, Probit regressions for comparing them with Logit and generate Logit for males, Urbans & Logit with clustring for families 
	
	qui eststo: reg pr `varlist1' i.year i.fasl i.ur i.ostan i.citizen i.mar [pweight=IW_Yearly], vce(robust)
	estadd local location Yes
	estadd local year Yes
	est store r7
	
	qui eststo: probit pr `varlist1' i.year i.fasl i.ur i.ostan i.citizen i.mar [pweight=IW_Yearly], vce(robust)
	estadd local location Yes
	estadd local year Yes
	est store r8
	
	qui eststo: logit pr `varlist1' i.year i.fasl i.ur i.ostan i.citizen i.mar [pweight=IW_Yearly], vce(cluster pkey)
	estadd local location Yes
	estadd local year Yes
	est store r9
	
	qui eststo: logit pr `varlist0' i.year i.fasl i.ostan i.citizen i.mar if sex==1 [pweight=IW_Yearly], vce(robust)
	estadd local location Yes
	estadd local year Yes
	est store r10
	
	qui eststo: logit pr `varlist0' i.year i.fasl i.ur i.ostan i.citizen i.mar if sex==0 & ur==1 [pweight=IW_Yearly], vce(robust)
	estadd local location Yes
	estadd local year Yes
	est store r11
	
	esttab r7 r8 r9 r10 r11 using "Result/reg2.tex",replace compress label b(%9.3f) se(%9.3f) star (* 0.1 ** 0.05 *** 0.01)  ///
	s(location year N, label("Region FE" "Time FE" "N. of Obs")) nomtitles ///
	drop(`varlist2') order(`order') title("OLS, Logit & Probit regressions\label{reg2}") ///
	addnotes("Notes: Time FE: Year and season fixed effects; Region FE: Province and Urban/Rural fixed effects;" "Base levels: Irainian-Urban area-Illitrate-Married-spring-year 92;" "Cluster for families; FU(MR):restrict for being female in urban(male in rural) areas;" "Cluster, FU & MR use Logit") ///
    longtable noomitted nobaselevels ///
	collabels("OLS" "Probit" "Cluster" "FU" "MR",lhs("Activity Prob.")) eqlabels(none) noconstant booktabs unstack ///
	refcat(1.sex "\emph{Gender:}" 1.educ "\emph{Schooling stat.:}" 1.edu "\emph{Degree of educ.:}" 2.citizen "\emph{Citizenship:}" 2.mar "\emph{Marriage stat.:}" , nolabel)
	
	
