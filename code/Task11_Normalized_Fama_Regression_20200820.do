**************************************
*    Normalized Fama Regression
**************************************
cd E:\Econ872_Paper\analysis
capture close
//3-lags
foreach country in CAD CHF DEM FRF GBP ITL JPY NOK SEK{
	//use temp/VAR_`country'_yoy.dta, clear
	//drop if year > 2009
	//drop if year == 2009 & month > 10
	//use temp/VAR_`country'_8917_yoy.dta,clear
	//use temp/VAR_`country'_8906_yoy.dta,clear
	use temp/VAR_`country'_0717_yoy.dta,clear
	sort year month
	g t = _n
	xtset cty2 t
	* excess return 
	g exre = s_growth - i_diff 
	* normalized interest rate differentials
	g norm_idiff = i_diff - pi_ryoy
	
	gen coef_t = .
	label variable coef_t "Estimated coefficient of normalized interest rate differentials"
	gen tstat_t = .
	label variable tstat_t "t-statistics of normalized interest rate differentials"
	gen cilow_t = .
	label variable cilow_t "Lower bound of 95% CI, normalized interest rate differentials"
	gen cihigh_t = .
	label variable cihigh_t "Upper bound of 95% CI, normalized interest rate differentials"
	
	reg exre norm_idiff if country2 == "`country'", r
	replace coef_t = _b[norm_idiff] 
	local tstat = _b[norm_idiff]/_se[norm_idiff]
	replace tstat_t = `tstat' 
	local cilow = _b[norm_idiff] - 1.96 * _se[norm_idiff]
	replace cilow_t = `cilow' 
	local cihigh = _b[norm_idiff] + 1.96 * _se[norm_idiff]	
	replace cihigh_t = `cihigh'
	keep country2 coef_t cihigh cilow 
	duplicates drop
	//save temp/Normalized_Fama_`country', replace
	outreg2 using "temp/Fama_norm.xls", append dec(3) stats(coef se) adds(t-test, `tstat', CI-low, `cilow', CI-high, `cihigh')
}

/*
use temp/Normalized_Fama_CAD, clear
foreach country in CHF DEM FRF GBP ITL JPY NOK SEK{
    append using temp/Normalized_Fama_`country'
}
*/
//save temp/Normalized_wholesample, replace
//save temp/Normalized_8917, replace
//save temp/Normalized_8906, replace
//save temp/Normalized_0717, replace