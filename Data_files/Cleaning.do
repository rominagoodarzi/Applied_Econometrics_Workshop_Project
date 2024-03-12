//step 1: append dta files for 1392-1398

	use "Data/lfs92.dta" ,clear

	forvalues i=3/8 {
	append using "Data/lfs9`i'.dta"
	}

	save "Data/lfs.dta", replace

//step 2: change the name of some variables and desting them

	replace IW_Yearly = IW10_Yearly if IW_Yearly==.
	drop IW10_Yearly IW15_Yearly

	rename F2_D04 sex
	rename F2_D07 age
	rename F2_D08 citizen
	rename F2_D19 mar
	rename F2_D15 educ
	
	keep pkey sex age citizen NobatAmargiri mar educ F2_D16 F2_D17 ActivityStatus IW_Yearly
	destring sex-NobatAmargiri , replace force
	
//step 3: drop age under 18 and over 65
	drop if age<17 | age>66

//step 4: generate some variable that we need for regressions and label them

	// gen pr var: for active people 1 & for others 0
		g pr=(ActivityStatus==2 | ActivityStatus==1)
		label var pr "probablity of activity"

	//gen "urban/rural": var for urban 1 & for rural 2
		g ur=substr(pkey,5,1) 
		destring ur, replace
		replace ur=0 if ur==1
		replace ur=1 if ur==2
		label define ur 0 "urban" 1 "rural"
		label values ur ur

	//gen "year" var
		g year=substr(pkey,1,2)
		destring year, replace
		
	//gen "fasl" var for seasons
		rename NobatAmargiri fasl
		label define fasl 1 "spring" 2 "summer" 3 "fall" 4 "winter"
		label values fasl fasl

	//gen "ostan" var: for provinces
		g ostan=substr(pkey,3,2)
		destring ostan, replace

	//gen "edu" var: for education status
		gen edu=.
		label var edu "Education status"
		replace edu=0 if F2_D16==2
		replace edu=1 if F2_D17==1 | F2_D17==11
		replace edu=2 if F2_D17==2 | F2_D17==3 | F2_D17==4 | F2_D17==21 | F2_D17==31 | F2_D17==41
		replace edu=3 if F2_D17==5 | F2_D17==6 | F2_D17==7 | F2_D17==8 | F2_D17==51 | F2_D17==52 | F2_D17==53 | F2_D17==61

		label define edu 0 "Illitrate" 1 "Primary sch." 2 " High sch." 3 "University"
		label values edu edu
		
		
		label var educ "schooling status"
		replace educ=0 if educ==2
		label define educ 1 "Student" 0  "No student"
		label values educ educ
	//generate sex ratio
		g male = (sex==1)
		g female = (sex==2)
		egen men = sum(male), by(year)
		egen women = sum(female), by(year)
		g sex_ratio = men/women
		label var sex_ratio "sex ratio"
		
	//label sex gategories
		replace sex=0 if sex==1
		replace sex=1 if sex==2 
		label define sex 0 "Male" 1 "Female"
		label values sex sex
		
	//gen age^2
		gen age2=age^2
		label var age2 "age^2"

	//label some variables
		label define mar 1 "Married" 2 "Widow" 3 "Divorced" 4 "Single"
		label values mar mar
		g mar_ratio=(mar==1)
		
		label define citizen 1 "Iranian" 2 "Afghan" 3 "Else"
		label values citizen citizen
		g citi_ratio=(citizen==1)
		
		//gen agegrp: for agegroups
		g agegrp=.
		replace agegrp=1 if age<=22
		replace agegrp=2 if age>=23 & age<=27
		replace agegrp=3 if age>=28 & age<=32
		replace agegrp=4 if age>=33 & age<=37
		replace agegrp=5 if age>=38 & age<=42
		replace agegrp=6 if age>=43 & age<=47
		replace agegrp=7 if age>=48 & age<=52
		replace agegrp=8 if age>=53 & age<=57
		replace agegrp=9 if age>=58
		egen m=total(male), by(agegrp year)
		egen wm=total(female), by(agegrp year)
		label define agegrp 1 "18 to 22" 2 "23 to 27" 3 "28 to 32" 4 "33 to 37" 5 "38 to 42" 6 "43 to 47" 7 "48 to 52" 8 "53 to 57" 9 "58 to 65"
		label values agegrp agegrp
		
	
	save "Result/cleaned.dta", replace
