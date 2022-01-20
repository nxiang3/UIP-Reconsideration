*********************************************
*  Real UIP
*********************************************


use "$data/data_updated_201009",clear
sort country2 year month
merge 1:1 country2 year month using $inter/production_index
drop if _merge == 2
drop _merge
merge m:1 country1 year month using $inter/production_index_us
drop if _merge ==2 
drop _merge

//append using "$data/data_us_210625"

* construct y-o-y inflation for each country
xtset cty2 t
gen cpi_lag = l12.cpi
gen inflation = (log(cpi) - log(cpi_lag))/12

//gen inflation = log(cpi) - log(cpi_lag)
gen inflation_lag = l.inflation
gen inflation_change = inflation - l.inflation
* relative inflation
gen p_r = (log(cpi_usa) - log(cpi))/12
gen pr_lag = l12.p_r
gen p_r_diff = p_r - pr_lag
gen p_diff_lag = l.p_r_diff
// YEAR ON YEAR IP GROWTH
gen ip_growth_relative = lIP_growth_us - lIP_growth
gen ip_growth_relative_lag = l.ip_growth_relative
gen lIP_growth_us_lag = l.lIP_growth_us
	
// BUSINESS CYCLE RELATIVE
gen gap_relative = gap_us - gap


* monthly relative inflation
gen inflation_diff = d.p_r
replace inflation_diff = inflation_diff * 12
gen inflation_month = f.inflation_diff

* last period interest rates
gen i_diff_lag = l.i_diff
gen libor_lag = l.libor
gen libor_change = libor - libor_lag
* change in relative interest rates
gen i_diff_change = i_diff - i_diff_lag
* change in relative inflation
gen p_r_diff_change = p_r_diff - p_diff_lag


drop if country2 == "AUD" || country2 == "NZD" || country2 == "CHF"
drop cty2 
egen cty2 = group(country2)
xtset cty2 t

gen inflation_predict =.
//capture erase $tables/real_predict.xls
//capture erase $tables/real_predict_pigrowth.xls
forval i = 1(1)8{
	reg inflation_month p_r_diff i_diff ip_growth_relative gap_relative if cty2 == `i', r
	predict inflation_predict_`i' if cty2 == `i'
	replace inflation_predict = inflation_predict_`i' if cty2 == `i'
	//outreg2 using $tables/real_predict.xls, append dec(3) stats(coef se)
}

* real interest differential
gen r_diff = i_diff - inflation_predict

foreach x of global date{

	//use "$data/data_updated_201009",clear
	preserve
	
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
	
	gen srex = s_change - i_diff
	drop if r_diff ==.
	bys country2: gen Obs = _N
	drop if s_change ==. | r_diff ==.
	bys cty2: gen num = _N
	xtset cty2 t
	gen r_lag = l.r_diff

	reg r_diff r_lag if cty2 == 1, r
	gen var_rho = _se[r_lag]^2 if cty2 == 1
	* Step 1: construct corrected residuals
	gen rho_c = _b[r_lag] + (1+3 * _b[r_lag])/num + 3*(1+3 * _b[r_lag])/num/num if cty2 == 1
	gen theta_c = _b[_cons] if cty2 == 1
	gen v_c = r_diff - rho_c*r_lag - theta_c if cty2 == 1
	replace v_c = f.v_c if cty2 == 1
	* Step 2: estimate fama coefficient
	reg srex r_diff v_c if cty2 == 1 ,r
	gen beta_c = _b[r_diff] if cty2 == 1
	gen phi_c = _b[v_c] if cty2 == 1
	* Step 3: SE correction
	gen var_rho_c = var_rho*(1+3/num + 9/num/num)^2 if cty2 == 1
	gen var_beta_c = _se[r_diff]^2 if cty2 == 1
	gen se_beta_c_corrected = sqrt(phi_c^2*var_rho_c + var_beta_c) if cty2 == 1
	gen low = beta_c - 1.96*se_beta_c_corrected if cty2 == 1
	gen high = beta_c + 1.96*se_beta_c_corrected if cty2 == 1
	gen P_value = 2*ttail(e(df_r), abs((beta_c)/se_beta_c_corrected))
	//whole sample
	forval i = 1(1)8{
		reg r_diff r_lag if cty2 == `i', r
		replace var_rho = _se[r_lag]^2 if cty2 == `i'
		* Step 1: construct corrected residuals
		replace rho_c = _b[r_lag] + (1+3 * _b[r_lag])/num + 3*(1+3 * _b[r_lag])/num/num if cty2 == `i'
		replace theta_c = _b[_cons] if cty2 == `i'
		replace v_c = r_diff - rho_c*r_lag - theta_c if cty2 == `i'
		replace v_c = f.v_c if cty2 == `i'
		* Step 2: estimate fama coefficient
		reg srex r_diff v_c if cty2 == `i',r
		replace beta_c = _b[r_diff] if cty2 == `i'
		replace phi_c = _b[v_c] if cty2 == `i'
		* Step 3: SE correction
		replace var_rho_c = var_rho*(1+3/num + 9/num/num)^2 if cty2 == `i'
		replace var_beta_c = _se[r_diff]^2 if cty2 == `i'
		replace se_beta_c_corrected = sqrt(phi_c^2*var_rho_c + var_beta_c) if cty2 == `i'
		replace low = beta_c - 1.96*se_beta_c_corrected if cty2 == `i'
		replace high = beta_c + 1.96*se_beta_c_corrected if cty2 == `i'
		replace P_value = 2*ttail(e(df_r), abs((beta_c)/se_beta_c_corrected))
	}
	keep cty2 country2 beta_c se_beta_c_corrected low high Obs P_value
	duplicates drop
	
	gen CI = "(" + string(low,"%9.3f")  + "," + string(high, "%9.3f") + ")"
	keep country2 Obs CI beta_c P_value
	rename country2 Currency
	rename beta_c b
	merge 1:1 Currency using $data/date_pi_`x'
	drop _merge
	order Currency Time Obs b CI P_value
	format b P_value %9.3f
	drop if Currency == "CHF"
	save $results/corrected_realuip_pigrowth_`x', replace
	restore
}
