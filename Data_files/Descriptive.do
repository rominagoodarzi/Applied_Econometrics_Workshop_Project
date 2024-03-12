use "Result/cleaned.dta", clear
tempfile temp
save `temp'

//step 1: Graph barchart for eduaction & marriage status
	graph bar [pweight=IW_Yearly], label name(edu,replace) over(edu)
	graph bar [pweight=IW_Yearly], name(mar,replace) label over(mar)
	graph combine edu mar, name(g3,replace) rows(2) title("Percentage of each eduaction & marriage status for all years")
	graph export "Result/combine.png", replace

//step 2: Calculate some statistics: sex ratio, urban ratio, student ratio and marriage ratio 
	estpost tabstat sex_ratio ur educ mar_ratio citi_ratio , statistics(mean) columns(statistics) by(year)
	esttab using "Result/table1.tex", cells("mean(fmt(%9.2f))") replace unstack noobs nonumber nomtitle label collabels(none) coeflabels(sex_ratio "Male/Female" ur "Rural/Total" educ "Student/Total" mar_ratio "Married/Total" citi_ratio "Iranian/Total")

//step 3:  Calculate some statistics for age over years
	estpost tabstat age , statistics(mean median sd) columns(statistics) listwise by(year)
	esttab using "Result/age.tex", cells("mean(fmt(%9.1f)) p50(fmt(%9.0f)) sd(fmt(%9.2f))") replace noobs nonumber nomtitle collabels(,lhs("Year"))

//step 4: Graph participation rate over years for education status
	collapse (mean) pr (sum) IW_Yearly , by(edu year)
	graph twoway (line pr year if edu==0 [pweight=IW_Yearly]) (line pr year if edu==1 [pweight=IW_Yearly]) (line pr year if edu==2 [pweight=IW_Yearly]) (line pr year if edu==3 [pweight=IW_Yearly]), title(Participation rate over years for education status)  ///
	xl(#7) yl(#7) ytitle(participation rate) ysc(titlegap(3)) xsc(titlegap(2)) name(g1,replace) legend(order(1 "Illitrate" 2 "Primary school" 3 "High school" 4 "University"))
	graph export "Result/g1.png",replace
	use `temp',clear

//step 5: Graph participation rate by gender over years 
	collapse (mean) pr (sum) IW_Yearly , by(sex year)
	graph twoway (line pr year if sex==0 [pweight=IW_Yearly],c(l) yaxis(1))  (line pr year if sex==1 [pweight=IW_Yearly],c(l) yaxis(2)), title(Participation rate over years by gender)  ///
	xl(#7) yl(0.75(0.01)0.8,axis(1)) yl(0.15(0.01)0.2,axis(2)) ytitle(male,axis(1)) ytitle(female,axis(2)) ysc(titlegap(3)) ysc(titlegap(2) axis(2)) xsc(titlegap(2)) legend(order(1 "male" 2 "female")) name(g2,replace)
	graph export "Result/g2.png",replace
	use `temp',clear

//step 6: Graph population pyramid for two years

	collapse (mean) m (mean) wm (sum)IW_Yearly , by(year agegrp)
	replace m = -m
	g zero = 0
	
	twoway (bar m agegrp[pweight=IW_Yearly] if year==92, horizontal bfc(gs7) blc(gs7)) ///
	(bar wm agegrp[pweight=IW_Yearly] if year==92, horizontal bfc(gs11) blc(gs11)) ///
	(scatter agegrp zero, mlabel(agegrp) mlabcolor(black) msymbol(none)), title("year 1392") ///
	xtitle("Population") ytitle(" ") yscale(noline) ylabel(none) legend(order(1 "male" 2 "female")) ///
	xsc(titlegap(2)) xlabel(#5) name(pr1,replace)
	
	twoway (bar m agegrp[pweight=IW_Yearly] if year==98, horizontal bfc(gs7) blc(gs7)) ///
	(bar wm agegrp[pweight=IW_Yearly] if year==98, horizontal bfc(gs11) blc(gs11)) ///
	(scatter agegrp zero, mlabel(agegrp) mlabcolor(black) msymbol(none)), title("year 1398") ///
	xtitle("Population") ytitle(" ") yscale(noline) ylabel(none) legend(order(1 "male" 2 "female")) ///
	xsc(titlegap(2)) xlabel(#5) name(pr2,replace)
	
	graph combine pr1 pr2, name(combine2,replace) title("Population pyramid")
	graph export "Result/combine2.png", replace
