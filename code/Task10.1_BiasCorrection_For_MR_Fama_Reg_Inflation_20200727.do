************************************************
*    Bias Correction for Medium-Run Fama Reg   *
*             With Inflation (Eq7)             *
*            By: Nan Xiang                     *
************************************************
* USE BIAS CORRECTION FORMULA FROM BOUDOUKH, ISRAEL AND RICHARDSON'2020 FOR LONG HORIZON PREDICTIVE REGRESSION

foreach x of global date{
use "$data/data_updated_201009",clear

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
g p_r_diff = p_r - p_r_lag12 // p_t - p_t-12 - (p_t* - p_t-12*)
gen p_diff_lag = l.p_r_diff

forval i = 1(1)11{
    drop if i_diff_forward`i'==.
}

keep country2 cty2 date year month s_change s_yoy i_sum i_diff_forward* i_diff p_r_diff p_diff_lag

	if "`x'" == "v1"{
		di "Full Sample"
	}
	if "`x'" == "v2"{
		qui: keep if year >= 1987
		di "1987/01-2020/09"
	}
	if "`x'" == "v3"{
		qui: keep if year >= 1987 & year <2007
		di "1987/01-2006/12"
	}
	if "`x'" == "v4"{
		qui: keep if year >= 2007
		di "2007/01-2020/09"
	}

drop if i_diff ==.
drop if p_r_diff ==.
* Medium Run Excess Return (1y)
g mr_ex_re = s_yoy - i_sum
* Short Run Excess Return (1m)
g sr_ex_re = s_change - i_diff


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
	reg sr_ex_re p_r_diff
	predict u,r
	* innovation and persistence of autocorrelation
	reg p_r_diff p_diff_lag
	g rho = _b[p_diff_lag]
	predict v,r
	* Covariance between u and v
	correlate u v, covariance
	g float uv_cov = r(cov_12)
	* Variance of v
	egen v_var = sd(v)
	replace v_var = v_var^2
	* Bias: beta_hat + bias = beta
	g bias = (J*(1+rho) + 2*rho*(1-rho^J)/(1-rho)) * uv_cov / v_var / T
	* Predictive Regression
	tsset t
	newey mr_ex_re p_r_diff, lag(12)
	g beta_J = _b[p_r_diff]
	replace beta_J = beta_J + bias
	* adjusted standard error (Boudoukh, Richardson and  Whitelaw'2008')
	egen sr_var = sd(sr_ex_re)
	replace sr_var = sr_var^2
	egen p_diff_var = sd(p_r_diff)
	replace p_diff_var = p_diff_var^2
	g se = sqrt(J*sr_var/T/p_diff_var*sqrt(1 + 2*rho/J/(1-rho)*((J-1) - rho*(1-rho^(J-1))/(1-rho))))
	g high = beta_J + 1.96*se
	g low = beta_J -1.96*se
	g P_value = 2*ttail(e(df_r), abs((beta_J)/se))
	keep country2 cty2 T beta_J high low P_value
	duplicates drop 
	save $inter/mr_inflation_`country'_`x', replace
	restore
}

use $inter/mr_inflation_CAD_`x', clear
foreach country in CHF DEM FRF GBP ITL JPY NOK SEK{
    append using $inter/mr_inflation_`country'_`x'
}

	gen CI = "(" + string(low,"%9.3f")  + "," + string(high, "%9.3f") + ")"
	keep country2 T beta_J CI P_value
	rename country2 Currency
	rename T Obs
	rename beta_J b
	sort Currency
	merge 1:1 Currency using $data/date_`x'
	drop _merge
	order Currency Time Obs b CI P_value
	format b P_value %9.3f
	drop if Currency == "AUD" | Currency == "NZD"
	save $results/corrected_mrfama_inflation_`x', replace
}
