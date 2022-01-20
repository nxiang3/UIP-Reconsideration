**********************************
* Shadow Rates from Wu-Xia
**********************************
clear
import excel "$raw\shadowrate_US", sheet("Sheet1")
gen year = floor(A/100)
gen month = mod(A, 100)
gen shadow_libor_us = B/1200
gen country1 = "USD"
drop A B
save $inter\shadow_us, replace

import excel $raw\shadowrate_UK, sheet("Sheet1") clear
gen year = floor(A/100)
gen month = mod(A, 100)
gen shadow_libor = B/1200
gen country2 = "GBP"
drop A B
save $inter\shadow_uk, replace

import excel $raw\shadowrate_ECB, sheet("Sheet1") clear
gen year = floor(A/100)
gen month = mod(A, 100)
gen shadow_libor = B/1200
gen country2 = "DEM"
drop A B
append using $inter\shadow_uk
save $inter\shadow_ukecb, replace

use "$data/data_updated_201009",clear
sort year month country1
merge m:1 year month country1 using "$inter/shadow_us"
drop _merge
sort year month country2 
merge 1:1 year month country2 using "$inter/shadow_ukecb"
drop _merge
drop if shadow_libor ==.
drop if shadow_libor_us ==.
 
sort country2 year month

drop cty2 
egen cty2 = group(country2)
xtset cty2 t
gen srex = s_change - i_diff
drop if srex ==.
gen shadow_diff = shadow_libor_us - shadow_libor
drop if shadow_diff ==.
gen shadow_diff_lag = l.shadow_diff

qui: keep if year >= 2007
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

forval i = 1(1)2{
    reg shadow_diff shadow_diff_lag if cty2 == `i', r
	replace var_rho = _se[shadow_diff_lag]^2 if cty2 == `i'
	* Step 1: construct corrected residuals
	replace rho_c = _b[shadow_diff_lag] + (1+3 * _b[shadow_diff_lag])/num + 3*(1+3 * _b[shadow_diff_lag])/num/num if cty2 == `i'
	replace theta_c = _b[_cons] if cty2 == `i'
	replace v_c = shadow_diff - rho_c*shadow_diff_lag - theta_c if cty2 == `i'
	//xtset cty2 t
	replace v_c = f.v_c if cty2 == `i'
	* Step 2: estimate fama coefficient
	reg srex shadow_diff v_c if cty2 == `i',r
	replace beta_c = _b[shadow_diff] if cty2 == `i'
	replace phi_c = _b[v_c] if cty2 == `i'
	* Step 3: SE correction
	replace var_rho_c = var_rho*(1+3/num + 9/num/num)^2 if cty2 == `i'
	replace var_beta_c = _se[shadow_diff]^2 if cty2 == `i'
	replace se_beta_c_corrected = sqrt(phi_c^2*var_rho_c + var_beta_c) if cty2 == `i'
	replace low = beta_c - 1.96*se_beta_c_corrected if cty2 == `i'
	replace high = beta_c + 1.96*se_beta_c_corrected if cty2 == `i'
	replace  P_value = 2*ttail(e(df_r), abs((beta_c)/se_beta_c_corrected)) if cty2 == `i'
}
	keep country2 cty2 beta_c se_beta_c_corrected low high num P_value
	duplicates drop
	
	gen CI = "(" + string(low,"%9.3f")  + "," + string(high, "%9.3f") + ")"
	keep country2 num CI beta_c P_value
	rename country2 Currency
	rename beta_c d
	merge 1:1 Currency using $data/date_pi_v4
	keep if _merge == 3
	drop _merge
	rename num Obs
	order Currency Time Obs d CI P_value
	format d P_value %9.3f
	save $results/corrected_shadow, replace

