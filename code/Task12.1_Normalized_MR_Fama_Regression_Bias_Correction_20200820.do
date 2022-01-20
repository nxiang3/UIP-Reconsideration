************************************************
*    Bias Correction for Medium-Run Fama Reg   *
*              Normalized                      *
*            By: Nan Xiang                     *
************************************************
* USE BIAS CORRECTION FORMULA FROM BOUDOUKH, ISRAEL AND RICHARDSON'2020 FOR LONG HORIZON PREDICTIVE REGRESSION

cd E:/Econ872_Paper/analysis
use input/data_updated_200617,clear

replace cpi = log(cpi)
replace cpi_usa = log(cpi_usa)
xtset cty2 t
g s_year = f12.s_fama // exchange rate 12 month ahead t+12
g s_yoy = s_year - s_fama // s_t+12 - s_t
//sum of interest differential into 11 periods ahead 
forval i = 1(1)11{
    g i_diff_forward`i' = f`i'.i_diff
}
egen i_sum = rowtotal(i_diff_forward*)
replace i_sum = i_sum + i_diff
//inflation
g p_r = cpi_usa - cpi
g p_r_lag12 = l12.p_r
g p_r_diff = (p_r - p_r_lag12)/12 // p_t - p_t-12 - (p_t* - p_t-12*)
* Normalized interest differential
g norm_idiff = i_diff - p_r_diff
gen norm_idiff_lag = l.norm_idiff

forval i = 1(1)11{
    drop if i_diff_forward`i'==.
}
keep country2 cty2 date year month q s_change s_yoy i_sum i_diff_forward* i_diff p_r_diff norm_idiff norm_idiff_lag

drop if i_diff ==.
drop if norm_idiff ==.
* Medium Run Excess Return (1y)
g mr_ex_re = s_yoy - i_sum
* Short Run Excess Return (1m)
g sr_ex_re = s_change - i_diff

******1989:01-2017:11
keep if year > 1988
keep if year < 2018
drop if year == 2017 & month == 12 
******

***** 1989:01-2006:12
keep if year < 2007
keep if year > 1988
*****

*****2007:01-2017:11
keep if year < 2018
keep if year > 2006
drop if year == 2017 & month == 12 
*****


//whole sample

foreach country in CAD CHF DEM FRF GBP ITL JPY NOK SEK{
    preserve
    keep if country2 == "`country'"
	* Sample Size
	g T = _N
	sort year month
	g t = _n
	* Horizon
	g J = 12
	* innovation from 1m predictive regression: u
	reg sr_ex_re norm_idiff
	predict u,r
	* innovation and persistence of autocorrelation
	reg norm_idiff norm_idiff_lag
	g rho = _b[norm_idiff_lag]
	predict v,r
	* Covariance between u and v
	correlate u v, covariance
	g float uv_cov = r(cov_12)
	* Variance of v
	egen v_var = var(v)
	* Bias: beta_hat + bias = beta
	g bias = (J*(1+rho) + 2*rho*(1-rho^J)/(1-rho)) * uv_cov / v_var / T
	* Predictive Regression
	tsset t
	newey mr_ex_re norm_idiff, lag(12)
	g beta_J = _b[norm_idiff]
	replace beta_J = beta_J + bias
	* adjusted standard error (Boudoukh, Richardson and  Whitelaw'2008')
	egen sr_var = var(sr_ex_re)
	egen norm_idiff_var = var(norm_idiff)
	g se = sqrt(J*sr_var/T/norm_idiff_var * sqrt(1 + 2*rho/J/(1-rho)*((J-1) - rho*(1-rho^(J-1))/(1-rho))))
	g high = beta_J + 1.96*se
	g low = beta_J -1.96*se
	keep country2 cty2 beta_J high low
	duplicates drop 
	save temp/Normalized_mr_inflation_`country', replace
	restore
}

use temp/Normalized_mr_inflation_CAD, clear
foreach country in CHF DEM FRF GBP ITL JPY NOK SEK{
    append using temp/Normalized_mr_inflation_`country'
}
//save temp/8917_MR_Corrected,replace
//save temp/8906_MR_Corrected,replace
save temp/0717_MR_Corrected,replace