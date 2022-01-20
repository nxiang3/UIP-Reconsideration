clear
clear matrix
set more off
mata: mata set matafavor speed, perm

*** ECON872 new task3
*** by Nan Xiang
cd E:\Econ872_Paper\analysis
foreach country in CAD CHF DEM FRF GBP ITL JPY NOK SEK{
	cd E:\Econ872_Paper\analysis
	use input\data_updated_200617,clear
	keep if country2 == "`country'"

	replace cpi = log(cpi)
	replace cpi_usa = log(cpi_usa)
	xtset cty2 t
	* pi_t = p_t - p_(t-1)
	gen pi = d.cpi
	gen pi_dollar = d.cpi_usa 
	gen pi_r = pi_dollar - pi
	* qt = s_t-pr_t
	gen p_r = cpi_usa - cpi
	keep country2 cty2 date year month s_fama i_diff pi_r p_r

	sort year month
	gen t = _n
	xtset cty2 t
	gen p_r_lag12 = l12.p_r
	gen year_inflation = p_r - p_r_lag12 if p_r_lag12!=.
	gen s_fama_1 = f.s_fama
	gen s_diff = s_fama_1 - s_fama
	drop if year_inflation==.
	drop if s_diff ==.
	drop if i_diff == .
	gen excess = s_diff - i_diff
	cd E:\Econ872_Paper\analysis\output
	rolling _b _se, window(120) saving(`country'_yinflation_10y,replace) keep(date,start): reg s_diff i_diff year_inflation, r
	rolling _b _se, window(120) saving(`country'_yinflation_excess_10y,replace) keep(date,start): reg excess year_inflation, r
}