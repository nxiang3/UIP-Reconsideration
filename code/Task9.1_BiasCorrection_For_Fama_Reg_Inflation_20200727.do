************************************************
*    Bias Correction for Fama with Inflation   *
*            By: Nan Xiang                     *
************************************************

foreach x of global date{
	clear
	import excel $raw\date_pi_`x'.xlsx, sheet("Sheet1") firstrow
	sort Currency
	save $data/date_pi_`x', replace
	
	use "$data/data_updated_201009",clear
	gen p_r = log(cpi_usa) - log(cpi)
	xtset cty2 t
	gen pr_lag = l12.p_r
	gen p_r_diff = p_r - pr_lag
	gen p_diff_lag = l.p_r_diff
	drop if p_r_diff==.
	//drop if p_diff_lag ==. 
	drop if s_change ==. | i_diff ==.
	
	if "`x'" == "v1"{
		di "Full Sample"
	}
	if "`x'" == "v2"{
		qui: keep if year >= 1987
		di "1987/01-2020/09"
	}
	if "`x'" == "v3"{
		qui: keep if year >= 1987 & year <2007
		di "1989/01-2006/12"
	}
	if "`x'" == "v4"{
		qui: keep if year >= 2007
		di "2007/01-2020/09"
	}
	keep if inlist(country2, "CAD", "CHF", "DEM", "FRF", "GBP", "ITL", "JPY", "NOK", "SEK")
	drop cty2 
	egen cty2 = group(country2)
    //foreach country in CAD CHF DEM FRF GBP ITL JPY NOK SEK{
	//preserve
	//keep if country2 == "`country'"
	gen srex = s_change - i_diff
	bys cty2: gen num = _N
	gen var_rho =.
	gen rho_c =.
	gen theta_c =.
	gen v_c =.
	gen beta_c =.
	gen phi_c =.
	gen var_rho_c =.
	gen var_beta_c =.
	gen se_beta_c_corrected =.
	gen low =.
	gen high =.
	gen P_value =.
forval i = 1(1)9{
    reg p_r_diff p_diff_lag if cty2 == `i', r
	replace var_rho = _se[p_diff_lag]^2 if cty2 == `i'
	* Step 1: construct corrected residuals
	replace rho_c = _b[p_diff_lag] + (1+3 * _b[p_diff_lag])/num + 3*(1+3 * _b[p_diff_lag])/num/num if cty2 == `i'
	replace theta_c = _b[_cons] if cty2 == `i'
	replace v_c = p_r_diff - rho_c*p_diff_lag - theta_c if cty2 == `i'
	xtset cty2 t
	replace v_c = f.v_c if cty2 == `i'
	* Step 2: estimate fama coefficient
	reg srex p_r_diff v_c if cty2 == `i',r
	replace beta_c = _b[p_r_diff] if cty2 == `i'
	replace phi_c = _b[v_c] if cty2 == `i'
	* Step 3: SE correction
	replace var_rho_c = var_rho*(1+3/num + 9/num/num)^2 if cty2 == `i'
	replace var_beta_c = _se[p_r_diff]^2 if cty2 == `i'
	replace se_beta_c_corrected = sqrt(phi_c^2*var_rho_c + var_beta_c) if cty2 == `i'
	replace low = beta_c - 1.96*se_beta_c_corrected if cty2 == `i'
	replace high = beta_c + 1.96*se_beta_c_corrected if cty2 == `i'
	replace P_value = 2*ttail(e(df_r), abs((beta_c)/se_beta_c_corrected)) if cty2 == `i'
}
	keep country2 cty2 beta_c se_beta_c_corrected low high num P_value
	duplicates drop
	
	gen CI = "(" + string(low,"%9.3f")  + "," + string(high, "%9.3f") + ")"
	keep country2 num CI beta_c P_value
	rename country2 Currency
	rename beta_c d
	merge 1:1 Currency using $data/date_pi_`x'
	keep if _merge == 3
	drop _merge
	rename num Obs
	order Currency Time Obs d CI P_value
	format d P_value %9.3f
	save $results/corrected_fama_pi_`x', replace
}	


