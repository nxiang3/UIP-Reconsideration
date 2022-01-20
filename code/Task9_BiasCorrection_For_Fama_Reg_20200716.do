************************************************
*         Bias Correction for Fama Reg         *
*            By: Nan Xiang                     *
************************************************

foreach x of global date{
    clear
	import excel $raw\date_`x'.xlsx, sheet("Sheet1") firstrow
	sort Currency
	save $data/date_`x', replace
	
	use "$data/data_updated_201009",clear

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
	bys country2: gen Obs = _N
	drop if s_change ==. | i_diff ==.
	bys cty2: gen num = _N
	xtset cty2 t
	gen i_lag = l.i_diff

	reg i_diff i_lag if cty2 == 1, r
	gen var_rho = _se[i_lag]^2 if cty2 == 1
	* Step 1: construct corrected residuals
	gen rho_c = _b[i_lag] + (1+3 * _b[i_lag])/num + 3*(1+3 * _b[i_lag])/num/num if cty2 == 1
	gen theta_c = _b[_cons] if cty2 == 1
	gen v_c = i_diff - rho_c*i_lag - theta_c if cty2 == 1
	replace v_c = f.v_c if cty2 == 1
	* Step 2: estimate fama coefficient
	reg s_change i_diff v_c if cty2 == 1 ,r
	gen beta_c = _b[i_diff] if cty2 == 1
	gen phi_c = _b[v_c] if cty2 == 1
	* Step 3: SE correction
	gen var_rho_c = var_rho*(1+3/num + 9/num/num)^2 if cty2 == 1
	gen var_beta_c = _se[i_diff]^2 if cty2 == 1
	gen se_beta_c_corrected = sqrt(phi_c^2*var_rho_c + var_beta_c) if cty2 == 1
	gen low = beta_c - 1.96*se_beta_c_corrected if cty2 == 1
	gen high = beta_c + 1.96*se_beta_c_corrected if cty2 == 1
	gen P_value = 2*ttail(e(df_r), abs((beta_c-1)/se_beta_c_corrected))
	//whole sample
	forval i = 2(1)11{
		reg i_diff i_lag if cty2 == `i', r
		replace var_rho = _se[i_lag]^2 if cty2 == `i'
		* Step 1: construct corrected residuals
		replace rho_c = _b[i_lag] + (1+3 * _b[i_lag])/num + 3*(1+3 * _b[i_lag])/num/num if cty2 == `i'
		replace theta_c = _b[_cons] if cty2 == `i'
		replace v_c = i_diff - rho_c*i_lag - theta_c if cty2 == `i'
		replace v_c = f.v_c if cty2 == `i'
		* Step 2: estimate fama coefficient
		reg s_change i_diff v_c if cty2 == `i',r
		replace beta_c = _b[i_diff] if cty2 == `i'
		replace phi_c = _b[v_c] if cty2 == `i'
		* Step 3: SE correction
		replace var_rho_c = var_rho*(1+3/num + 9/num/num)^2 if cty2 == `i'
		replace var_beta_c = _se[i_diff]^2 if cty2 == `i'
		replace se_beta_c_corrected = sqrt(phi_c^2*var_rho_c + var_beta_c) if cty2 == `i'
		replace low = beta_c - 1.96*se_beta_c_corrected if cty2 == `i'
		replace high = beta_c + 1.96*se_beta_c_corrected if cty2 == `i'
		replace P_value = 2*ttail(e(df_r), abs((beta_c-1)/se_beta_c_corrected))
	}
	keep cty2 country2 beta_c se_beta_c_corrected low high Obs P_value
	duplicates drop
	
	gen CI = "(" + string(low,"%9.3f")  + "," + string(high, "%9.3f") + ")"
	keep country2 Obs CI beta_c P_value
	rename country2 Currency
	rename beta_c b
	merge 1:1 Currency using $data/date_`x'
	drop _merge
	order Currency Time Obs b CI P_value
	format b P_value %9.3f
	save $results/corrected_fama_`x', replace

}